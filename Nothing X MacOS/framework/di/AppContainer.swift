//  AppContainer.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/18.
//

import Foundation
import Swinject

class AppContainer {
    
    static let shared = AppContainer()
    let container: Container
    
    private init() {
        container = Container()
        setupDependencies()
    }
    
    private func setupDependencies() {
        registerServices()
        registerRepositories()
        registerUseCases()
        registerViewModels()
    }
    
    private func registerServices() {
        container.register(NothingService.self) { _ in NothingServiceImpl.shared }
        container.register(BluetoothService.self) { _ in BluetoothServiceImpl() }
    }
    
    private func registerRepositories() {
        container.register(NothingRepository.self) { _ in NothingRepositoryImpl.shared }
    }
    
    private func registerUseCases() {
        
        container.register(GetSavedDevicesUseCaseProtocol.self) { resolver in
            let nothingRepository = resolver.resolve(NothingRepository.self)
            return GetSavedDevicesUseCase(nothingRepository: nothingRepository!)
        }
        
        container.register(FetchDataUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return FetchDataUseCase(service: nothingService!)
        }
        
        container.register(DisconnectDeviceUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return DisconnectDeviceUseCase(nothingService: nothingService!)
        }
        
        container.register(IsBluetoothOnUseCaseProtocol.self) { resolver in
            let bluetoothService = resolver.resolve(BluetoothService.self)
            return IsBluetoothOnUseCase(bluetoothService: bluetoothService!)
        }
        
        container.register(IsNothingConnectedUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return IsNothingConnectedUseCase(nothingService: nothingService!)
        }
        
        container.register(IsLocalConfigEmptyUseCaseProtocol.self) { resolver in
            let nothingRepository = resolver.resolve(NothingRepository.self)
            return IsLocalConfigEmptyUseCase(nothingRepository: nothingRepository!)
        }
        
        container.register(ConnectToNothingUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return ConnectToNothingUseCase(nothingService: nothingService!)
        }
        
        container.register(SwitchControlsUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return SwitchControlsUseCase(nothingService: nothingService!)
        }
        
        container.register(DiscoverNothingUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return DiscoverNothingUseCase(nothingService: nothingService!)
        }
        
        container.register(StopNothingDiscoveryUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)
            return StopNothingDiscoveryUseCase(nothingService: nothingService!)
        }
        
        container.register(SwitchEqUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return SwitchEqUseCase(service: nothingService)
        }
        
        container.register(SwitchInEarDetectionUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return SwitchInEarDetectionUseCase(nothingService: nothingService)
        }
        
        container.register(RingBudsUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return RingBudsUseCase(nothingService: nothingService)
        }
        
        container.register(StopRingingBudsUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return StopRingingBudsUseCase(nothingService: nothingService)
        }
        
        container.register(DeleteSavedUseCaseProtocol.self) { resolver in
            let nothingRepository = resolver.resolve(NothingRepository.self)!
            return DeleteSavedDeviceUseCase(nothingRepository: nothingRepository)
        }
        
        container.register(SwitchAncUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return SwitchAncUseCase(service: nothingService)
        }
        
