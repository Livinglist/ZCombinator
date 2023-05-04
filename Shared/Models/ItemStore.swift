import Foundation
import SwiftUI
import HackerNewsKit

extension ItemView {
    @MainActor
    class ItemStore : ObservableObject {
        @Published var kids = [Comment]()
        @Published var status: Status = .idle
        @Published var item: (any Item)?
        
        func loadKids() async {
            if let kids = self.item?.kids {
                self.status = .loading
                
                var comments = [Comment]()
                
                await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                    comments.append(comment)
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
        
        func refresh() async -> Void {
            if let id = self.item?.id {
                withAnimation {
                    self.kids.removeAll()
                }
                self.status = .loading

                let item = await StoriesRepository.shared.fetchItem(id)
                
                if let item = item {
                    self.item = item
                    await loadKids()
                }
            }
        }
    }
}
