//
//  TripleTapIconComponent.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/11.
//

import SwiftUI

struct TripleTapIconComponent: View {
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(Color.red)
                .frame(width: 4, height: 4)
            Circle()
                .fill(Color.red)
                .frame(width: 4, height: 4)
            Circle()
                .fill(Color.red)
                .frame(width: 4, height: 4)
            
        }
        .padding(.bottom, 2)
    }
}

#Preview {
    TripleTapIconComponent()
}
