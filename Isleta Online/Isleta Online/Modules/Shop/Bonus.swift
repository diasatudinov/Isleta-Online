//
//  Bonus.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 17.12.2024.
//

import Foundation

struct Bonus : Identifiable, Equatable, Codable, Hashable {
    let id = UUID()
    let icon: String
    let name: String
    var purchased = false
}