        container.register(SwitchLatencyUseCaseProtocol.self) { resolver in
            let nothingService = resolver.resolve(NothingService.self)!
            return SwitchLatencyUseCase(nothingService: nothingService)
        }
    }
    
    private func registerViewModels() {
        
        container.register(MainViewViewModel.self) { resolver in
            let fetchDataUseCase = resolver.resolve(FetchDataUseCaseProtocol.self)!
            let disconnectDeviceUseCase = resolver.resolve(DisconnectDeviceUseCaseProtocol.self)!
            let getSavedDevicesUseCase = resolver.resolve(GetSavedDevicesUseCaseProtocol.self)!
            let isBluetoothOnUseCase = resolver.resolve(IsBluetoothOnUseCaseProtocol.self)!
            let isNothingConnectedUseCase = resolver.resolve(IsNothingConnectedUseCaseProtocol.self)!
            let isLocalConfigEmptyUseCase = resolver.resolve(IsLocalConfigEmptyUseCaseProtocol.self)!
            
            return MainViewViewModel(
                fetchDataUseCase: fetchDataUseCase,
                disconnectDeviceUseCase: disconnectDeviceUseCase,
                getSavedDevicesUseCase: getSavedDevicesUseCase,
                isBluetoothOnUseCase: isBluetoothOnUseCase,
                isNothingConnectedUseCase: isNothingConnectedUseCase,
                isLocalConfigEmptyUseCase: isLocalConfigEmptyUseCase
            )
        }
        
        container.register(ConnectViewViewModel.self) { resolver in
            let getSavedDevicesUseCase = resolver.resolve(GetSavedDevicesUseCaseProtocol.self)!
            let isBluetoothOnUseCase = resolver.resolve(IsBluetoothOnUseCaseProtocol.self)!
            let connectToNothingUseCase = resolver.resolve(ConnectToNothingUseCaseProtocol.self)!
            
            return ConnectViewViewModel(
                isBluetoothOnUseCase: isBluetoothOnUseCase,
                connectToNothingUseCase: connectToNothingUseCase,
                getSavedDevicesUseCase: getSavedDevicesUseCase
            )
        }
        
        container.register(ControlsDetailViewViewModel.self) { resolver in
            let switchControlsUseCase = resolver.resolve(SwitchControlsUseCaseProtocol.self)!
            return ControlsDetailViewViewModel(switchControlsUseCase: switchControlsUseCase)
        }
        
        container.register(DiscoveryViewViewModel.self) { resolver in
            let isBluetoothOnUseCase = resolver.resolve(IsBluetoothOnUseCaseProtocol.self)!
            return DiscoveryViewViewModel(isBluetoothOnUseCase: isBluetoothOnUseCase)
        }
        
        container.register(DiscoveryStartedViewViewModel.self) { resolver in
            let discoverNothingUseCase = resolver.resolve(DiscoverNothingUseCaseProtocol.self)!
            let connectToNothingUseCase = resolver.resolve(ConnectToNothingUseCaseProtocol.self)!
            let isNothingConnectedUseCase = resolver.resolve(IsNothingConnectedUseCaseProtocol.self)!
            let stopNothingDiscoveryUseCase = resolver.resolve(StopNothingDiscoveryUseCaseProtocol.self)!
            let isBluetoothOnUseCase = resolver.resolve(IsBluetoothOnUseCaseProtocol.self)!
            
            return DiscoveryStartedViewViewModel(
                discoverNothingUseCase: discoverNothingUseCase,
                connectToNothingUseCase: connectToNothingUseCase,
                isNothingConnectedUseCase: isNothingConnectedUseCase,
                stopNothingDiscoveryUseCase: stopNothingDiscoveryUseCase,
                isBluetoothConnectedUseCase: isBluetoothOnUseCase
            )
        }
        
        container.register(EqualizerViewViewModel.self) { resolver in
            let switchEqUseCase = resolver.resolve(SwitchEqUseCaseProtocol.self)!
            return EqualizerViewViewModel(switchEqUseCase: switchEqUseCase)
        }
        
        container.register(FindMyBudsViewViewModel.self) { resolver in
            let ringBudsUseCase = resolver.resolve(RingBudsUseCaseProtocol.self)!
            let stopRingingBudsUseCase = resolver.resolve(StopRingingBudsUseCaseProtocol.self)!
            
            return FindMyBudsViewViewModel(
                ringBudsUseCase: ringBudsUseCase,
                stopRingingBudsUseCase: stopRingingBudsUseCase
            )
        }
        
        container.register(NoiseControlViewViewModel.self) { resolver in
            let switchAncUseCase = resolver.resolve(SwitchAncUseCaseProtocol.self)!
            return NoiseControlViewViewModel(switchAncUseCase: switchAncUseCase)
        }
        
        container.register(SettingsViewViewModel.self) { resolver in
            let switchLatencyUseCase = resolver.resolve(SwitchLatencyUseCaseProtocol.self)!
            let switchInEarDetectionUseCase = resolver.resolve(SwitchInEarDetectionUseCaseProtocol.self)!
            let deleteSavedUseCase = resolver.resolve(DeleteSavedUseCaseProtocol.self)!
            let getSavedDevicesUseCase = resolver.resolve(GetSavedDevicesUseCaseProtocol.self)!
            let isNothingConnectedUseCase = resolver.resolve(IsNothingConnectedUseCaseProtocol.self)!
            
            return SettingsViewViewModel(
                switchLatencyUseCase: switchLatencyUseCase,
                switchInEarDetectionUseCase: switchInEarDetectionUseCase,
                deleteSavedDeviceUseCase: deleteSavedUseCase,
                getSavedDevicesUseCase: getSavedDevicesUseCase,
                isNothingConnectedUseCase: isNothingConnectedUseCase
            )
        }
    }
}
