//
//  ContentView.swift
//  Shared
//
//  Created by Jiaqi Feng on 7/18/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject private var storyStore = StoryStore()
    
    @State private var showLoginDialog: Bool = false
    @State private var showLogoutDialog: Bool = false
    @State private var showAboutSheet: Bool = false
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject private var auth: Authentication
    
    var body: some View {
        NavigationView {
            List {
                ForEach(storyStore.stories){ story in
                    StoryRow(story: story)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowSeparator(.hidden)
                        .onAppear {
                            storyStore.onStoryRowAppear(story)
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                storyStore.refresh()
            }
            .toolbar {
                ToolbarItem{
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
                    }
                }
            }
            .navigationTitle(storyStore.storyType.rawValue.uppercased())
            Text("Select a story")
        }
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
                    return
                }
                
                auth.logIn(username: username, password: password)
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter your username and password.")
        })
        .alert("Logout", isPresented: $showLogoutDialog, actions: {
            Button("Logout", role: .destructive, action: auth.logOut)
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Do you want to log out as \(auth.username.orEmpty)?")
        })
        .task {
            await storyStore.fetchStories()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
