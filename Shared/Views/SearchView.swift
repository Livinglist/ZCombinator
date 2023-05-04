import AlertToast
import Foundation
import SwiftUI
import Combine
import HackerNewsKit

struct SearchView: View {
    @StateObject var searchStore = SearchStore()
    @StateObject var debounceObject = DebounceObject()
    @State private var showFlagToast = Bool()
    @State private var showUpvoteToast = Bool()
    @State private var showDownvoteToast = Bool()
    @State private var showFavoriteToast = Bool()
    @State private var showUnfavoriteToast = Bool()
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
                ItemRow(item: item,
                        showFlagToast: $showFlagToast,
                        showUpvoteToast: $showUpvoteToast,
                        showDownvoteToast: $showDownvoteToast,
                        showFavoriteToast: $showFavoriteToast,
                        showUnfavoriteToast: $showUnfavoriteToast)
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowSeparator(.hidden)
                .onAppear {
                    searchStore.onItemRowAppear(item)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .searchable(text: $debounceObject.text, placement: .navigationBarDrawer(displayMode: .always))
        .toast(isPresenting: $showFlagToast) {
            AlertToast(type: .systemImage("flag.fill", .gray), title: "Flagged")
        }
        .toast(isPresenting: $showUpvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsup.fill", .gray), title: "Upvoted")
        }
        .toast(isPresenting: $showDownvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsdown.fill", .gray), title: "Downvoted")
        }
        .toast(isPresenting: $showUnfavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.slash", .gray), title: "Removed")
        })
        .toast(isPresenting: $showFavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.fill", .gray), title: "Added")
        })
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
