//
//  ShopView.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//

import SwiftUI

struct ShopView: View {
    @StateObject var user = User.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ShopViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        ZStack {
                            Image(.backBtn)
                                .resizable()
                                .scaledToFit()
                        }.frame(height: DeviceInfo.shared.deviceType == .pad ? 100:55)
                        
                    }
                    Spacer()
                    
                    HStack(spacing: 5){
                        Spacer()
                        
                        ZStack {
                            Image(.coinsBg)
                                .resizable()
                                .scaledToFit()
                            
                            Text("\(user.coins)")
                                .font(.system(size: DeviceInfo.shared.deviceType == .pad ? 40:20, weight: .black))
                                .foregroundStyle(.white)
                                .textCase(.uppercase)
                        }.frame(height: DeviceInfo.shared.deviceType == .pad ? 100:50)
                        
                    }
                    
                
            }.padding([.top,.horizontal], 20)
                HStack {
                    itemView(image: .magnet, header: "magnet", isOpen: true)
                    
                    itemView(image: .acceleration, header: "Acceleration", isOpen: true)
                    
                    itemView(image: .shield, header: "shield", isOpen: true)
                }
                Spacer()
            }
            
        }.background(
            Image(.bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
    }
    
    @ViewBuilder func itemView(image: ImageResource, header: String, isOpen: Bool) -> some View {
        
        
        ZStack {
            
            Image(.shopBg)
                .resizable()
                .scaledToFit()
            
            VStack(alignment: .center, spacing: 15) {
                
                Image(image)
                    .resizable()
                    .foregroundColor(.black)
                    .scaledToFit()
                    .frame(height: DeviceInfo.shared.deviceType == .pad ? 160 : 80)
                    
                
                Text(header)
                    .font(.system(size: DeviceInfo.shared.deviceType == .pad ? 40:20, weight: .bold))
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                Button {
                    
                    switch image {
                    case .magnet: print("magnet")
                    case .acceleration: print("acceleration")
                    case .shield: print("shield")
                    default:
                        print("error")
                    }
                    
                } label: {
                    Image(user.coins < 50 ? .shopBtnRed : .shopBtn)
                        .resizable()
                        .foregroundColor(.black)
                        .scaledToFit()
                        .frame(height: DeviceInfo.shared.deviceType == .pad ? 80 : 50)
                }
                
            }
        }.frame(height: DeviceInfo.shared.deviceType == .pad ? 450:270)
    }
}

#Preview {
    ShopView(viewModel: ShopViewModel())
}
