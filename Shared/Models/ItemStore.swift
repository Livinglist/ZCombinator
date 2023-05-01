import Foundation
import SwiftUI

extension ItemView {
    @MainActor
    class ItemStore<T: Item> : ObservableObject {
        @Published var kids: [Comment] = [Comment]()
        @Published var status: Status = .idle
        
        @Published var item: (any Item)? {
            didSet {
                if item is Story {
                    Task {
                        await loadKids()
                    }
                }
            }
        }
        
        func loadKids() async {
            if let kids = self.item?.kids {
                self.status = .loading
                
                var comments: [Comment] = [Comment]()
                
                await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                    comments.append(comment)
                }
                
                withAnimation {
                    self.kids.append(contentsOf: comments)
                    self.status = .loaded
                }
            }
        }
        
        func refresh() {
            self.kids.removeAll()
            if let id = self.item?.id, item is Story {
                self.status = .loading
                Task {
                    let item = await StoriesRepository.shared.fetchItem(id)

                    if let item = item {
                        self.item = item
                    }
                }
            }
        }
    }
}
