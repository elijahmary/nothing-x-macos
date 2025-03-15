//
//  TextStyles.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/11.
//

import Foundation
import SwiftUICore


struct SubsettingTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .light))
            .textCase(.uppercase)
            .padding(.bottom, 1)
            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)))
    }
}

struct SubsettingDescriptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .light))
            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
    }
}

struct SettingsSubsectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
            .textCase(.uppercase)
            .padding(.top, 8)
    }
}

struct SettingsToggleDescriptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .light))
            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
            .padding(.trailing, 64)
    }
}

struct ViewTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("5by7", size: 16))
            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)))
            .multilineTextAlignment(.leading)
            .textCase(.uppercase)
    }
}

struct DescriptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(2)
            .font(.system(size: 10, weight: .light))
            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 12)
    }
}

struct ActionSelectionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            
            .padding(4)
            .textCase(.uppercase)
    }
}

struct ActionSelectionTitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            
            .font(.system(size: 10, weight:.light))
            .textCase(.uppercase)
    }
}


struct SupportedDeviceNameTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .offset(y: 38)
            .font(.system(size: 8, weight: .light))
            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
    }
}


