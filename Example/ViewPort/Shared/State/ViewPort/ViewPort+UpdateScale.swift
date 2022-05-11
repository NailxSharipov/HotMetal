//
//  ViewPort+UpdateScale.swift
//  ViewPort
//
//  Created by Nail Sharipov on 11.05.2022.
//

import SwiftUI

extension ViewPort {

    struct ScaleTransactionResult {
        let animate: Bool
        let rect: Rect
    }
    
    var isScalePossible: Bool {
        activeTransaction == nil
    }

    mutating func scale(_ scale: Float) {
        if activeTransaction == nil {
            activeTransaction = Transaction(worldFrame: frameWorld, viewPoint: viewPoint)
        }
        
        guard let transaction = activeTransaction else {
            return
        }

        let clip = self.clipScale(startFrame: transaction.startWorldFrame, scale: scale, maxSize: imageSize)
        frameWorld = clip.stretch

        self.setMaxSize()
    }
    
    mutating func endScale(_ scale: Float) -> ScaleTransactionResult? {
        guard let transaction = activeTransaction else {
            return nil
        }

        let clip = self.clipScale(startFrame: transaction.startWorldFrame, scale: scale, maxSize: imageSize)

        activeTransaction = nil
        return ScaleTransactionResult(animate: clip.isOverlap, rect: clip.fixed)
    }
    
    mutating func apply(_ result: ScaleTransactionResult) {
        frameWorld = result.rect
        self.setMaxSize()
        activeTransaction = nil
    }
    
    private struct ClipScale {
        let stretch: Rect
        let fixed: Rect
        let isOverlap: Bool
    }
    
    private func clipScale(startFrame: Rect, scale: Float, maxSize: Size) -> ClipScale {
        let nScale: Float = max(0.01, scale)

        let newWorld = startFrame.scale(nScale)
        let clip = self.scaleClip(world: newWorld, angle: angle)
        guard case let .overlap(rect) = clip else {
            return ClipScale(stretch: newWorld, fixed: newWorld, isOverlap: false)
        }
        
        let stretch = Rect(center: rect.center, size: newWorld.size.stretch(max: rect.size))
        
        return ClipScale(stretch: stretch, fixed: rect, isOverlap: true)
    }
    
}


private extension Float {
    
    func stretch(max: Float) -> Float {
        guard self > max else { return self }
        let x = self / max
        let s = max * (1 + 0.15 * (1 - 1/x))
        return s
    }
}

private extension Size {
    
    func stretch(max: Size) -> Size {
        Size(
            width: width.stretch(max: max.width),
            height: height.stretch(max: max.height)
        )
    }

}
