//
//  ContentView.swift
//  Shared
//
//  Created by Jiaqi Feng on 7/18/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var isActive = false
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.stories){ story in
                    ZStack {
                        StoryRow(story: story).listRowInsets(EdgeInsets()).onAppear {
                            viewModel.onStoryRowAppear(story)
                        }
                        NavigationLink(destination: ItemView<Story>(item: story), isActive: $isActive) {
                            EmptyView()
                        }.hidden()
                    }.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            isActive = true
                        } label: {
                            Label("Flag", systemImage: "flag")
                        }
                    }.listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem{
                    Menu {
                        ForEach(StoryType.allCases, id: \.self) { storyType in
                            Button {
                                viewModel.storyType = storyType
                                
                                Task {
                                    await viewModel.fetchStories()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: storyType.iconName)
                                    Text("\(storyType.rawValue.uppercased())")
                                }
                            }
                        }
                    } label: {
                        Label("Add Item", systemImage: "list.bullet")
                    }
                }
            }
            .navigationTitle(viewModel.storyType.rawValue.uppercased())
            Text("Select an item")
        }.task {
            await viewModel.fetchStories()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
