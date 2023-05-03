import Foundation
import SwiftUI
import Combine
import HackerNewsKit

extension PinView {
    @MainActor
    class PinStore: ObservableObject {
        @Published var pinnedItems: [any Item] = [any Item]()
        @Published var status: Status = .idle
        private let settings = Settings.shared
        private(set) var pinnedIds: [Int] = [Int]() {
            didSet {
                Task {
                    await fetchPinnedStories()
                }
            }
        }
        private var pinListCancellable: AnyCancellable?
        
        init() {
            pinListCancellable = settings.$pinList.sink(receiveValue: { ids in
                self.pinnedIds = Array<Int>(ids)
            })
        }
        
        func fetchPinnedStories() async {
            var items = [any Item]()
            
            await StoriesRepository.shared.fetchItems(ids: pinnedIds) { item in
                items.append(item)
            }
            
            withAnimation {
                self.pinnedItems = items
            }
        }
    }
}
