//
//  SearchStartViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation

@Observable
final class SearchStartViewModel {
    var searchButtonToggle: Bool = false
    
    func searchButtonTapped() {
        searchButtonToggle.toggle()
        
        // 샤잠 시작
    }
}
