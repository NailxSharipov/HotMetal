//
//  CGPoint.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import CoreGraphics

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(left: CGFloat, right: CGPoint) -> CGPoint {
    CGPoint(x: left * right.x, y: left * right.y)
}

func *(left: CGPoint, right: CGFloat) -> CGPoint {
    right * left
}

func /(left: CGPoint, right: CGFloat) -> CGPoint {
    let k = 1 / right
    return k * left
}
