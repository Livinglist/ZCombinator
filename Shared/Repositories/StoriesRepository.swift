import Foundation
import Alamofire

class StoriesRepository {
    static let shared: StoriesRepository = StoriesRepository()
    
    private let baseUrl: String = "https://hacker-news.firebaseio.com/v0/"
    
    private init() {}
    
    // MARK: - Stories related.
    
    public func fetchStories(from storyType: StoryType, onStoryFetched: @escaping (Story) -> Void) async -> Void {
        let storyIds = await fetchStoryIds(from: storyType)
        
        for id in storyIds {
            let story = await self.fetchStory(id)
            if let story = story {
                onStoryFetched(story)
            }
        }
    }
    
    public func fetchStoryIds(from storyType: StoryType) async -> [Int] {
        let response =  await AF.request("\(self.baseUrl)\(storyType.rawValue)stories.json").serializingString().response
        guard response.data != nil else { return [Int]() }
        let storyIds = try? JSONDecoder().decode([Int].self, from: response.data!)
        return storyIds ?? [Int]()
    }
    
    public func fetchStories(ids: [Int], filtered: Bool = true, onStoryFetched: @escaping (Story) -> Void) async -> Void {
        for id in ids {
            let story = await fetchStory(id)
            if var story = story {
                if filtered {
                    let filteredText = story.text.htmlStripped.withExtraLineBreak
                    story = story.copyWith(text: filteredText)
                }
                onStoryFetched(story)
            }
        }
    }
    
    public func fetchStory(_ id: Int) async -> Story?{
        let response = await AF.request("\(self.baseUrl)item/\(id).json").serializingString().response

        if let data = response.data {
            let story = try? JSONDecoder().decode(Story.self, from: data)
            
            return story
        } else {
            return nil
        }
    }
    
    // MARK: - Comments related.
    
    public func fetchComments(ids: [Int], filtered: Bool = true, onCommentFetched: @escaping (Comment) -> Void) async -> Void {
        for id in ids {
            let comment = await fetchComment(id)

            if var comment = comment {
                if filtered {
                    let filteredText = comment.text.htmlStripped.withExtraLineBreak
                    comment = comment.copyWith(text: filteredText)
                }
                onCommentFetched(comment)
            }
        }
    }
    
    public func fetchComment(_ id: Int) async -> Comment?{
        let response = await AF.request("\(self.baseUrl)item/\(id).json").serializingString().response
        
        if let data = response.data {
            let comment = try? JSONDecoder().decode(Comment.self, from: data)
            return comment
        } else {
            return nil
        }
        
    }
    
    public func fetchItem(_ id: Int) async -> (any Item)? {
        let response = await AF.request("\(self.baseUrl)item/\(id).json").serializingString().response

        if let data = response.data, let result = try? response.result.get(), let map = result.toJSON() as? [String: AnyObject] {
            guard let type = map["type"] as? String else { return nil }
            
            switch type {
            case "story":
                let story = try? JSONDecoder().decode(Story.self, from: data)
                return story
            case "comment":
                let comment = try? JSONDecoder().decode(Comment.self, from: data)
                return comment
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}
