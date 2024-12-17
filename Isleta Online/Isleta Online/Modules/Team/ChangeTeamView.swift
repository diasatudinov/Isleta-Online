//
//  ChangeTeamView.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 17.12.2024.
//

import SwiftUI

struct ChangeTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var user = User.shared
    @ObservedObject var viewModel: TeamViewModel
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
                    ForEach(viewModel.teams, id: \.self) { team in
                        
                        itemView(image: team.icon, header: team.name, team: team)
                    }
                }
                
                
                Spacer()
            }
            
            Spacer()
        }.background(
            Image(.bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
        )
        
    }
    
    @ViewBuilder func itemView(image: String, header: String, team: Team) -> some View {
        
        
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
                    
                    viewModel.currentTeam = team
                } label: {
                    TextBg(height: DeviceInfo.shared.deviceType == .pad ? 80:42, text: viewModel.currentTeam?.name == header ? "Selected":"Choose", textSize: DeviceInfo.shared.deviceType == .pad ? 32:16)
                    
                }
                
            }
        }.frame(height: DeviceInfo.shared.deviceType == .pad ? 450:270)
    }
}

#Preview {
    ChangeTeamView(viewModel: TeamViewModel())
}
