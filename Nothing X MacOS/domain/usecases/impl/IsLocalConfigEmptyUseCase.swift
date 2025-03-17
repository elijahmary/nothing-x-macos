//
//  IsLocalConfigEmptyUseCase.swift
//  Nothing X MacOS
//
//  Created by Daniel on 2025/3/16.
//

import Foundation

class IsLocalConfigEmptyUseCase : IsLocalConfigEmptyUseCaseProtocol {
    
    private let nothingRepository: NothingRepository
    
    init(nothingRepository: NothingRepository) {
        self.nothingRepository = nothingRepository
    }
    
    func isEmpty() -> Bool {
        return nothingRepository.isEmpty()
    }
    
}
