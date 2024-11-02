//
//  SearchShazamingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/1/24.
//

import SwiftUI

struct SearchShazamingView: View {
    @State private var viewModel: SearchShazamingViewModel = SearchShazamingViewModel()
    
    var body: some View {
        ZStack {
            Color(viewModel.shazamStatus.backgroundColor)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    SearchShazamingView()
}
