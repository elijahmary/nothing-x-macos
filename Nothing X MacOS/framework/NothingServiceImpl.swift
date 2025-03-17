//
//  NothingController.swift
//  BluetoothTest
//
//  Created by Daniel on 2025/2/13.
//
import Combine
import Foundation
import os


private struct Request {
    let command: Commands
    let operationID: UInt8
    let payload: [UInt8]
    let completion: (Result<Void, Error>) -> Void
    let requestTimeout: TimeInterval
    let responseTimeout: TimeInterval
    var retryCount: Int = 0 // Track the number of retries
}

class NothingServiceImpl: NothingService {
    
    private let logger = Logger(subsystem: "com.eldandelion.Nothing-X-MacOS", category: "nothing service")
    
    static let shared = NothingServiceImpl()
    
    private lazy var cancellables = Set<AnyCancellable>()
    private let bluetoothManager = BluetoothManager.shared
    private lazy var currentRequest: Request? = nil
    
    // A queue to hold requests
    private lazy var requestQueue: [Request] = []
    // A semaphore to control access to the queue
    private let queueSemaphore = DispatchSemaphore(value: 1)
    private let maxRetries = 3
    // A flag to indicate if a request is currently being processed
    private var isProcessing = false
    
    private lazy var nothingDevice: NothingDeviceFDTO? = nil
    private var hasFailedRequests = false
    
