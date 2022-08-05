//
//  ItemView+ViewModel.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation
import SwiftUI

extension ItemView {
    @MainActor
    class ItemViewModel<T: ItemProtocol> : ObservableObject {
        @Published var kids: [Comment] = [Comment]()
        @Published var loaded: Bool = false
        @Published var status: Status = .idle
        
        @Published var item: T? {
            didSet {
                print("did set \(self.item?.title ?? "")")
                if item is Story {
                    Task {
                        await loadKids()
                    }
                }
            }
        }
        
        
        func loadKids() async {
            if let kids = self.item?.kids, self.status != .loading && self.status != .loaded {
                self.status = .loading
                
                var comments: [Comment] = [Comment]()
                
                await StoriesRepository.shared.fetchComments(ids: kids) { comment in
                    DispatchQueue.main.async {
                        print("new comments \(self.kids.count)")
                        
                        comments.append(comment)
                    }
                }
                
                withAnimation {
                    self.kids.append(contentsOf: comments)
                    self.status = .loaded
                }
            }
        }
    }
}
