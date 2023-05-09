import SwiftUI
import CoreData
import HackerNewsKit

struct HomeView: View {
    @EnvironmentObject private var auth: Authentication
    @StateObject private var storyStore = StoryStore()
    @ObservedObject private var settings = Settings.shared
    @ObservedObject private var router = Router.shared
    
    @State private var showLoginDialog = Bool()
    @State private var showLogoutDialog = Bool()
    @State private var showAboutSheet = Bool()
    @State private var showUrlSheet = Bool()
    
    @State private var username = String()
    @State private var password = String()
    @State private var shouldRememberMe = Bool()
    
    @State private var actionPerformed: Action = .none
    private static var handledUrl: URL? = nil
    
    var body: some View {
        NavigationStack(path: $router.path) {
            List {
                NavigationLink(value: Destination.pin) {
                    Label("Pins", systemImage: "pin")
                }
                .listRowSeparator(.hidden)
                
                ForEach(storyStore.stories) { story in
                    ItemRow(item: story,
                            actionPerformed: $actionPerformed)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .listRowSeparator(.hidden)
                    .onAppear {
                        storyStore.onStoryRowAppear(story)
                    }
                }
            }
            .navigationDestination(for: Comment.self) { cmt in
                ItemView(item: cmt, level: 0)
            }
            .navigationDestination(for: Story.self) { story in
                ItemView(item: story, level: 0)
            }
            .navigationDestination(for: Destination.self) { val in val.toView() }
            .listStyle(.plain)
            .refreshable {
                await storyStore.refresh()
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        router.to(Destination.search)
                    } label: {
                        Label(String(), systemImage: "magnifyingglass")
                    }
                }
                ToolbarItem {
                    Button {
                        router.to(Destination.fav)
                    } label: {
                        Label(String(), systemImage: "heart")
                    }
                }
                ToolbarItem {
                    Menu {
                        ForEach(StoryType.allCases, id: \.self) { storyType in
                            Button {
                                storyStore.storyType = storyType
                                
                                Task {
                                    await storyStore.fetchStories()
                                }
                            } label: {
                                Label("\(storyType.rawValue.uppercased())", systemImage: storyType.iconName)
                            }
                        }
                        Divider()
                        AuthButton(showLoginDialog: $showLoginDialog, showLogoutDialog: $showLogoutDialog)
                        Button {
                            showAboutSheet = true
                        } label: {
                            Label("About", systemImage: "")
                        }
                    } label: {
                        Label("Add Item", systemImage: "list.bullet")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle(storyStore.storyType.rawValue.uppercased())
        }
        .withToast(actionPerformed: $actionPerformed)
        .tint(.orange)
        .sheet(isPresented: $showAboutSheet, content: {
            SafariView(url: Constants.githubUrl)
        })
        .sheet(isPresented: $showUrlSheet, content: {
            SafariView(url: Self.handledUrl!)
        })
        .alert("Login", isPresented: $showLoginDialog, actions: {
            TextField("Username", text: $username)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            Button("Login", action: {
                guard username.isNotEmpty && password.isNotEmpty else {
                    HapticFeedbackService.shared.error()
                    return
                }
                
                Task {
                    // TODO: Ask user whether or not the app should store their login info.
                    let res = await auth.logIn(username: username, password: password, shouldRememberMe: true)
                    
                    if res {
                        HapticFeedbackService.shared.success()
                        actionPerformed = .login
                    } else {
                        HapticFeedbackService.shared.error()
                    }
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter your username and password.")
        })
        .alert("Logout", isPresented: $showLogoutDialog, actions: {
            Button("Logout", role: .destructive, action: {
                HapticFeedbackService.shared.success()
                auth.logOut()
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Do you want to log out as \(auth.username.orEmpty)?")
        })
        .task {
            await storyStore.fetchStories()
        }
        .onOpenURL(perform: { url in
            if let id = url.absoluteString.itemId {
                Task {
                    let story = await StoriesRepository.shared.fetchStory(id)
                    guard let story = story else { return }
                    router.to(story)
                }
            }
        })
        .environment(\.openURL, OpenURLAction { url in
            if let id = url.absoluteString.itemId {
                Task {
                    let item = await StoriesRepository.shared.fetchItem(id)
                    guard let item = item else {
                        Self.handledUrl = url
                        showUrlSheet = true
                        return
                    }
                    
                    router.to(item)
                }
                return .handled
            } else {
                Self.handledUrl = url
                showUrlSheet = true
                return .handled
            }
        })
    }
}
