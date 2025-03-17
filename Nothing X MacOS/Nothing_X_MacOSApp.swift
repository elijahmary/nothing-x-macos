
import SwiftUI


@main
struct Nothing_X_MacOSApp: App {
    
    @StateObject private var store = Store()
    @StateObject private var viewModel = MainViewViewModel(
        
        fetchDataUseCase: FetchDataUseCase(service: NothingServiceImpl.shared),
        disconnectDeviceUseCase: DisconnectDeviceUseCase(nothingService: NothingServiceImpl.shared),
        getSavedDevicesUseCase: GetSavedDevicesUseCase(nothingRepository: NothingRepositoryImpl.shared),
        isBluetoothOnUseCase: IsBluetoothOnUseCase(bluetoothService: BluetoothServiceImpl()),
        isNothingConnectedUseCase: IsNothingConnectedUseCase(nothingService: NothingServiceImpl.shared),
        isLocalConfigEmptyUseCase: IsLocalConfigEmptyUseCase(nothingRepository: NothingRepositoryImpl.shared)
        
    )
    @StateObject private var budsPickerViewModel = BudsPickerComponentViewModel()

    var body: some Scene {
        MenuBarExtra {
            NavigationStack(path: $viewModel.navigationPath.animation(.default)) {
                
                ConnectView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch(destination) {
                        case .home: HomeView()
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .equalizer: EqualizerView(eqMode: $viewModel.eqProfiles)
                        case .controls: ControlsView()
                        case .controlsTripleTap: ControlsDetailView(destination: .controlsTripleTap, leftTripleTapAction: $viewModel.leftTripleTapAction, rightTripleTapAction: $viewModel.rightTripleTapAction, leftTapAndHoldAction: $viewModel.leftTapAndHoldAction, rightTapAndHoldAction: $viewModel.rightTapAndHoldAction)
                        case .controlsTapHold: ControlsDetailView(destination: .controlsTapHold,
                                                                  leftTripleTapAction: $viewModel.leftTripleTapAction, rightTripleTapAction: $viewModel.rightTripleTapAction, leftTapAndHoldAction: $viewModel.leftTapAndHoldAction, rightTapAndHoldAction: $viewModel.rightTapAndHoldAction
                        )
                        case .settings: SettingsView()
                        case .findMyBuds: FindMyBudsView()
                        case .discover: DiscoveryView()
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .connect: ConnectView()
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .discover_started: DiscoveryStartedView()
                        case .bluetooth_off: BluetoothIsOffView()
                            
                        case .supported_devices: SupportedDevicesView()
                            
                        }
                        
                        
                    }
                    
            }
            .environmentObject(store)
            .environmentObject(viewModel)
            .environmentObject(budsPickerViewModel)
            .frame(width: 250, height: 230)
        
            
        } label: {
            
            Label(viewModel.batteryPercentage, image: "nothing.ear.1")
                .labelStyle(.titleAndIcon)
            
        }
        .menuBarExtraStyle(.window)
        
    }
}
