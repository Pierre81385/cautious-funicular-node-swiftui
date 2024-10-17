//
//  ContentView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/5/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
//            VStack {
//                Text("Socket.IO Client in SwiftUI Mobile").bold().italic()
//                Text("Check the console for socket events").fontWeight(.ultraLight)
//            }
        EntryView()
            .onAppear{
                        SocketService.shared.socket.connect()
                    }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
