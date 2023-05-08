import Foundation
import SwiftUI
import HackerNewsKit

extension ItemView {
    @MainActor
    class ItemStore : ObservableObject {
        @Published var kids = [Comment]()
        @Published var status: Status = .idle
        @Published var item: (any Item)?
        @Published var loadingItem: Int?
        @Published var loadedItems: Set<Int> = Set<Int>()
        
        func loadKids(of cmt: Comment) async {
            guard let parentIndex = kids.firstIndex(of: cmt) else { return }
            if let kids = cmt.kids, let level = cmt.level {
                self.loadingItem = cmt.id
                
                var comments = [Comment]()
                
                await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                    comments.append(comment.copyWith(level: level + 1))
                }
                
                withAnimation {
                    self.kids.insert(contentsOf: comments, at: parentIndex + 1)
                    self.loadingItem = nil
                    self.loadedItems.insert(cmt.id)
                }
            }
        }
        
        func refresh() async -> Void {
            if let id = self.item?.id {
                withAnimation {
                    self.loadingItem = nil
                    self.loadedItems = Set<Int>()
                    self.kids.removeAll()
                }
                self.status = .loading
                
                let item = await StoriesRepository.shared.fetchItem(id)
                
                if let item = item, let kids = item.kids {
                    self.item = item
                    
                    var comments = [Comment]()
                    
                    await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                        comments.append(comment.copyWith(level: 0))
                    }
                    
                    
                    withAnimation {
                        self.kids.append(contentsOf: comments)
                        self.status = .loaded
                    }
                } else {
                    withAnimation {
                        self.status = .loaded
                    }
                }
            }
        }
    }

}
