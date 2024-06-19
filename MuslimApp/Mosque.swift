//
//  Mosque.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/18.
//

import Foundation

struct Mosque: Codable {
    let region: String
    let title: String
    let type: String
    let address: String
    let phone_number: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case region = "지역"
        case title = "상호"
        case type = "종류"
        case address = "주소"
        case phone_number = "연락처"
        case latitude = "위도"
        case longitude = "경도"
    }
}
