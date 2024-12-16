//
//  DeviceInfo.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//

import UIKit

class DeviceInfo {
    static let shared = DeviceInfo()
    
    var deviceType: UIUserInterfaceIdiom
    
    private init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom
    }
}
