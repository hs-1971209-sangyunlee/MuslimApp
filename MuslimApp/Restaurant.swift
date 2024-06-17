//
//  Restaurant.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/15.
//

import Foundation

struct Restaurant: Codable {
    let region: String
    let title: String
    let type: String
    let address: String
    let phone_number: String
    let menu: String
    let price: String
    let note: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case region = "지역"
        case title = "상호"
        case type = "종류"
        case address = "주소"
        case phone_number = "연락처"
        case menu = "메뉴"
        case price = "가격"
        case note = "비고"
        case latitude = "위도"
        case longitude = "경도"
    }
}

