import AlertToast
import Foundation
import SwiftUI
import Combine
import HackerNewsKit

public final class DebounceObject: ObservableObject {
    @Published var text: String = String()
    @Published var debouncedText: String = String()
    private var bag = Set<AnyCancellable>()
    
    public init(dueTime: TimeInterval = 1) {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.debouncedText = value
            })
            .store(in: &bag)
    }
}


struct SearchView: View {
    @ObservedObject var searchStore = SearchStore()
    @StateObject var debounceObject = DebounceObject()
    @State private var showFlagToast: Bool = Bool()
    @State private var showUpvoteToast: Bool = Bool()
    @State private var showDownvoteToast: Bool = Bool()
    @State private var showFavoriteToast: Bool = Bool()
    @State private var showUnfavoriteToast: Bool = Bool()
    
    var body: some View {
        List {
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
            }.id(UUID())
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
            Task {
                await searchStore.search(query: text)
            }
        }
    }
}
