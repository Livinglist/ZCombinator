//
//  HNRepository.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation
import Alamofire

class StoriesRepository {
    static private let baseUrl: String = "https://hacker-news.firebaseio.com/v0/"
    
    public static func fetchStories(from storyType: StoryType, onStoryFetched: @escaping (Story) -> Void) async -> Void {
        let storyIds = await fetchStoryIds(from: storyType)

        for id in storyIds {
            let story = await self.fetchStory(id)
            if let story = story {
                onStoryFetched(story)
            }
        }
    }
    
    public static func fetchStoryIds(from storyType: StoryType) async -> [Int] {
        let response =  await AF.request("\(self.baseUrl)\(storyType.rawValue)stories.json").serializingString().response
        let storyIds = try? JSONDecoder().decode([Int].self, from: response.data!)
        return storyIds ?? [Int]()
    }
    
    public static func fetchStories(ids: [Int], onStoryFetched: @escaping (Story) -> Void) async -> Void {
        for id in ids {
            let story = await fetchStory(id)
            if let story = story {
                onStoryFetched(story)
            }
        }
    }
    
    public static func fetchStory(_ id: Int) async -> Story?{
        let response = await AF.request("\(self.baseUrl)item/\(id).json").serializingString().response
        
        if let data = response.data {
            let story = try? JSONDecoder().decode(Story.self, from: data)
            return story
        } else {
            return nil
        }
        
    }
}
