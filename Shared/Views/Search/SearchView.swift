import Foundation
import SwiftUI
import Combine
import HackerNewsKit

struct SearchView: View {
    @StateObject private var searchStore = SearchStore()
    @StateObject private var debounceObject = DebounceObject()
    @State private var actionPerformed: Action = .none
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var useDateRange: Bool = Bool()
    
    var body: some View {
        List {
            HStack {
                Chip(selected: searchStore.params.sorted, label: "sorted") {
                    searchStore.onSortTap()
                }
                Chip(selected: searchStore.contains(.comment), label: "comment") {
                    searchStore.onTap(filter: .comment)
                }
                Chip(selected: searchStore.contains(.story), label: "story") {
                    searchStore.onTap(filter: .story)
                }
                Chip(selected: useDateRange, label: "date") {
                    useDateRange.toggle()
                }
            }
            .listRowSeparator(.hidden)
            if useDateRange {
                HStack {
                    Text("from")
                    DatePicker(selection: $startDate, in: ...Date(), displayedComponents: [.date]) {
                        EmptyView()
                    }
                    Text("to")
                    DatePicker(selection: $endDate, in: ...Date(), displayedComponents: [.date]) {
                        EmptyView()
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
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
                await searchStore.search(query: text)
            }
        }.onChange(of: searchStore.params) { filter in
            if debounceObject.debouncedText.isEmpty { return }
            Task {
                await searchStore.search(query: debounceObject.debouncedText)
            }
        }
    }
}
