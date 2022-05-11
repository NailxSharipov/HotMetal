//
//  ViewPort+CornerMove.swift
//  ViewPort
//
//  Created by Nail Sharipov on 08.05.2022.
//

import SwiftUI
import HotMetal
import CoreGraphics

extension ViewPort {
    
    private struct Distance {
        let sqrDist: Float
        let corner: Rect.Corner.Layout
    }
    
    // move Corner
    
    func isCorner(point: CGPoint, sqrRadius: CGFloat) -> Rect.Corner.Layout? {
        guard activeTransaction == nil else { return nil }

        let p = transform.screenToLocal(point: point)
        
        let distanceList = frameLocal.corners.map({ Distance(sqrDist: $0.point.sqrDistance(p), corner: $0.layout) })
        
        guard let nearest = distanceList.sorted(by: { $0.sqrDist < $1.sqrDist }).first else { return nil }

        if nearest.sqrDist < Float(sqrRadius) {
            return nearest.corner
        }
        
        return nil
    }

    mutating func move(corner: Rect.Corner.Layout, translation: CGSize) {
        if activeTransaction == nil {
            activeTransaction = Transaction(localFrame: frameLocal)
        }
        
        if let transaction = activeTransaction {
            frameLocal = self.translate(startFrame: transaction.startLocalFrame, corner: corner, screen: translation)
        }
    }
    
    mutating func endMove(corner: Rect.Corner.Layout, translation: CGSize) {
        guard let transaction = activeTransaction else { return }
        let newLocal = self.translate(startFrame: transaction.startLocalFrame, corner: corner, screen: translation)
        frameLocal = newLocal
        frameWorld = transform.localToWorld(rect: newLocal)
        
        self.setMaxSize() // animate this

        activeTransaction = nil
    }
    
    private func translate(startFrame: Rect, corner: Rect.Corner.Layout, screen translation: CGSize) -> Rect {
        var rect = startFrame
        
        let fixed = rect.corner(layout: rect.opossite(layout: corner))
        let fixedWorld = transform.localToWorld(point: fixed.point)
        
        let trans = transform.screenToLocal(size: translation)
        var float = rect.cornerPoint(layout: corner) + trans
        let floatWorld = transform.localToWorld(point: float)

        // clip float corner
        
        let clip = self.clip(point: floatWorld)
        if clip.isOverlap {
            float = transform.worldToLocal(point: clip.point)
        }
        
        rect = Rect(a: fixed.point, b: float)
        
        let cw = rect.corner(layout: rect.clockWise(layout: corner))
        let cwWorld = transform.localToWorld(point: cw.point)

        let ccw = rect.corner(layout: rect.counterClockWise(layout: corner))
        let ccwWorld = transform.localToWorld(point: ccw.point)
        
        let cwClip = self.clip(fixed: fixedWorld, float: cwWorld)
        let ccwClip = self.clip(fixed: fixedWorld, float: ccwWorld)
        
        if cwClip.isOverlap || ccwClip.isOverlap {
            let a = transform.worldToLocal(point: cwClip.point)
            let b = transform.worldToLocal(point: ccwClip.point)
            rect = Rect(a: a, b: b)
        }

        // clip size
        let worldSize = transform.scaleLocalToWorld(rect.size)
        if worldSize.width < minSize || worldSize.height < minSize {
            let width = max(worldSize.width, minSize)
            let height = max(worldSize.height, minSize)

            let localSize = transform.scaleWorldToLocal(Size(width: width, height: height))

            rect = Rect(corner: rect.corner(layout: fixed.layout), size: localSize)
        }

        return rect
    }
}
