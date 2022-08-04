//
//  ItemProtocol.swift
//  ZCombinator (iOS)
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation

protocol ItemProtocol: Codable, Identifiable, Hashable {
    var id: Int { get }
    var title: String? { get }
    var text: String? { get }
    var url: String? { get }
    var by: String { get }
    var score: Int? { get }
    var descendants: Int? { get }
    var time: Int { get }
    var kids: [Int]? { get }
}