    private init() {
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(BluetoothNotifications.CONNECTED.rawValue),
            object: nil,
            queue: .main,
            using: handleDeviceConnectedNotification(_:)
        )
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(BluetoothNotifications.DATA_RECEIVED.rawValue),
            object: nil,
            queue: .main,
            using: handleDataReceivedNotification(_:)
        )
    
        
    }
    
    
    @objc private func handleDataReceivedNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo, let data = userInfo["data"] as? [UInt8], data.isValid() {
            
            logger.info("Data received in Nothing Service: \(data)")
            
            do {
                try routeDataAndSave(rawData: data)
            } catch ArrayErrors.invalidArray(let message) {
                logger.critical("\(message)")
            } catch {
                logger.critical("An unexpected error occurred: \(error.localizedDescription)")
            }
            
            
            if let currentRequest = currentRequest,
               getOperationIdFrom(rawData: data)
                .isMatching(requestID: currentRequest.operationID)
            {
                currentRequest.completion(.success(()))
                processNextRequest()
            } else {
                handleResponseResults()
            }
            
        } else {
            logger.critical("Received data is invalid")
        }
        
    }
    
    @objc private func handleDeviceConnectedNotification(_ notification: Notification) {
        if let device = notification.object as? BluetoothDeviceEntity {
            nothingDevice = NothingDeviceFDTO(bluetoothDetails: device)
            logger.info("Nothing Device object has been created: \(self.nothingDevice?.name ?? "Unknown")")
            
            NotificationCenter.default.post(name: Notification.Name(NothingServiceNotifications.CONNECTED.rawValue), object: nothingDevice)
        }
    }
    
    private func getOperationIdFrom(rawData: [UInt8]) -> UInt8 {
        let idIndex = 7
        return rawData[idIndex]
    }
    
    func switchGesture(device: GestureDeviceType, gesture: GestureType, action: UInt8) {
        
        let payload: [UInt8] = [0x01, device.rawValue, 0x01, gesture.rawValue, action]
        
        addRequest(
            
            command: Commands.SET_GESTURE,
            operationID: Commands.SET_GESTURE.firstEightBits,
            requestTimeout: 1000,
            responseTimeout: 1000,
            payload: payload
            
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                logger.info("Successfully switched gesture settings")
                do {
                    try setGestureConfigs(deviceType: device, gestureType: gesture, action: action)
                } catch Errors.invalidArgument(let message) {
                    logger.error("\(message)")
                } catch {
                    logger.error("An unexpected error occurred: \(error.localizedDescription)")
                }
            case .failure(let error):
                logger.error("Failed to switch gesture settings: \(error.localizedDescription)")
            }
        }
    }
    
    func stopNothingDiscovery() {
        bluetoothManager.stopDeviceInquiry()
    }
    
    func switchLatency(mode: Bool) {
        
        var array: [UInt8] = [0x02, 0x00]
        if mode {
            array[0] = 0x01
        }
        
        addRequest(
            
            command: Commands.SET_LATENCY,
            operationID: Commands.SET_LATENCY.firstEightBits,
            requestTimeout: 1000,
            responseTimeout: 1000,
            payload: array
        
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                logger.info("Successfully changed latency settings \(mode)")
                nothingDevice?.isLowLatencyOn = mode
            case .failure(let error):
                logger.error("Failed to change latency settings: \(error.localizedDescription)")
            }
        }
        
    }
    
    func switchInEarDetection(mode: Bool) {
        
        var array: [UInt8] = [0x01, 0x01, 0x00]
        
        if mode {
            array[2] = 0x01
        }
        
        addRequest(
            
            command: Commands.SET_IN_EAR_STATUS,
            operationID: Commands.SET_IN_EAR_STATUS.firstEightBits,
            requestTimeout: 1000,
            responseTimeout: 1000,
            payload: array
            
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                logger.info("Successfully changed in-ear detection to \(mode)")
                nothingDevice?.isInEarDetectionOn = mode
            case .failure(let error):
                logger.error("Failed to change in-ear detection: \(error.localizedDescription)")
            }
        }
    }
    
    func ringBuds() {
        setRingBuds(right: true, left: true, doRing: true)
    }
    
    func stopRingingBuds() {
        setRingBuds(right: true, left: true, doRing: false)
    }
    
    func switchANC(mode: ANC) {
        
        let byteArray: [UInt8] = [0x01, mode.rawValue, 0x00]
        
        logger.info("Setting ANC with byte array: \(byteArray)")
        
        addRequest(
            
            command: Commands.SET_ANC,
            operationID: Commands.SET_ANC.firstEightBits,
            requestTimeout: 1000,
            responseTimeout: 1000,
            payload: byteArray
            
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                logger.info("Successfully changed ANC settings")
                nothingDevice?.anc = mode
            case .failure(let error):
                logger.error("Failed to change ANC settings: \(error.localizedDescription)")
            }
        }
    }
    
    func switchEQ(mode: EQProfiles) {
        
        let byteArray: [UInt8] = [mode.rawValue, 0x00]
        
        addRequest(
            
            command: Commands.SET_EQ,
            operationID: Commands.SET_EQ.firstEightBits,
            requestTimeout: 1000,
            responseTimeout: 1000,
            payload: byteArray
            
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                logger.info("Successfully changed EQ settings")
                nothingDevice?.listeningMode = mode
            case .failure(let error):
                logger.error("Failed to change EQ settings: \(error.localizedDescription)")
            }
        }
    }
    
    func connectToNothing(device: BluetoothDeviceEntity) {
        bluetoothManager.connectToDevice(address: device.mac, channelID: device.channelId)
    }
    
    func disconnect() {
        bluetoothManager.disconnectDevice()
        self.nothingDevice = nil
    }
    
    func discoverNothing() {
        
        let classOfNothing = BluetoothDeviceClass.CLASS_OF_NOTHING.rawValue
        let pairedDevices = bluetoothManager.getPaired(withClass: Int(classOfNothing))
        let connectedPaired = pairedDevices.filter({ $0.isConnected })
        
        for device in connectedPaired {
            NotificationCenter.default.post(name: Notification.Name(NothingServiceNotifications.FOUND.rawValue), object: device, userInfo: nil)
        }
        
        bluetoothManager.startDeviceInquiry(withClass: classOfNothing)
        
    }
    
    func isNothingConnected() -> BluetoothDeviceEntity? {
        return nothingDevice?.bluetoothDetails
    }
    
    func isNothingConnected() -> Bool {
        return bluetoothManager.isDeviceConnected()
    }
    
    func connectToNothing(address: String) {
        #warning("could be invalid mac address")
        #warning("could be invalid channelID")
        bluetoothManager.connectToDevice(address: address, channelID: 15)
    }
    
