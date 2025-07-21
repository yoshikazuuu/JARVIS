//
//  Font.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import Foundation
import SwiftUI

extension Font {
    static func mulish(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.custom("Mulish", size: size).weight(weight)
    }
}
