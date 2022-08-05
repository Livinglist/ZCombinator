//
//  Story.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation

struct Story : ItemProtocol {
    let id: Int
    let title: String?
    let text: String?
    let url: String?
    let by: String
    let score: Int?
    let descendants: Int?
    let time: Int
    let kids: [Int]?
    
    init(id: Int, title: String?, text: String?, url: String?, by: String, score: Int?, descendants: Int?, time: Int, kids: [Int] = [Int]()) {
        self.id = id
        self.title = title
        self.text = text
        self.url = url
        self.score = score
        self.by = by
        self.descendants = descendants
        self.time = time
        self.kids = kids
    }
    
    // Empty initializer
    init() {
        self.init(id: 0, title: "", text: "", url: "", by: "", score: 0, descendants: 0, time: 0)
    }
    
    func copyWith(text: String?) -> Story{
        Story(id: id, title: title, text: text, url: url, by: by, score: score, descendants: descendants, time: time, kids: kids ?? [Int]())
    }
}