#warning("there is a change that device gets disconnected during transfer but it is low since it takes less than a second to fetch the data will fix it in the future")
    func fetchData() {
        
        logger.info("Fetching data")
        
        if isNothingConnected() {
            
            logger.info("Adding request")
            
            addRequest(
                
                command: Commands.GET_SERIAL_NUMBER,
                operationID: Commands.GET_SERIAL_NUMBER.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
                
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched serial number.")
                case .failure(let error):
                    logger.error("Failed to fetch serial number: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_FIRMWARE,
                operationID: Commands.GET_FIRMWARE.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
                
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched firmware number.")
                case .failure(let error):
                    logger.error("Failed to fetch firmware number: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_BATTERY,
                operationID: Commands.GET_BATTERY.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
                
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched battery settings.")
                case .failure(let error):
                    logger.error("Failed to fetch battery settings: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_ANC,
                operationID: Commands.GET_ANC.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
                
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched ANC settings.")
                case .failure(let error):
                    logger.error("Failed to fetch ANC settings: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_EQ,
                operationID: Commands.GET_EQ.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
            
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched EQ settings.")
                case .failure(let error):
                    logger.error("Failed to fetch EQ: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_LATENCY,
                operationID: Commands.GET_LATENCY.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
            
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched latency settings.")
                case .failure(let error):
                    logger.error("Failed to fetch latency settings: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_IN_EAR_STATUS,
                operationID: Commands.GET_IN_EAR_STATUS.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
            
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched in-ear status.")
                case .failure(let error):
                    logger.error("Failed to fetch in-ear status: \(error.localizedDescription)")
                }
            }
            
            addRequest(
                
                command: Commands.GET_GESTURES,
                operationID: Commands.GET_GESTURES.firstEightBits,
                requestTimeout: 1000,
                responseTimeout: 1000
            
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    logger.info("Successfully fetched gestures.")
                case .failure(let error):
                    logger.error("Failed to fetch gestures: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func send(command: Commands, operationID: UInt8, payload: [UInt8] = []) {
        var header: [UInt8] = [0x55, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        header[7] = UInt8(operationID)
        logger.info("Operation being sent is \(operationID)")
        
        // Convert command to bytes
        let commandBytes = withUnsafeBytes(of: command.rawValue.bigEndian) { Array($0) }
        header[3] = commandBytes[0]
        header[4] = commandBytes[1]
        
        let payloadLength = UInt8(payload.count)
        header[5] = payloadLength
        
        // Append payload to header
        header.append(contentsOf: payload)
        
        // Calculate CRC
        let crc = CRC16.crc16(buffer: header)
        header.append(UInt8(crc & 0xFF)) // Append low byte
        header.append(UInt8((crc >> 8) & 0xFF))
        
        // Send the data
        bluetoothManager.send(data: &header, length: UInt16(header.count))
    }
    
    
    // Function to get the current request being processed
    private func getCurrentRequest() -> Request? {
        queueSemaphore.wait()
        defer { queueSemaphore.signal() }
        return requestQueue.first // Return the first request in the queue
    }
    
    private func handleResponseResults() {
        
    
        if hasFailedRequests {
            
            self.logger.info("Failed some of the requests.")
            
            NotificationCenter.default.post(
                
                name: Notification.Name(NothingServiceNotifications.DATA_UPDATE_FAIL.rawValue),
                object: nil,
                userInfo: nil
            )
            
        } else {
            self.logger.info("All requests have been processed. Sending data to the user.")
            
            if let nothingDevice = nothingDevice {
            
                let nothingDeviceEntity = NothingDeviceFDTO.toEntity(nothingDevice)
                
                NotificationCenter.default.post(
                    
                    name: Notification.Name(NothingServiceNotifications.DATA_UPDATE_SUCCESS.rawValue),
                    object: nothingDeviceEntity,
                    userInfo: nil
                )
            }
            
        }
    }
    
    // Function to process requests in the queue
    private func processNextRequest() {
        logger.info("Log queue: processing next request")
        queueSemaphore.wait()
        
        // Check if there are requests in the queue
        guard !requestQueue.isEmpty else {
            logger.info("Log queue: queue is empty")
            isProcessing = false
            queueSemaphore.signal()
            
            handleResponseResults()
            hasFailedRequests = false
          
            return
        }
        
        // Get the next request from the queue
        var request = requestQueue.removeFirst()
        currentRequest = request
        logger.info("Log queue: first request in queue is \(request.operationID)")
        isProcessing = true
        queueSemaphore.signal()
        
        // Set a timeout for the request
        let requestTimeout = DispatchTime.now() + request.requestTimeout
        DispatchQueue.global().asyncAfter(deadline: requestTimeout) { [weak self] in
            guard let self = self else { return }
            if self.isProcessing {
                logger.info("Request timed out, attempting to repeat")
                // Increment the retry count
                request.retryCount += 1
                
                // Check if the retry count exceeds the maximum allowed
                if request.retryCount <= self.maxRetries {
                    // Re-add the request to the queue
                    self.queueSemaphore.wait()
                    self.requestQueue.append(request) // Re-add the request
                    self.queueSemaphore.signal()
                    
                    // Call the completion handler with a timeout error
                    request.completion(.failure(DeviceError.timeoutError("Request timed out.")))
                    self.isProcessing = false
                    
                    // Process the next request
                    self.processNextRequest()
                } else {
                    // Handle the case where the maximum retries have been reached
                    logger.info("Maximum retries reached for request. Not re-adding to queue.")
                    request.completion(.failure(DeviceError.timeoutError("Maximum retries reached.")))
                    self.isProcessing = false
                    self.hasFailedRequests = true
                    
                    // Process the next request
                    self.processNextRequest()
                }
            }
        }
        
        // Send the command and handle the response
        send(command: request.command, operationID: request.operationID, payload: request.payload)
    }
    
    // Function to add a request to the queue
    private func addRequest(command: Commands, operationID: UInt8, requestTimeout: TimeInterval, responseTimeout: TimeInterval, payload: [UInt8] = [], completion: @escaping (Result<Void, Error>) -> Void) {
        
        let requestTimeoutInSeconds = TimeInterval(requestTimeout) / 1000.0
        let responseTimeoutInSeconds = TimeInterval(responseTimeout) / 1000.0
        
        let request = Request(command: command, operationID: operationID, payload: payload, completion: completion, requestTimeout: requestTimeoutInSeconds, responseTimeout: responseTimeoutInSeconds)
        
        queueSemaphore.wait()
        requestQueue.append(request) // Append the request to the queue
        queueSemaphore.signal()
        
        // Start processing if not already processing
        if !isProcessing {
            hasFailedRequests = false
            processNextRequest()
        }
    }
    
    
    private func setRingBuds(right: Bool, left: Bool, doRing: Bool) {
        
        let leftShouldRing: UInt8 = 0x02
        let leftShouldNotRing: UInt8 = 0x03
        let rightShouldRing: UInt8 = 0x01
        let rightShouldNotRing: UInt8 = 0x00
        
        var payload: [UInt8] = [0x00]
        
        if nothingDevice?.codename == Codenames.ONE {
            
            payload[0] = doRing ? 0x01 : 0x00
            
        } else {
            
            payload = [0x00, 0x00]
            
            payload[0] = left ? leftShouldRing : leftShouldNotRing
            payload[1] = right ? rightShouldRing : rightShouldNotRing
        }
        
        addRequest(command: Commands.SET_RING_BUDS, operationID: Commands.SET_RING_BUDS.firstEightBits, requestTimeout: 1000, responseTimeout: 1000, payload: payload, completion: {_ in })
        
    }
    
    
    
    private func routeDataAndSave(rawData: [UInt8]) throws {
        
        guard rawData.isValid() else {
            throw ArrayErrors.invalidArray("Provided array is invalid")
        }
        
        let header = Array(rawData[0..<6])
        let command = getCommand(header: header)
        
        switch command {
            
        case Commands.READ_FIRMWARE.rawValue:
            let firmware = NothingServiceImpl.readFirmware(hexArray: rawData, logger: logger)
            nothingDevice?.firmware = firmware
            saveSKU()
            saveCodename()
            
        case Commands.READ_SERIAL_NUMBER.rawValue:
            do {
                let serial = try NothingServiceImpl.readSerial(hexArray: rawData, logger: logger)
                if !serial.isEmpty {
                    nothingDevice?.serial = serial
                    nothingDevice?.sku = skuFromSerial(serial: serial)
                }
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            }

            
        case Commands.READ_ANC_ONE.rawValue,
            Commands.READ_ANC_TWO.rawValue:
            do {
                
                let anc = try NothingServiceImpl.readANC(hexArray: rawData, logger: logger)
                nothingDevice?.anc = anc
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            } catch Errors.invalidArgument(let message) {
                logger.critical("\(message)")
            }
            
        case Commands.READ_EQ_ONE.rawValue,
            Commands.READ_EQ_TWO.rawValue:
            do {
                
                let eq = try NothingServiceImpl.readEQ(hexArray: rawData, logger: logger)
                nothingDevice?.listeningMode = eq
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            } catch Errors.invalidArgument(let message) {
                logger.critical("\(message)")
            }
            
            
        case Commands.READ_BATTERY_ONE.rawValue,
            Commands.READ_BATTERY_TWO.rawValue,
            Commands.READ_BATTERY_THREE.rawValue:
            do {
                
                let configurations = try NothingServiceImpl.readBattery(hexArray: rawData, logger: logger)
                saveBatteryConfigs(configs: configurations)
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
                
            }
            
        case Commands.READ_LATENCY.rawValue:
            do {
                let latency = try NothingServiceImpl.readLatencyMode(hexArray: rawData, logger: logger)
                nothingDevice?.isLowLatencyOn = latency
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            } catch Errors.invalidArgument(let message) {
                logger.critical("\(message)")
            }
            
            
        case Commands.READ_IN_EAR_MODE.rawValue:
            do {
                let inEarMode = try NothingServiceImpl.readInEarDetection(hexArray: rawData, logger: logger)
                nothingDevice?.isInEarDetectionOn = inEarMode
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            }
       
            
        case Commands.READ_GESTURES.rawValue:
            
            do {
                let gestures = try NothingServiceImpl.readGestures(hexArray: rawData, logger: logger)
                
                for gesture in gestures {
                    do {
                        try setGestureConfigs(deviceType: gesture.0, gestureType: gesture.1, action: gesture.2)
                    } catch {
                        logger.critical("An unexpected error occurred: \(error.localizedDescription)")
                    }
                }
                
            } catch ArrayErrors.rangeError(let message) {
                logger.critical("\(message)")
            }
      
         
        default:
            logger.warning("Unhandled command \(command)")
        }
    }
    
    private func saveSKU() {
        if nothingDevice?.sku == SKU.UNKNOWN, let firmware = nothingDevice?.firmware {
            nothingDevice?.sku = skuFromFirmware(firmware: firmware)
        }
    }
    
    private func saveCodename() {
        guard let sku = nothingDevice?.sku else {
            return
        }
        nothingDevice?.codename = codenameFromSKU(sku: sku)
    }
    
    private func saveBatteryConfigs(configs: [(deviceType: BatteryDeviceType, batteryLevel: Int, isConnected: Bool, isCharging: Bool)]) {
        
        for configuration in configs {
            
            switch configuration.deviceType {
            case .LEFT:
                nothingDevice?.leftBattery = configuration.batteryLevel
                nothingDevice?.isLeftCharging = configuration.isCharging
                nothingDevice?.isLeftConnected = configuration.isConnected
                
            case .RIGHT:
                nothingDevice?.rightBattery = configuration.batteryLevel
                nothingDevice?.isRightCharging = configuration.isCharging
                nothingDevice?.isRightConnected = configuration.isConnected
                
            case .CASE:
                nothingDevice?.caseBattery = configuration.batteryLevel
                nothingDevice?.isCaseCharging = configuration.isCharging
                nothingDevice?.isCaseConnected = configuration.isConnected
            }
        }
        
    }
    
    
    private func setGestureConfigs(deviceType: GestureDeviceType, gestureType: GestureType, action: UInt8) throws {
        if deviceType == .LEFT {
            if gestureType == .TAP_AND_HOLD {
                guard let actionValue = TapAndHoldGestureActions(rawValue: action) else {
                    throw Errors.invalidArgument("In setGestureInNothing invalid argument \(action)")
                }
                nothingDevice?.tapAndHoldGestureActionLeft = actionValue
            } else if gestureType == .TRIPLE_TAP {
                guard let actionValue = TripleTapGestureActions(rawValue: action) else {
                    throw Errors.invalidArgument("In setGestureInNothing invalid argument \(action)")
                }
                nothingDevice?.tripleTapGestureActionLeft = actionValue
            }
        } else if deviceType == .RIGHT {
            if gestureType == .TAP_AND_HOLD {
                guard let actionValue = TapAndHoldGestureActions(rawValue: action) else {
                    throw Errors.invalidArgument("In setGestureInNothing invalid argument \(action)")
                }
                nothingDevice?.tapAndHoldGestureActionRight = actionValue
            } else if gestureType == .TRIPLE_TAP {
                guard let actionValue = TripleTapGestureActions(rawValue: action) else {
                    throw Errors.invalidArgument("In setGestureInNothing invalid argument \(action)")
                }
                nothingDevice?.tripleTapGestureActionRight = actionValue
            }
        }
    }
    
    private func getCommand(header: [UInt8]) -> UInt16 {
        
        logger.debug("header: \(header)")
        
        let commandBytes = Array(header[3..<5])
        logger.debug("commandBytes: \(commandBytes)")
        
        let commandInt = (UInt16(commandBytes[0]) | (UInt16(commandBytes[1]) << 8))
        logger.debug("commandInt: \(commandInt)")
        
        return commandInt
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension String {
    var nonEmpty: String? {
        return isEmpty ? nil : self
    }
}

extension Array where Element == UInt8 {
    func isValid() -> Bool {
        return self.count >= 8 && self[0] == 0x55
    }
}

extension UInt8 {
    func isMatching(requestID: UInt8) -> Bool {
        return self == requestID
    }
}
