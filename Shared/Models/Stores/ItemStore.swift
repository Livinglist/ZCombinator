import Foundation
import SwiftUI
import HackerNewsKit

extension ItemView {
    @MainActor
    class ItemStore : ObservableObject {
        @Published var kids: [Comment] = .init()
        @Published var status: Status = .idle
        @Published var item: (any Item)?
        @Published var loadingItem: Int?
        @Published var loadedItems: Set<Int> = .init()
        @Published var collapsed: Set<Int> = .init()
        @Published var hidden: Set<Int> = .init()
        
        func loadKids(of cmt: Comment) async {
            if let parentIndex = kids.firstIndex(of: cmt),
               let kids = cmt.kids,
               let level = cmt.level,
               loadingItem == nil {
                self.loadingItem = cmt.id
                
                var comments = [Comment]()
                
                await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                    comments.append(comment.copyWith(level: level + 1))
                }
                
                self.loadedItems.insert(cmt.id)
                withAnimation {
                    self.kids.insert(contentsOf: comments, at: parentIndex + 1)
                }
                self.loadingItem = nil
            }
        }
        
        func refresh() async -> Void {
            if status.isLoading { return }
            
            if let id = self.item?.id {
                withAnimation {
                    self.kids.removeAll()
                }
                self.loadingItem = nil
                self.loadedItems.removeAll()
                self.collapsed.removeAll()
                self.hidden.removeAll()
                self.status = .loading
                
                if let item = await StoriesRepository.shared.fetchItem(id),
                   let kids = item.kids {
                    self.item = item
                    
                    await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.status = .backgroundLoading
                                self.kids.append(comment.copyWith(level: 0))
                            }
                        }
                    }
                }
                
                self.status = .loaded
            }
        }
        
        func fetchParent(of cmt: Comment) async {
            guard let parentId = cmt.parent,
                  let parent = await StoriesRepository.shared.fetchItem(parentId)
            else { return }
            
            Router.shared.to(parent)
        }
        
        func collapse(cmt: Comment) {
            collapsed.insert(cmt.id)
            
            hide(kidsOf: cmt)
        }
        
        func uncollapse(cmt: Comment) {
            collapsed.remove(cmt.id)
            
            unhide(kidsOf: cmt)
        }
        
        func hide(kidsOf parent: Comment) {
            guard let kids = parent.kids else { return }
            
            for childId in kids {
                let child = self.kids.first { $0.id == childId }
                guard let child = child else {
                    continue
                }
                hidden.insert(childId)
                hide(kidsOf: child)
            }
        }
        
        func unhide(kidsOf parent: Comment) {
            guard let kids = parent.kids else { return }
            
            for childId in kids {
                let child = self.kids.first { $0.id == childId }
                guard let child = child else {
                    continue
                }
                
                hidden.remove(childId)
                if collapsed.contains(childId) == false {
                    unhide(kidsOf: child)
                }
            }
        }
    }
}
