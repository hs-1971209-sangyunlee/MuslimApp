//
//  Post.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/18.
//

import Foundation

struct Post: Codable {
    let title: String
    let detail: String
    let userName: String
    let userId: String
    let image: String?
    let placeId: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case detail
        case userName
        case userId
        case image
        case placeId
        case timestamp
    }
}
