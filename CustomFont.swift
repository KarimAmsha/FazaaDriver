// CustomFont.swift
// Fazaa

import SwiftUI

extension Font {
    static func app(_ size: CGFloat, _ weight: FontWeight = .regular, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        // يمكنك استخدام relativeTo لو حبيت دعم Dynamic Type
        Font.custom(weight.rawValue, size: size, relativeTo: textStyle)
    }
}

extension View {
    @inlinable
    func appFont(_ size: CGFloat, _ weight: FontWeight = .regular, relativeTo textStyle: Font.TextStyle = .body) -> some View {
        self.font(.app(size, weight, relativeTo: textStyle))
    }
}
