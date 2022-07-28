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
    let time: Int
    
    init(id: Int, title: String?, text: String?, url: String?, by: String, score: Int?, time: Int) {
        self.id = id
        self.title = title
        self.text = text
        self.url = url
        self.score = score
        self.by = by
        self.time = time
    }
    
    // Empty initializer
    init() {
        self.init(id: 0, title: "", text: "", url: "", by: "", score: 0, time: 0)
    }
}
