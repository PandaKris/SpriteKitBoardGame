//
//  ContentView.swift
//  SpriteKitBoardGame
//
//  Created by Kristanto Sean N on 11/10/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: GameScene(size: geometry.size), debugOptions: [
                    .showsFPS,
                    .showsNodeCount,
                    .showsPhysics
            ])
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
