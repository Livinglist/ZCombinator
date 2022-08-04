//
//  Comment.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/28/22.
//

import Foundation

struct Comment : ItemProtocol {
    let id: Int
    let title: String?
    let text: String?
    let url: String?
    let by: String
    let score: Int?
    let descendants: Int?
    let time: Int
    let kids: [Int]?
    
    init(id: Int, title: String?, text: String?, url: String?, by: String, score: Int?, descendants: Int, time: Int, kids: [Int] = [Int]()) {
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
}
