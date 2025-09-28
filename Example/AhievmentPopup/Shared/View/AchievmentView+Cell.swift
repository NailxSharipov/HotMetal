//
//  AchievmentView+Cell.swift
//  AhievmentPopup
//
//  Created by Nail Sharipov on 01.09.2022.
//

import SwiftUI

extension AchievmentView {

    struct Cell: View {

        let item: AchievmentItem
        let color: Color
        let duration: TimeInterval
        @State var animation: CGFloat = 0

        var body: some View {
            ZStack {
                Capsule().fill(.white)
                ShineCapsule(
                    startColor: Color(white: 1, opacity: 0.5),
                    endColor: Color(white: 1, opacity: 0),
                    maxScale: 1.7,
                    animation: animation
                )
                HStack(spacing: 2) {
                    item.image.resizable().clipShape(Circle())
                    .aspectRatio(1, contentMode: .fit)
                    .padding(8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(color)
                        Text(item.description)
                            .lineLimit(2)
                            .font(.system(size: 12))
                            .foregroundColor(color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .bottom, .trailing], 8)
                }
            }
            .frame(width: 300, height: 60)
            .onAppear() {
                withAnimation(.linear(duration: duration)) {
                    animation = 0.6 * duration
                }
            }
        }
    }
}

private struct ShineCapsule: View, Animatable {
    
    var animatableData: CGFloat {
         get {
             animation
         }
         set {
             animation = newValue
         }
     }
    
    let startColor: Color
    let endColor: Color
    let maxScale: CGFloat

    var animation: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            self.content(size: proxy.size)
        }
    }
    
    private func content(size: CGSize) -> some View {
        let delta = (maxScale - 1) * size.height
        
        let t0 = animation.remainder(offset: 0)
        let d0 = delta * t0
        let w0 = size.width + d0
        let h0 = size.height + d0
        let c0 = startColor.lerp(color: endColor, fraction: t0)
        
        let t1 = animation.remainder(offset: 0.5)
        let d1 = delta * t1
        let w1 = size.width + d1
        let h1 = size.height + d1
        let c1 = startColor.lerp(color: endColor, fraction: t1)
        
        let x = 0.5 * size.width
        let y = 0.5 * size.height
        
        return ZStack {
            Capsule()
                .fill(c0)
                .frame(
                    width: w0,
                    height: h0,
                    alignment: .center
                )
                .position(x: x, y: y)
            Capsule()
                .fill(c1)
                .frame(
                    width: w1,
                    height: h1,
                    alignment: .center
                )
                .position(x: x, y: y)
        }
    }
    
}

private extension CGFloat {

    func remainder(offset: CGFloat) -> CGFloat {
        let a = self + offset
        let r = a - a.rounded(.towardZero)
        return r
    }
}

private extension Color {
    
    struct RGBA {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
    }
    
    var rgba: RGBA {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        let native = NativeColor(self)
        
        if let color = native.usingColorSpace(.deviceRGB) {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            return RGBA(r: r, g: g, b: b, a: a)
        }

        if let color = native.usingColorSpace(.deviceRGB) {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var l: CGFloat = 0
            var a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
            
            return Color.toRGB(h: h, s: s, l: l, a: a)
        }

        return RGBA(r: 0, g: 0, b: 0, a: 0)
    }

    func lerp(color: Color, fraction f: CGFloat) -> Color {
        guard f > 0 else {
            return self
        }
        let s = self.rgba
        let t = color.rgba
        
        let r = s.r + (t.r - s.r) * f
        let g = s.g + (t.g - s.g) * f
        let b = s.b + (t.b - s.b) * f
        let a = s.a + (t.a - s.a) * f
        
        return Color(red: r, green: g, blue: b, opacity: a)
    }
    
    
    private static func toRGB(h: CGFloat, s: CGFloat, l: CGFloat, a: CGFloat) -> RGBA {
        guard s != 0 else {
            return RGBA(r: s, g: s, b: s, a: a)
        }

        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        let r = hueToRgb(p: p, q: q, t: h + 1 / 3)
        let g = hueToRgb(p: p, q: q, t: h)
        let b = hueToRgb(p: p, q: q, t: h - 1 / 3)
        
        return RGBA(r: r, g: g, b: b, a: a)
    }

    private static func hueToRgb(p: CGFloat, q: CGFloat, t: CGFloat) -> CGFloat {
        var t = t
        
        if t < 0 {
            t += 1
        }
        
        if t > 1 {
            t -= 1
            
        }
        
        if t < 1 / 6 {
            return p + (q - p) * 6 * t
        }
        
        if t < 1 / 2 {
            return q
        }
            
        if t < 2 / 3 {
            return p + (q - p) * (2 / 3 - t) * 6
        }
            
        return p
    }

}
