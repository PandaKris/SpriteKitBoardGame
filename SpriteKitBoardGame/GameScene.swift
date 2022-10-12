//
//  GameScene.swift
//  SpriteKitBoardGame
//
//  Created by Kristanto Sean N on 11/10/22.
//

import Foundation
import SpriteKit

enum TouchState {
    case idle
    case touched
    case moved
}

class GameScene : SKScene {
    
    var touchState = TouchState.idle
    var draggedObject: SKNode? = nil
    var initialPosition: CGPoint?
    
    var tileLeftMap = SKTileMapNode()
    var tileRightMap = SKTileMapNode()
    var tileMiddleMap = SKTileMapNode()
    
    var leftBoardArray: [[Int]] = [
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0]
    ]
    
    var rightBoardArray: [[Int]] = [
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0]
    ]
    
    var middleBoardArray: [[Int]] = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ]
    
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        prepareBoard()
        prepareObject()
    }
    
    func prepareObject() {
        let object = SKSpriteNode(imageNamed: "turret")
        object.size = CGSize(width: 100, height: 50)
        object.anchorPoint = CGPoint(x: 0.35, y: 0.75)
        object.position = CGPoint(x: frame.size.width/2, y: frame.size.height*3/4)
        object.userData = ["draggable": true, "width": 2, "height": 1]
        object.zPosition = 10
        self.addChild(object)
    }
    
    func prepareBoard() {
        let board = SKNode()
        anchorPoint = .zero
        
        let tile = SKTileDefinition(texture: SKTexture(imageNamed: "wheel"))
        let tileGroup = SKTileGroup(tileDefinition: tile)

        let tileSelected = SKTileDefinition(texture: SKTexture(imageNamed: "rocket"))
        let tileSelectedGroup = SKTileGroup(tileDefinition: tileSelected)

        let tileSet = SKTileSet(tileGroups: [tileGroup, tileSelectedGroup], tileSetType: .grid)
        
        // left board
        tileLeftMap = SKTileMapNode(
            tileSet: tileSet,
            columns: 2,
            rows: 4,
            tileSize: CGSize(width: 50, height: 50)
        )
        tileLeftMap.fill(with: tileGroup)
        tileLeftMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        for i in 0...leftBoardArray.count-1 {
            for j in 0...leftBoardArray[i].count-1 {
                tileLeftMap.tileDefinition(atColumn: j, row: i)?.userData = [
                    "x": i,
                    "y": j,
                    "tile": "left"
                ]
            }
        }
        tileLeftMap.position = CGPoint(x: frame.size.width / 6, y: frame.size.height/2)
        board.addChild(tileLeftMap)

        // right board
        tileRightMap = SKTileMapNode(
            tileSet: tileSet,
            columns: 2,
            rows: 4,
            tileSize: CGSize(width: 50, height: 50)
        )
        tileRightMap.fill(with: tileGroup)
        tileRightMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        for i in 0...rightBoardArray.count-1 {
            for j in 0...rightBoardArray[i].count-1 {
                tileRightMap.tileDefinition(atColumn: j, row: i)?.userData = [
                    "x": i,
                    "y": j,
                    "tile": "right"
                ]
            }
        }
        tileRightMap.position = CGPoint(x: frame.size.width * 5 / 6, y: frame.size.height/2)
        board.addChild(tileRightMap)
        
        // middle board
        tileMiddleMap = SKTileMapNode(
            tileSet: tileSet,
            columns: 4,
            rows: 4,
            tileSize: CGSize(width: 50, height: 50)
        )
        tileMiddleMap.fill(with: tileGroup)
        tileMiddleMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        for i in 0...middleBoardArray.count-1 {
            for j in 0...middleBoardArray[i].count-1 {
                tileMiddleMap.tileDefinition(atColumn: j, row: i)?.userData = [
                    "x": i,
                    "y": j,
                    "tile": "middle"
                ]
            }
        }
        tileMiddleMap.position = CGPoint(x: frame.size.width / 2, y: frame.size.height/2)
        board.addChild(tileMiddleMap)

        self.addChild(board)

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNode = scene?.nodes(at: touch.location(in: self))
        guard let touchedNode = touchedNode else { return }
        if touchedNode.isEmpty { return }
                
        if ((touchedNode[0].userData?.value(forKey: "draggable")) != nil) {
            touchState = .touched
            draggedObject = touchedNode[0]
            initialPosition = touch.location(in: self)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNode = scene?.nodes(at: touch.location(in: self))
        guard let touchedNode = touchedNode else { return }
        if touchedNode.isEmpty { return }

        touchState = .moved
        draggedObject?.position = touches.first?.location(in: self) ?? CGPoint(x: 0, y: 0)

        var nodePos = touchedNode.count - 2
        if nodePos < 0 {
            nodePos = 0
        }
        if let tile = touchedNode[nodePos] as? SKTileMapNode {
            displaySelectedTiles(tile: tile, touch: touch, object: draggedObject)
        } else {
            resetTiles()
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNode = scene?.nodes(at: touch.location(in: self))
        guard let touchedNode = touchedNode else { return }
        if touchedNode.isEmpty { return }
        
        var nodePos = touchedNode.count - 2
        if nodePos < 0 {
            nodePos = 0
        }

        if let tile = touchedNode[nodePos] as? SKTileMapNode {
            // check if object can fit the selected tile
            if checkCanFitTile(tile: tile, touch: touch, object: draggedObject!) {
                // if yes, remove initial position in tile, set new position in new tile
                // place object in that tile
                print("CAN PUT TILE")
                placeObjectToTile(tile: tile, touch: touch, object: draggedObject)
            } else {
                // if no, put them back
                if let position = initialPosition {
                    draggedObject?.position = position
                }
            }
        }

        resetTiles()
        touchState = .idle
        draggedObject = nil
        initialPosition = nil

    }
    
    func checkCanFitTile(tile: SKTileMapNode, touch: UITouch, object: SKNode) -> Bool {
        
        //get object width and height
        let objWidth = object.userData?.value(forKey: "width") as? Int
        let objHeight = object.userData?.value(forKey: "height") as? Int
        
        if let width = objWidth, let height = objHeight {
            let column = tile.tileColumnIndex(fromPosition: touch.location(in: tile))
            let row = tile.tileRowIndex(fromPosition: touch.location(in: tile))
            tile.setTileGroup(tile.tileSet.tileGroups[1], forColumn: column, row: row)
            for i in 1...width {
                for j in 1...height {
                    if tile.numberOfColumns <= column + i - 1 || tile.numberOfRows <= row - j + 1 {
                        return false
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func resetTiles() {
        tileLeftMap.fill(with: tileLeftMap.tileSet.tileGroups[0])
        tileMiddleMap.fill(with: tileMiddleMap.tileSet.tileGroups[0])
        tileRightMap.fill(with: tileRightMap.tileSet.tileGroups[0])
    }
    
    func placeObjectToTile(tile: SKTileMapNode, touch: UITouch, object: SKNode?){

        guard let object = object else {
            return
        }

        //get object width and height
        let objWidth = object.userData?.value(forKey: "width") as? Int
        let objHeight = object.userData?.value(forKey: "height") as? Int
        
        if let width = objWidth, let height = objHeight {
            let column = tile.tileColumnIndex(fromPosition: touch.location(in: tile))
            let row = tile.tileRowIndex(fromPosition: touch.location(in: tile))
            object.position = tile.convert(tile.centerOfTile(atColumn: column, row: row), to: self)
        }
    }
    
    func displaySelectedTiles(tile: SKTileMapNode, touch: UITouch, object: SKNode?){
        resetTiles()

        guard let object = object else {
            return
        }

        //get object width and height
        let objWidth = object.userData?.value(forKey: "width") as? Int
        let objHeight = object.userData?.value(forKey: "height") as? Int
        
        if let width = objWidth, let height = objHeight {
            let column = tile.tileColumnIndex(fromPosition: touch.location(in: tile))
            let row = tile.tileRowIndex(fromPosition: touch.location(in: tile))
            tile.setTileGroup(tile.tileSet.tileGroups[1], forColumn: column, row: row)

            for i in 1...width {
                for j in 1...height {
                    tile.setTileGroup(tile.tileSet.tileGroups[1], forColumn: column + i - 1, row: row - j + 1)
                }
            }
        }
        
    }
}
