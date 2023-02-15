//
//  Item.swift
//  ZCombinator (iOS)
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation

protocol Item: Codable, Identifiable, Hashable {
    var id: Int { get }
    var title: String? { get }
    var text: String? { get }
    var url: String? { get }
    var type: String? { get }
    var by: String? { get }
    var score: Int? { get }
    var descendants: Int? { get }
    var time: Int { get }
    var kids: [Int]? { get }
    
   // func copyWith(text: String?) -> Item
}

extension Item {
    var createdAt: String {
        let date = Date(timeIntervalSince1970: Double(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }

    var timeAgo: String {
        let date = Date(timeIntervalSince1970: Double(time))
        return date.timeAgoString
    }

    var itemUrl: String {
        "https://news.ycombinator.com/item?id=\(self.id)"
    }

    var readableUrl: String? {
        if let url = self.url {
            let domain = URL(string: url)?.host
            return domain
        }
        return nil
    }

    var isJob: Bool {
        return type == "job"
    }

    var isJobWithUrl: Bool {
        return type == "job" && text.isNullOrEmpty && url.isNotNullOrEmpty
    }
}
