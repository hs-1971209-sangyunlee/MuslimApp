import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var isLoggedIn: Bool = false
    var userId: String = ""
    var userName: String = ""
}
