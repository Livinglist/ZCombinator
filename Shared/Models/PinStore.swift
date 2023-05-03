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
                if status == .idle {
                    Task {
                        await fetchPinnedStories()
                    }
                } else if pinnedIds.count > oldValue.count {
                    let newIds = pinnedIds.filter { id in
                        oldValue.contains(id) == false
                    }
                    
                    Task{
                        await fetchNewlyPinnedStories(ids: newIds)
                    }
                } else if pinnedIds.count < oldValue.count {
                    let oldIds = oldValue.filter { id in
                        pinnedIds.contains(id) == false
                    }
                    
                    removeUnpinnedStories(ids: oldIds)
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
                self.status = .loaded
                self.pinnedItems = items
            }
        }
        
        func fetchNewlyPinnedStories(ids: [Int]) async {
            var items = [any Item]()
            
            await StoriesRepository.shared.fetchItems(ids: pinnedIds) { item in
                items.append(item)
            }
            
            withAnimation {
                self.pinnedItems.append(contentsOf: items)
            }
        }
        
        func removeUnpinnedStories(ids: [Int]) {
            withAnimation {
                self.pinnedItems.removeAll { item in
                    ids.contains(item.id)
                }
            }
        }
    }
}
