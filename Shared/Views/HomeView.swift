import SwiftUI
import CoreData
import HackerNewsKit

struct HomeView: View {
    @EnvironmentObject private var auth: Authentication
    @StateObject private var storyStore: StoryStore = .init()
    @ObservedObject private var settings: Settings = .shared
    @ObservedObject private var router: Router = .shared
    
    @State private var showLoginDialog: Bool = .init()
    @State private var showLogoutDialog: Bool = .init()
    @State private var showAboutSheet: Bool = .init()
    @State private var showUrlSheet: Bool = .init()
    
    @State private var username: String = .init()
    @State private var password: String = .init()

    @State private var actionPerformed: Action = .none
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    private static var handledUrl: URL? = nil
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            mainView
        } else {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                mainView
            } detail: {
                NavigationStack(path: $router.path) {
                    Text("Tap on a story to its comments")
                        .navigationDestination(for: Comment.self) { cmt in
                            ItemView(item: cmt, level: 0)
                        }
                        .navigationDestination(for: Story.self) { story in
                            ItemView(item: story, level: 0)
                        }
                        .navigationDestination(for: Destination.self) { val in
                            val.toView()
                        }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    var storyList: some View {
        List {
            Button {
                Router.shared.to(.pin)
            } label: {
                Label("Pins", systemImage: "pin")
            }
            .listRowSeparator(.hidden)
            
            if storyStore.status.isLoading {
                HStack {
                    Spacer()
                    LoadingIndicator().frame(height: 200)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else {
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
        }
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
                            Label("\(storyType.label.capitalized)", systemImage: storyType.iconName)
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
        .navigationTitle(storyStore.storyType.label.uppercased())
    }
    
    @ViewBuilder
    var mainView: some View {
        storyList
            .if(UIDevice.current.userInterfaceIdiom == .phone) { view in
                view
                    .navigationDestination(for: Comment.self) { cmt in
                        ItemView(item: cmt, level: 0)
                    }
                    .navigationDestination(for: Story.self) { story in
                        ItemView(item: story, level: 0)
                    }
                    .navigationDestination(for: Destination.self) { val in val.toView() }
            }
            .if(UIDevice.current.userInterfaceIdiom == .phone) { view in
                NavigationStack(path: $router.path) {
                    view
                }
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
