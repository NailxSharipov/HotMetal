//
//  ViewPort+BodyMove.swift
//  ViewPort
//
//  Created by Nail Sharipov on 08.05.2022.
//

import SwiftUI
import HotMetal
import CoreGraphics

private var initWorldFrame: Rect = .zero
private var initWorldView: Rect = .zero

extension ViewPort {
    
    func isInside(point: CGPoint) -> Bool {
        guard modeState == .idle else { return false }
        let local = transform.screenToLocal(point: point)
        return frameLocal.isContain(point: local)
    }

    mutating func move(translation: CGSize) {
        if modeState == .idle {
            modeState = .body
            initWorldFrame = frameWorld
            initWorldView = viewWorld
        }

        let translation = self.clipTranslate(screen: translation).stretch
        frameWorld = initWorldFrame.translate(size: translation)
        viewWorld = initWorldView.translate(size: translation)
    }

    mutating func endMove(translation: CGSize) {
        let translation = self.clipTranslate(screen: translation).fixed
        frameWorld = initWorldFrame.translate(size: translation)
        viewWorld = initWorldView.translate(size: translation)
        
        transform.update(worldPos: viewWorld.center)
        modeState = .idle
    }
    
    private struct ClipTranslation {
        let stretch: Size
        let fixed: Size
    }
    
    private func clipTranslate(screen translation: CGSize) -> ClipTranslation {
        let localTrans = -1 * transform.screenToLocal(size: translation)
        let worldTrans = transform.localToWorld(size: localTrans)
        let newWorld = initWorldFrame.translate(size: worldTrans)
        let clip = self.rectClip(world: newWorld)
        guard clip.isOverlap else {
            return ClipTranslation(stretch: worldTrans, fixed: worldTrans)
        }
        
        let localSize = transform.worldToLocal(size: Size(vector: clip.vector))
        let worldStretch = worldTrans + transform.localToWorld(size: localSize.stretch)
        let worldFixed = worldTrans + transform.localToWorld(size: localSize)
        
        return ClipTranslation(stretch: worldStretch, fixed: worldFixed)
    }
}

private extension Float {
    
    var stretch: Float {
        let x = self
        let a = abs(x)
        return x * (1 - 0.5 / (0.005 * a + 1))
    }
}

private extension Size {
    
    var stretch: Size {
        Size(width: width.stretch, height: height.stretch)
    }

}
