//
//  ContentView.swift
//  Shared
//
//  Created by Jiaqi Feng on 7/18/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject private var vm = HomeViewModel()
    @State private var showLoginDialog: Bool = false
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    @State private var showAboutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.stories){ story in
                    StoryRow(story: story)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowSeparator(.hidden)
                        .onAppear {
                            vm.onStoryRowAppear(story)
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                vm.refresh()
            }
            .toolbar {
                ToolbarItem{
                    Menu {
                        ForEach(StoryType.allCases, id: \.self) { storyType in
                            Button {
                                vm.storyType = storyType
                                
                                Task {
                                    await vm.fetchStories()
                                }
                            } label: {
                                Label("\(storyType.rawValue.uppercased())", systemImage: storyType.iconName)
                            }
                        }
                        Button {
                            showLoginDialog = true
                        } label: {
                            Label("Log In", systemImage: "")
                        }
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
            .navigationTitle(vm.storyType.rawValue.uppercased())
            Text("Select a story")
        }
        .alert("Login", isPresented: $showLoginDialog, actions: {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Login", action: {})
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter your username and password.")
        })
        .task {
            await vm.fetchStories()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
