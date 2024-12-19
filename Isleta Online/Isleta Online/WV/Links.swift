import SwiftUI

class Links {
    
    static let shared = Links()
    
    static let winStarData = "https://onlinews.xyz/info"
    static let privacyData = "https://onlinews.xyz/"
    
    @AppStorage("finalUrl") var finalURL: URL?
    
    
}