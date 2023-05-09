import Foundation
import SwiftUI
import Combine
import HackerNewsKit

struct SearchView: View {
    @StateObject var searchStore = SearchStore()
    @StateObject var debounceObject = DebounceObject()
    @State private var actionPerformed: Action = .none
    @State private var filter: Filter = .story
    
    var body: some View {
        List {
            Picker("Type", selection: $filter) {
                ForEach(Filter.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
            ForEach(searchStore.results, id: \.self.id) { item in
                ItemRow(item: item, actionPerformed: $actionPerformed)
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowSeparator(.hidden)
                .onAppear {
                    searchStore.onItemRowAppear(item)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $debounceObject.text, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Hacker News")
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search")
        .withToast(actionPerformed: $actionPerformed)
        .onChange(of: debounceObject.debouncedText) { text in
            if text.isEmpty { return }
            Task {
                await searchStore.search(query: text, filter: filter)
            }
        }.onChange(of: filter) { filter in
            if debounceObject.debouncedText.isEmpty { return }
            Task {
                await searchStore.search(query: debounceObject.debouncedText, filter: filter)
            }
        }
    }
}
