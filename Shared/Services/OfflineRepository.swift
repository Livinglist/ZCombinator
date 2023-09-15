import Alamofire
import Foundation
import SwiftUI
import SwiftData
import HackerNewsKit

/// 
/// For accessing cached stories and comments when the device is offline.
///

@MainActor
public class OfflineRepository {
    public static let shared: OfflineRepository = .init()
    
    private let baseUrl: String = "https://hacker-news.firebaseio.com/v0/"
    
    private init() {}
    
    let storiesRepository = StoriesRepository.shared
    let container = try! ModelContainer(for: StoryWrapper.self, CommentWrapper.self)
    
    // MARK: - Story related.
    
    public func downloadAllStories(from storyType: StoryType) async -> Void {
        try? container.mainContext.delete(model: StoryWrapper.self)
        try? container.mainContext.delete(model: CommentWrapper.self)
        
        let context = container.mainContext
        var stories = [Story]()
        
        await storiesRepository.fetchAllStories(from: storyType) { story in
            context.insert(StoryWrapper(story, storyType: storyType))
            stories.append(story)
        }
        
        for story in stories {
            await downloadChildComments(of: story)
        }
    }
    
    private func downloadChildComments(of item: any Item) async -> Void {
        let context = container.mainContext
        var comments = [Comment]()
        
        await storiesRepository.fetchComments(ids: item.kids ?? [Int](), onCommentFetched: { comment in
            context.insert(CommentWrapper(comment))
            comments.append(comment)
        })
        
        try? context.save()
        for comment in comments {
            await downloadChildComments(of: comment)
        }
    }
    
    public func fetchAllStories(from storyType: StoryType) -> [Story] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<StoryWrapper>(
            predicate: #Predicate { $0.storyType == storyType }
        )
        if let stories = try? context.fetch(descriptor) {
            return stories.map { $0.story }
        } else {
            return [Story]()
        }
    }
    
    public func fetchStoryIds(from storyType: StoryType) async -> [Int] {
        return [Int]()
    }
    
    public func fetchStoryIds(from storyType: String) async -> [Int] {
        return [Int]()
    }
    
    public func fetchStory(_ id: Int) async -> Story? {
        let context = container.mainContext
        var descriptor = FetchDescriptor<StoryWrapper>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        if let results = try? context.fetch(descriptor) {
            return results.first?.story
        } else {
            return nil
        }
    }
    
    // MARK: - Comment related.
    
    public func fetchComments(ids: [Int]) -> [Comment] {
        let context = container.mainContext
        var descriptor = FetchDescriptor<CommentWrapper>(
            predicate: #Predicate { comment in ids.contains { $0 == comment.id } }
        )
        if let results = try? context.fetch(descriptor) {
            return results.map { $0.comment }
        } else {
            return [Comment]()
        }
    }
    
    public func fetchComment(_ id: Int) -> Comment? {
        let context = container.mainContext
        var descriptor = FetchDescriptor<CommentWrapper>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        if let results = try? context.fetch(descriptor) {
            return results.first?.comment
        } else {
            return nil
        }
    }
}
