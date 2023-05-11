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
        @Published var loadedItems = Set<Int>()
        @Published var collapsed = Set<Int>()
        @Published var hidden = Set<Int>()
        
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
        
        func fetchParent(of cmt: Comment) async {
            guard let parentId = cmt.parent,
                  let parent = await StoriesRepository.shared.fetchItem(parentId)
            else { return }
            
            Router.shared.to(parent)
        }
        
        func collapse(cmt: Comment) {
            collapsed.insert(cmt.id)
            
            hide(cmt: cmt)
        }
        
        func uncollapse(cmt: Comment) {
            collapsed.remove(cmt.id)
            
            unhide(cmt: cmt)
        }
        
        func hide(cmt: Comment) {
            guard let kids = cmt.kids else { return }
            
            for childId in kids {
                let child = self.kids.first { $0.id == childId }
                guard let child = child else {
                    continue
                }
                hidden.insert(childId)
                hide(cmt: child)
            }
        }
        
        func unhide(cmt: Comment) {
            guard let kids = cmt.kids else { return }
            
            for childId in kids {
                let child = self.kids.first { $0.id == childId }
                guard let child = child else {
                    continue
                }
                
                hidden.remove(childId)
                if collapsed.contains(childId) == false {
                    unhide(cmt: child)
                }
            }
        }
    }
}
