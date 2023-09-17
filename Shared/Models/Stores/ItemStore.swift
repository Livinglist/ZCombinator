import Foundation
import Combine
import SwiftUI
import HackerNewsKit

extension ItemView {
    @MainActor
    class ItemStore : ObservableObject {
        @Published var comments: [Comment] = .init()
        @Published var status: Status = .idle
        @Published var item: (any Item)?
        @Published var loadingItemId: Int?
        
        /// Stores ids of loaded comments, including both root and child comments.
        @Published var loadedCommentIds: Set<Int> = .init()
        @Published var collapsed: Set<Int> = .init()
        @Published var hidden: Set<Int> = .init()
        @Published var isConnectedToNetwork: Bool = true
        
        private var cancellable: AnyCancellable?
        
        init() {
            cancellable = NetworkMonitor.shared.networkStatus.sink { isConnected in
                self.isConnectedToNetwork = isConnected
            }
        }
        
        /// Load child comments of a comment.
        func loadKids(of cmt: Comment) async {
            if let parentIndex = comments.firstIndex(of: cmt),
               let kids = cmt.kids,
               let level = cmt.level,
               loadingItemId == nil {
                self.loadingItemId = cmt.id
                
                var comments = [Comment]()
                
                if isConnectedToNetwork {
                    await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                        comments.append(comment.copyWith(level: level + 1))
                    }
                } else if let id = loadingItemId {
                    comments = OfflineRepository.shared.fetchComments(of: id)
                }
                
                withAnimation {
                    self.loadingItemId = nil
                    self.loadedCommentIds.insert(cmt.id)
                    self.comments.insert(contentsOf: comments, at: parentIndex + 1)
                }
            }
        }
        
        func refresh() async -> Void {
            guard let id = self.item?.id else { return }
            
            if status.isLoading { return }
            
            withAnimation {
                self.comments.removeAll()
            }
            self.loadingItemId = nil
            self.loadedCommentIds.removeAll()
            self.collapsed.removeAll()
            self.hidden.removeAll()
            self.status = .inProgress
            
            if isConnectedToNetwork {
                if let item = await StoriesRepository.shared.fetchItem(id),
                   let kids = item.kids {
                    self.item = item
                    
                    await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.status = .backgroundLoading
                                self.comments.append(comment.copyWith(level: 0))
                            }
                        }
                    }
                }
            } else {
                // We don't need to refresh in offline mode
                if !self.comments.isEmpty { self.status = .completed }
                let cmts = OfflineRepository.shared.fetchComments(of: id)
                self.comments = cmts
            }
            
            self.status = .completed
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
        
        private func hide(kidsOf parent: Comment) {
            guard let kids = parent.kids else { return }
            
            for childId in kids {
                let child = self.comments.first { $0.id == childId }
                guard let child = child else {
                    continue
                }
                hidden.insert(childId)
                hide(kidsOf: child)
            }
        }
        
        private func unhide(kidsOf parent: Comment) {
            guard let kids = parent.kids else { return }
            
            for childId in kids {
                let child = self.comments.first { $0.id == childId }
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
