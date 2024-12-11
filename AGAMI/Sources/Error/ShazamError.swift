//
//  ShazamError.swift
//  AGAMI
//
//  Created by 박현수 on 12/9/24.
//

import Foundation

enum ShazamError: Error {
    case isRunning
    case didNotFindMatch
    case didFail
    case cancelled
}
