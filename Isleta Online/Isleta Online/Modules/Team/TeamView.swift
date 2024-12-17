//
//  TeamView.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 17.12.2024.
//

import SwiftUI

struct TeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var user = User.shared
    @ObservedObject var viewModel: TeamViewModel
    @State private var showChangeTeam = false
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
                if let currentTeam = viewModel.currentTeam {
                    Image("\(currentTeam.icon)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: DeviceInfo.shared.deviceType == .pad ? 400:204)
                }
                
                Button {
                    showChangeTeam = true
                } label: {
                    TextBg(height: 93, text: "Change team", textSize: 24)
                }
                
                Spacer()
            }
        }.background(
            Image(.bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
        .fullScreenCover(isPresented: $showChangeTeam) {
            ChangeTeamView(viewModel: viewModel)
        }
    }
}

#Preview {
    TeamView(viewModel: TeamViewModel())
}
