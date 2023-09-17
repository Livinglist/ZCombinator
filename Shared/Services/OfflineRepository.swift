import Alamofire
import Foundation
import SwiftUI
import SwiftData
import HackerNewsKit

/// 
/// For accessing cached stories and comments when the device is offline.
///

@MainActor
public class OfflineRepository: ObservableObject {
    @Published var isDownloading = false
    @Published var completionCount = 0
    
    private let storiesRepository = StoriesRepository.shared
    private let container = try! ModelContainer(for: StoryCollection.self, CommentWrapper.self)
    private var stories = [Story]()
    private var comments = [Int: [Comment]]()
    
    public static let shared: OfflineRepository = .init()
    
    private init() {
        let context = container.mainContext
        
        // Fetch all cached stories.
        var descriptor = FetchDescriptor<StoryCollection>()
        descriptor.fetchLimit = 1
        if let results = try? context.fetch(descriptor) {
            stories = results.first?.stories ?? [Story]()
        }
        
        // Fetch all cached comments.
        let cmtDescriptor = FetchDescriptor<CommentWrapper>()
        if let results = try? context.fetch(cmtDescriptor) {
            let allComments = results.map { $0.comment }
            
            for cmt in allComments {
                var existingCmts = comments[cmt.first?.parent ?? 0] ?? [Comment]()
                existingCmts.append(cmt.first!)
                comments[cmt.first?.parent ?? 0] = existingCmts
            }
        }
    }
    
    // MARK: - Story related.
    
    public func downloadAllStories(from storyType: StoryType) async -> Void {
        isDownloading = true
        
        try? container.mainContext.delete(model: StoryCollection.self)
        try? container.mainContext.delete(model: CommentWrapper.self)
        
        let context = container.mainContext
        var stories = [Story]()
        
        await storiesRepository.fetchAllStories(from: storyType) { story in
            stories.append(story)
        }
        
        context.insert(StoryCollection(stories, storyType: storyType))
        
        for story in stories {
            await downloadChildComments(of: story, level: 0)
            completionCount = completionCount + 1
        }
        
        isDownloading = false
    }
    
    private func downloadChildComments(of item: any Item, level: Int) async -> Void {
        let context = container.mainContext
        var comments = [Comment]()
        
        await storiesRepository.fetchComments(ids: item.kids ?? [Int](), onCommentFetched: { comment in
            context.insert(CommentWrapper(comment.copyWith(level: level)))
            comments.append(comment)
        })
        
        try? context.save()
        
        for comment in comments {
            await downloadChildComments(of: comment, level: level + 1)
        }
    }
    
    public func fetchAllStories(from storyType: StoryType) -> [Story] {
        return stories
    }
    
    public func fetchStoryIds(from storyType: StoryType) async -> [Int] {
        return [Int]()
    }
    
    public func fetchStoryIds(from storyType: String) async -> [Int] {
        return [Int]()
    }
    
    public func fetchStory(_ id: Int) async -> Story? {
        return nil
//        let context = container.mainContext
//        var descriptor = FetchDescriptor<StoryCollection>(
//            predicate: #Predicate { $0.id == id }
//        )
//        descriptor.fetchLimit = 1
//        if let results = try? context.fetch(descriptor) {
//            return results.first?.story
//        } else {
//            return nil
//        }
    }
    
    // MARK: - Comment related.
    
    public func fetchComments(of id: Int) -> [Comment] {
        return comments[id] ?? [Comment]()
    }
    
    public func fetchComment(_ id: Int) -> Comment? {
        let context = container.mainContext
        var descriptor = FetchDescriptor<CommentWrapper>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        if let results = try? context.fetch(descriptor) {
            return results.first?.comment.first!
        } else {
            return nil
        }
    }
}
