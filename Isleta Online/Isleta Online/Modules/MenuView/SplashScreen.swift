//
//  SplashScreen.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//

import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    
                    Spacer()
                    
                }
                Spacer()
                
                
            }
            
            VStack {
                Spacer()
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                Image(.loadingImg)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 51)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: scale
                    )
                    .onAppear {
                        scale = 0.8
                    }
                    .padding(.bottom, 20)
                
                Spacer()
            }
        }.background(
            Image(.bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
    }
}

#Preview {
    SplashScreen()
}
