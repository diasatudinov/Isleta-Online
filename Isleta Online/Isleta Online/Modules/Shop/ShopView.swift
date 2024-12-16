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

                itemView(image: .magnet, header: "asdad", text: "asdasd", isOpen: true)
                Spacer()
            }
            
        }.background(
            Image(.bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
    }
    
    @ViewBuilder func itemView(image: ImageResource, header: String, text: String, isOpen: Bool) -> some View {
        
        
        ZStack {
            
            Image(.shopBg)
                .resizable()
                .scaledToFit()
            
            VStack(alignment: .center, spacing: 0) {
                
                Image(image)
                    .resizable()
                    .foregroundColor(.black)
                    .scaledToFit()
                    .frame(height: DeviceInfo.shared.deviceType == .pad ? 160 : 80)
                    .padding(.bottom, 30)
                
                Text(header)
                    .font(.system(size: DeviceInfo.shared.deviceType == .pad ? 50:20, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)
                Text(text)
                    .font(.system(size: DeviceInfo.shared.deviceType == .pad ? 46:13))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
            }
        }.frame(height: 270)
    }
}

#Preview {
    ShopView(viewModel: ShopViewModel())
}
