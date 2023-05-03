import AlertToast
import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject private var auth: Authentication
    @EnvironmentObject private var settingsStore: SettingsStore
    @ObservedObject private var storyStore = StoryStore()
    
    @State private var showLoginDialog: Bool = Bool()
    @State private var showLogoutDialog: Bool = Bool()
    @State private var showAboutSheet: Bool = Bool()
    
    @State private var username: String = String()
    @State private var password: String = String()
    @State private var shouldRememberMe: Bool = Bool()
    
    @State private var showFlagToast: Bool = Bool()
    @State private var showUpvoteToast: Bool = Bool()
    @State private var showDownvoteToast: Bool = Bool()
    @State private var showLoginToast: Bool = Bool()
    @State private var showFavoriteToast: Bool = Bool()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(storyStore.pinnedStories) { story in
                    StoryRow(story: story,
                             isPinnedStory: true,
                             showFlagToast: $showFlagToast,
                             showUpvoteToast: $showUpvoteToast,
                             showDownvoteToast: $showDownvoteToast,
                             showFavoriteToast: $showFavoriteToast)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .listRowSeparator(.hidden)
                    .onAppear {
                        storyStore.onStoryRowAppear(story)
                    }
                }
                ForEach(storyStore.stories) { story in
                    if storyStore.pinnedStories.contains(story) {
                        EmptyView()
                    } else {
                        StoryRow(story: story,
                                 showFlagToast: $showFlagToast,
                                 showUpvoteToast: $showUpvoteToast,
                                 showDownvoteToast: $showDownvoteToast,
                                 showFavoriteToast: $showFavoriteToast)
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
                        
                    } label: {
                         Text("Fav")
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
            Text("Select a story")
        }
        .tint(.orange)
        .toast(isPresenting: $showFlagToast) {
            AlertToast(type: .systemImage("flag.fill", .gray), title: "Flagged")
        }
        .toast(isPresenting: $showUpvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsup.fill", .gray), title: "Upvoted")
        }
        .toast(isPresenting: $showDownvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsdown.fill", .gray), title: "Downvoted")
        }
        .toast(isPresenting: $showLoginToast, alert: {
            AlertToast(type: .systemImage("person.badge.shield.checkmark.fill", .gray), title: "Welcome")
        })
        .toast(isPresenting: $showFavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.fill", .gray), title: "Added")
        })
        .sheet(isPresented: $showAboutSheet, content: {
            SafariView(url: Constants.githubUrl)
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
                        showLoginToast = true
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
        .onAppear {
            storyStore.settingsStore = settingsStore
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
