import Foundation
import SwiftData
import HackerNewsKit

@Model
class CommentWrapper {
    @Attribute(.unique) let id: Int
    let comment: Comment
    
    init(_ comment: Comment) {
        self.id = comment.id
        self.comment = comment
    }
}
