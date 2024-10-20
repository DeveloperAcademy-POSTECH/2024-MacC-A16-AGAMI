//
//  SearchPlayListFullscreenVIew.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/20/24.
//

import SwiftUI

struct SearchPlayListFullscreenVIew: View {
    @Environment(SearchCoordinator.self) var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SearchPlayListFullscreenVIew(viewModel: .init())
}
