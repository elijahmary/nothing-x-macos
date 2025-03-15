//
//  Errors.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/12.
//

import Foundation

enum Errors: Error, Equatable {
    case invalidArgument(String)
}

enum ArrayErrors: Error, Equatable {
    case rangeError(String)
    case invalidArray(String)
}

enum DeviceError: Error, Equatable {
    case responseError(String)
    case timeoutError(String)
}
