//
//  SettingsModel.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//


import SwiftUI

class SettingsModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true
}