//
//  HomeView.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 14/02/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            
            HStack {
                DeviceNameComponent()
                Spacer()
            }
            
            .padding(.bottom, 4)
            .zIndex(1)
       
            VStack(alignment: .center) {
                
                // Settings | Quit
                HStack {
                    Spacer()
                    // Settings
                    SettingsButtonComponent()
                    // Quit
                    QuitButtonComponent()
                }
                
                VStack {
                    
                    //HStack - Equaliser | Controls
                    HStack(spacing: 5) {
                        
                        //EQUALISER
                        if #available(macOS 14.0, *) {
                            NavigationLink("EQUALISER", value: Destination.equalizer)
                                .buttonStyle(GreyButton())
                                .focusEffectDisabled()
                                .focusable(false)
                        } else {
                            NavigationLink("EQUALISER", value: Destination.equalizer)
                                .buttonStyle(GreyButton())
                                .focusable(false)
                        }
                        
                        //CONTROLS
                        if #available(macOS 14.0, *) {
                            NavigationLink("CONTROLS", value: Destination.controls)
                                .buttonStyle(GreyButton())
                                .focusEffectDisabled()
                                .focusable(false)
                        } else {
                            NavigationLink("CONTROLS", value: Destination.controls)
                                .buttonStyle(GreyButton())
                                .focusable(false)
                        }
                    }
                    
                    Spacer()
                    
                    // NOISE CONTROL
                    if #available(macOS 14.0, *) {
                        NoiseControlComponent(selection: $store.noiseControlSelected)
                            .focusable(false)
                            .focusEffectDisabled()
                    } else {
                        NoiseControlComponent(selection: $store.noiseControlSelected)
                            .focusable(false)
                    }
                    
                    Spacer()
                    
                    // Battery Indicator
                    BatteryIndicatorComponent()
                    
                    Spacer()
                }
            }
        }
    
        .background(.black)
        .frame(width: 250, height: 230)
        .navigationBarBackButtonHidden(true)
    
    }
        
}

struct HomeView_Previews: PreviewProvider {
    static let store = Store()

    @State static var currentDestination: Destination? = .home
    @ObservedObject private var viewModel = AppContainer.shared.container.resolve(MainViewViewModel.self)!

    
    static var previews: some View {
        // Use a Group to allow for multiple previews if needed
        HomeView() // Pass the binding
            .environmentObject(store)
            .previewDisplayName("Home View Preview")
    }
    
}
