//
//  TapAndHoldIconComponent.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/11.
//

import SwiftUI

struct TapAndHoldIconComponent: View {
    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.red)
                .frame(width: 4, height: 4)
            Rectangle()
                .fill(Color.red)
                .frame(width: 8, height: 1)
        }
        .padding(.bottom, 2)
    }
}

#Preview {
    TapAndHoldIconComponent()
}
