//
//  Links.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 19.12.2024.
//


import SwiftUI

class Links {
    
    static let shared = Links()
    
    static let winStarData = "https://onlinews.xyz/info"
    static let privacyData = "https://onlinews.xyz/"
    
    @AppStorage("finalUrl") var finalURL: URL?
    
    
}