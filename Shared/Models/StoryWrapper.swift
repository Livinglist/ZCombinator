import Foundation
import SwiftData
import HackerNewsKit

@Model
class StoryWrapper {
    @Attribute(.unique) let id: Int
    let story: Story
    let storyType: StoryType
    
    init(_ story: Story, storyType: StoryType) {
        self.id = story.id
        self.story = story
        self.storyType = storyType
    }
}

@Model
class CommentWrapper {
    @Attribute(.unique) let id: Int
    let comment: Comment
    
    init(_ comment: Comment) {
        self.id = comment.id
        self.comment = comment
    }
}

