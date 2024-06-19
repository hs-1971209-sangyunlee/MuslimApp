import Foundation

struct Restaurant: Codable{
    let region: String
    let title: String
    let type: String
    let address: String
    let phone_number: String
    let latitude: Double
    let longitude: Double
    let menu: String
    let price: String
    let note: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case region = "지역"
        case title = "상호"
        case type = "종류"
        case address = "주소"
        case phone_number = "연락처"
        case latitude = "위도"
        case longitude = "경도"
        case menu = "메뉴"
        case price = "가격"
        case note = "비고"
        case id = "id"
    }
}

struct Mosque: Codable{
    let region: String
    let title: String
    let type: String
    let address: String
    let phone_number: String
    let latitude: Double
    let longitude: Double
    let id: String

    enum CodingKeys: String, CodingKey {
        case region = "지역"
        case title = "상호"
        case type = "종류"
        case address = "주소"
        case phone_number = "연락처"
        case latitude = "위도"
        case longitude = "경도"
        case id = "id"
    }
}
