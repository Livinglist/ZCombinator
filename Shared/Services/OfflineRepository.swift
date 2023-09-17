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
    lazy var lastFetchedAt = {
        guard let date = UserDefaults.standard.object(forKey: lastDownloadAtKey) as? Date else { return "" }
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy HH:mm"
        return df.string(from: date)
    }()
    
    private let storiesRepository = StoriesRepository.shared
    private let container = try! ModelContainer(for: StoryCollection.self, CommentCollection.self)
    private let downloadOrder = [StoryType.top, .ask, .best]
    private let lastDownloadAtKey = "lastDownloadedAt"
    private var stories = [StoryType: [Story]]()
    private var comments = [Int: [Comment]]()
    
    public static let shared: OfflineRepository = .init()
    
    private init() {
        let context = container.mainContext
        
        // Fetch all cached stories.
        var descriptor = FetchDescriptor<StoryCollection>()
        descriptor.fetchLimit = downloadOrder.count
        if let results = try? context.fetch(descriptor) {
            for res in results {
                stories[res.storyType] = res.stories
            }
        }
        
        // Fetch all cached comments.
        let cmtDescriptor = FetchDescriptor<CommentCollection>()
        if let results = try? context.fetch(cmtDescriptor) {
            for collection in results {
                comments[collection.parentId] = collection.comments
            }
        }
    }
    
    // MARK: - Story related.
    
    public func downloadAllStories() async -> Void {
        isDownloading = true
        
        UserDefaults.standard.set(Date.now, forKey: lastDownloadAtKey)
        
        let context = container.mainContext
        var completedStoryId = Set<Int>()
        
        try? context.delete(model: StoryCollection.self)
        try? context.delete(model: CommentCollection.self)
        
        for storyType in downloadOrder {
            var stories = [Story]()
            
            await storiesRepository.fetchAllStories(from: storyType) { story in
                stories.append(story)
            }
            
            context.insert(StoryCollection(stories, storyType: storyType))
            
            // Fetch comments for each story.
            for story in stories {
                // Skip already completed stories to prevent fetching for duplicate comments.
                if completedStoryId.contains(story.id) { continue }
                await downloadChildComments(of: story, level: 0)
                
                // Update counter for UI.
                completionCount = completionCount + 1
                completedStoryId.insert(story.id)
            }
        }
        
        isDownloading = false
    }
    
    private func downloadChildComments(of item: any Item, level: Int) async -> Void {
        let context = container.mainContext
        var comments = [Comment]()
        
        await storiesRepository.fetchComments(ids: item.kids ?? [Int](), onCommentFetched: { comment in
            comments.append(comment.copyWith(level: level))
        })
        
        context.insert(CommentCollection(comments, parentId: item.id))
        try? context.save()
        
        for comment in comments {
            await downloadChildComments(of: comment, level: level + 1)
        }
    }
    
    public func fetchAllStories(from storyType: StoryType) -> [Story] {
        guard let stories = stories[storyType] else { return [Story]() }
        let storiesWithCommentsDownloaded = stories.filter { story in
            comments[story.id].isNotNullOrEmpty
        }
        return storiesWithCommentsDownloaded
    }
    
    // MARK: - Comment related.
    
    public func fetchComments(of id: Int) -> [Comment] {
        return comments[id] ?? [Comment]()
    }
}
