//
//  ContentView.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Back")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
