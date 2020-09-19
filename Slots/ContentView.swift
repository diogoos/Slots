//
//  ContentView.swift
//  Slots
//
//  Created by Diogo Silva on 09/17/20.
//

import SwiftUI

struct ContentView: View {
    private func sendMessage(_ msg: AppDelegate.Message) {
        (NSApp.delegate as? AppDelegate)?.handle(msg)
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
            Button(action: { sendMessage(.SlotBuilderActivate)}, label: { Text("Edit slots") })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
