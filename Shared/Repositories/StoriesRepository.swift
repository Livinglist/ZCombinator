//
//  StoriesRepository.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation
import Alamofire

class StoriesRepository {
    static let shared: StoriesRepository = StoriesRepository()
    
    private let baseUrl: String = "https://hacker-news.firebaseio.com/v0/"
    
    // MARK: - Functions for fetching stories.
    
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
    
    // MARK: - Functions for fetching comments.
    
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
            print("fetched \(data) \("\(self.baseUrl)item/\(id).json")")
            let comment = try? JSONDecoder().decode(Comment.self, from: data)
            return comment
        } else {
            print("data is nil for \(id)")
            return nil
        }
        
    }
}
