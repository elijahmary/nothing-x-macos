//
//  SettingsView.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 15/02/23.
//

import SwiftUI

struct SettingsView: View {
    
    private let title: LocalizedStringKey? = "Forget This Device?"
    private let text: LocalizedStringKey? = nil
    private let topButtonText: LocalizedStringKey? = "Forget"
    private let bottomButtonText: LocalizedStringKey? = "Cancel"
    
    
    @StateObject private var viewModel = SettingsViewViewModel(nothingService: NothingServiceImpl.shared, nothingRepository: NothingRepositoryImpl.shared)
    
    @EnvironmentObject private var mainViewModel: MainViewViewModel
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                
                // Back - Heading - Settings | Quit
                HStack {
                    // Back
                    BackButtonComponent()
                 
                    Spacer()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(alignment: .leading) {
                        
                        //Header title
                        HStack {
                            // Heading
                            Text("Device settings")
                                .modifier(ViewTitleStyle())
                            
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        
                        VStack(alignment: .leading) {
                        
                        if viewModel.isNothingDeviceAccessible {
                            
                     
                                Text("Advanced features")
                                    .modifier(SettingsSubsectionTitleStyle())
                                    .padding(.top, 8)
                                // IN-EAR DETECT
                                
                                VStack(alignment: .leading) {
                                    Toggle("In-ear detection", isOn: $viewModel.inEarSwitch)
                                        .onChange(of: viewModel.inEarSwitch) { newValue in
                                            // Call the function when the toggle changes
                                            viewModel.switchInEarDetection(mode: newValue)
                                        }
                                    
                                    Text("Automatically play audio when earbuds are in and pause when removed.")
                                        .modifier(SettingsToggleDescriptionStyle())
                                }
                                .padding(.vertical, 6)
                                
                                VStack(alignment: .leading) {
                                    Toggle("Low lag mode", isOn: $viewModel.latencySwitch)
                                        .onChange(of: viewModel.latencySwitch) { newValue in
                                    
                                            viewModel.switchLatency(mode: newValue)
                                        }
                                    
                                    Text("Minimize latency for an improved gaming experience.")
                                        .modifier(SettingsToggleDescriptionStyle())
                                }
                                .padding(.vertical, 6)
                                
                                // Find My Earbuds
                                NavigationLink("FIND MY EARBUDS", value: Destination.findMyBuds)
                                    .textCase(.uppercase)
                                    .buttonStyle(FindMyTransparentButton())
                                    .padding(.bottom, 8)
                                
                                //Separation line
                                Rectangle()
                                    .fill(Color(#colorLiteral(red: 0.07009194046, green: 0.07611755282, blue: 0.08425947279, alpha: 1)))
                                    .frame(height: 0.8)
                            }
                            
                            Text("Device details")
                                .modifier(SettingsSubsectionTitleStyle())
                                
                            
                            VStack(alignment: .leading) {
                                Text("Device name")
                                    .modifier(SubsettingTitleStyle())
                                    
                                
                                Text(viewModel.name)
                                    .modifier(SubsettingDescriptionStyle())
                                    
                            }
                            .padding(.top, 8)
                            .padding(.vertical, 6)
                            
                            VStack(alignment: .leading) {
                                Text("Bluetooth address")
                                    .modifier(SubsettingTitleStyle())
                                
                                Text(viewModel.mac)
                                    .modifier(SubsettingDescriptionStyle())
                                    .textCase(.uppercase)
                                    
                            }
                            .padding(.vertical, 6)
                            
                            VStack(alignment: .leading) {
                                Text("Serial number")
                                    .modifier(SubsettingTitleStyle())
                                
                                Text(viewModel.serial)
                                    .modifier(SubsettingDescriptionStyle())
                                    
                            }
                            .padding(.vertical, 6)
                            
                            VStack(alignment: .leading) {
                                Text("Firmware version")
                                    .modifier(SubsettingTitleStyle())
                                
                                Text(viewModel.firmware)
                                    .modifier(SubsettingDescriptionStyle())
                                    
                            }
                            .padding(.vertical, 6)
                            
                            Rectangle()
                                .fill(Color(#colorLiteral(red: 0.07009194046, green: 0.07611755282, blue: 0.08425947279, alpha: 1)))
                                .frame(height: 0.8)
                            
                            Text("About")
                                .modifier(SettingsSubsectionTitleStyle())
                            
                            NavigationLink("Supported devices", value: Destination.supported_devices)
                                .textCase(.uppercase)
                                .buttonStyle(FindMyTransparentButton())
                                .padding(.bottom, 8)
                           
                                
                        }
                        .toggleStyle(SwitchToggleStyle())
                        
                        Spacer()
                        
                        Button("Forget") {
                            withAnimation {
                                viewModel.shouldShowForgetDialog = true
                            }
                        }
                        .buttonStyle(GreyButtonLarge())
                        .focusable(false)
                        .padding(.vertical, 16)
                    }
                }
                .frame(width: 200)
                
                
                
            }
            .navigationBarBackButtonHidden(true)
            
            .background(.black)
            .frame(width: 250, height: 230)
            .onAppear {
                if let device = mainViewModel.nothingDevice {
                    viewModel.inEarSwitch = device.isInEarDetectionOn
                    viewModel.latencySwitch = device.isLowLatencyOn
                }
            }
            if viewModel.shouldShowForgetDialog {
                Color.black.opacity(0.4) // Background dimming
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            viewModel.shouldShowForgetDialog = false
                        }
                    }
                    .zIndex(2)
                
                ModalSheetComponent(isPresented: $viewModel.shouldShowForgetDialog, title: title, text: text, topButtonText: topButtonText, bottomButtonText: bottomButtonText, action: {
                    
                    
                    //notify app that there is no devices saved anymore
                    
                    withAnimation {
                        viewModel.forgetDevice()
                        viewModel.shouldShowForgetDialog = false
                    }

                }, onCancelAction: {})
                .animation(.easeInOut, value: viewModel.shouldShowForgetDialog) // Animate the appearance
                .offset(y: viewModel.shouldShowForgetDialog ? 0 : 180) // Slide in from the bottom
                .zIndex(2)
            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    @State private var viewModel = SettingsViewViewModel(nothingService: NothingServiceImpl.shared,
                                                         nothingRepository: NothingRepositoryImpl.shared)
    
    static var previews: some View {
        
        let mainViewModel = MainViewViewModel(
            fetchDataUseCase: FetchDataUseCase(service: NothingServiceImpl.shared),
            disconnectDeviceUseCase: DisconnectDeviceUseCase(nothingService: NothingServiceImpl.shared),
            getSavedDevicesUseCase: GetSavedDevicesUseCase(nothingRepository: NothingRepositoryImpl.shared),
            isBluetoothOnUseCase: IsBluetoothOnUseCase(bluetoothService: BluetoothServiceImpl()),
            isNothingConnectedUseCase: IsNothingConnectedUseCase(nothingService: NothingServiceImpl.shared),
            isLocalConfigEmptyUseCase: IsLocalConfigEmptyUseCase(nothingRepository: NothingRepositoryImpl.shared)
            
        )
        
        SettingsView()
            .environmentObject(mainViewModel)
    }
}
