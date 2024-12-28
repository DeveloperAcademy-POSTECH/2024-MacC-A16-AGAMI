//
//  Publisher+.swift
//  AGAMI
//
//  Created by 박현수 on 12/28/24.
//

import Combine

extension Publisher {
    /// Publisher의 single output을 async/await로 기다립니다.
    func asyncSingleOutput() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                cancellable?.cancel()
            }
            receiveValue: { value in
                continuation.resume(returning: value)
                cancellable?.cancel()
            }
        }
    }
}
