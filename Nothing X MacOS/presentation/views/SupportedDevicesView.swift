//
//  SupportedDevicesView.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/15.
//

import SwiftUI

struct SupportedDevicesView: View {
    var body: some View {
        ZStack {
            
            VStack {
                
                HStack {
                    // Back
                    BackButtonComponent()
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    
                    //Header title
                    HStack {
                        // Heading
                        Text("Supported devices")
                            .modifier(ViewTitleStyle())
                        
                        
                        
                        Spacer()
                    }
                    
                    Text("Nothing")
                        .modifier(SettingsSubsectionTitleStyle())
                        .padding(.top, 8)
                    
                    
                    HStack(spacing: 12) {
                        GeometryReader { geometry in
                            
                            RoundedRectangle(cornerRadius: 12) // Set the corner radius
                                .frame(width: geometry.size.width, height: geometry.size.width) // Set the size of the rectangle
                                .foregroundColor(Color(.modalSheet))
                                .overlay(
                                    
                                    ZStack {
                                        
                                        Image("ear_1")
                                            .scaledToFit()
                                            .scaleEffect(0.6)
                                            .offset(y: -8)
                                        
                                        Text("Ear (1)")
                                            .modifier(SupportedDeviceNameTextStyle())
                                    }
                                    
                                )
                            
                            
                            
                        }
                        
                        GeometryReader { geometry in
                            
                            RoundedRectangle(cornerRadius: 12) // Set the corner radius
                                .frame(width: geometry.size.width, height: geometry.size.width) // Set the size of the rectangle
                                .foregroundColor(.gray) // Set the fill color (you can change this)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12) // Overlay for border
                                        .stroke(Color.black, lineWidth: 2) // Set the border color and width
                                )
                                .hidden()
                            
                        }
                        
                    }
                    
                    
                }
                .padding(.horizontal, 16)
                
                
            }
            
        }
        .frame(width: 250, height: 230)
        .background(Color.black)
    }
}

#Preview {
    SupportedDevicesView()
}
