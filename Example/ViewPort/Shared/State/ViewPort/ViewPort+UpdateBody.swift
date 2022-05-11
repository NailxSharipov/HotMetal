//
//  ViewPort+BodyMove.swift
//  ViewPort
//
//  Created by Nail Sharipov on 08.05.2022.
//

import SwiftUI
import HotMetal
import CoreGraphics

extension ViewPort {
    
    func isInside(point: CGPoint) -> Bool {
        guard activeTransaction == nil else { return false }
        let local = transform.screenToLocal(point: point)
        return frameLocal.isContain(point: local)
    }

    mutating func move(translation: CGSize) {
        if activeTransaction == nil {
            activeTransaction = Transaction(worldFrame: frameWorld, viewPoint: viewPoint)
        }
        
        if let transaction = activeTransaction {
            let translation = self.clipTranslate(startFrame: transaction.startWorldFrame, screen: translation).stretch
            frameWorld = transaction.startWorldFrame.translate(size: translation)
            viewPoint = transaction.startViewPoint + translation
        }
    }

    mutating func endMove(translation: CGSize) {
        guard let transaction = activeTransaction else { return }
        let translation = self.clipTranslate(startFrame: transaction.startWorldFrame, screen: translation).fixed
        frameWorld = transaction.startWorldFrame.translate(size: translation)
        viewPoint = transaction.startViewPoint + translation
        
        transform.update(worldPos: viewPoint)
        activeTransaction = nil
    }
    
    private struct ClipTranslation {
        let stretch: Size
        let fixed: Size
    }
    
    private func clipTranslate(startFrame: Rect, screen translation: CGSize) -> ClipTranslation {
        let localTrans = -1 * transform.screenToLocal(size: translation)
        let worldTrans = transform.localToWorld(size: localTrans)
        let newWorld = startFrame.translate(size: worldTrans)
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
