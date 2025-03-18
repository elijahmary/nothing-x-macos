//
//  ConnectView.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 14/02/23.
//

import SwiftUI

struct ConnectView: View {
    
    private let title: LocalizedStringKey? = "Failed to connect"
    private let text: LocalizedStringKey? = "Make sure device is on and in discovery mode."
    private let topButtonText: LocalizedStringKey? = "Retry"
    private let bottomButtonText: LocalizedStringKey? = "Cancel"
    
    @StateObject private var viewModel = AppContainer.shared.container.resolve(ConnectViewViewModel.self)!
    
    
    var body: some View {
        
        
        ZStack(alignment: .bottom) {
            
            
            // ear (1)
            
            HStack {
                DeviceNameComponent()
                Spacer()
            }
            .padding(.bottom, 4)
            .zIndex(1)
            
            
            
            VStack {
                
                HStack {
                    Spacer()
                    
                    // Settings
                    SettingsButtonComponent()
                    
                    // Quit
                    QuitButtonComponent()
                }
                
                VStack {
                    // Ear 1 Image
                    Image("ear_1")
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                .blendMode(.darken)
                        )
                    
                    
                    Spacer(minLength: 15)
                    
                    if viewModel.isLoading {
                        // Show loading spinner
                        ProgressView() // You can customize the text
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(Color.white)
                            .colorInvert()
                            .scaleEffect(0.6)
                            .padding(.bottom, 15)
                        
                        
                    } else {
                        // Connect Button
                        if #available(macOS 14.0, *) {
                            Button("Reconnect") {
                                viewModel.checkBluetoothStatus()
                                if viewModel.isBluetoothOn {
                                    viewModel.connect()
                                } else {
                                    viewModel.navigateToBluetoothOffView()
                                }
                                
                            }
                            .buttonStyle(OffWhiteConnectButton())
                            .focusable(false)
                            .focusEffectDisabled()
                        } else {
                            Button("Reconnect") {
                                viewModel.checkBluetoothStatus()
                                if viewModel.isBluetoothOn {
                                    viewModel.connect()
                                } else {
                                    viewModel.navigateToBluetoothOffView()
                                }
                                
                            }
                            .buttonStyle(OffWhiteConnectButton())
                            .focusable(false)
                        }
                        
                    }
                    
                }
                
                
            }
            
            // Bottom sheet overlay
            if viewModel.isFailedToConnectPresented {
                Color.black.opacity(0.4) // Background dimming
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            viewModel.isFailedToConnectPresented = false
                        }
                    }
                    .zIndex(2)
                
                ModalSheetComponent(isPresented: $viewModel.isFailedToConnectPresented, title: title, text: text, topButtonText: topButtonText, bottomButtonText: bottomButtonText, action: {
                    viewModel.retryConnect()
                }, onCancelAction: {})
                .animation(.easeInOut, value: viewModel.isFailedToConnectPresented) // Animate the appearance
                .offset(y: viewModel.isFailedToConnectPresented ? 0 : 180) // Slide in from the bottom
                .zIndex(3)
                
            }
            
        }
        
        .padding(.bottom, 0)
        .background(.black)
        .frame(width: 250,height: 230)
        .navigationBarBackButtonHidden(true)
        
    }
        
        
        
}


struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
