//
//  DeleteAccountView.swift
//  AGAMI
//
//  Created by yegang on 11/4/24.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            Color(viewModel.deleteAccountProcess == .finished ? .sTitleText : .sMain)
            
            switch viewModel.deleteAccountProcess {
            case .none:
                EmptyView()
            case .inProgress:
                VStack(alignment: .center, spacing: 44) {
                    CustomLottieView(.deleting)
                        .frame(height: 67)
                    
                    Text("회원 탈퇴중...")
                        .font(.notoSansKR(weight: .semiBold600, size: 24))
                        .foregroundStyle(Color(.sTitleText))
                }
                .ignoresSafeArea(.all)
            default:
                VStack(alignment: .center, spacing: 44) {
                    Image(.deleteViewIcon)
                        .resizable()
                        .frame(maxWidth: 72, maxHeight: 78)
                    
                    VStack(spacing: 14) {
                        Text("회원 탈퇴")
                            .font(.notoSansKR(weight: .semiBold600, size: 24))
                            .foregroundStyle(Color(.sMain))
                            .kerning(-0.43)
                        
                        Text("탈퇴가 완료되었습니다.")
                            .font(.notoSansKR(weight: .regular400, size: 17))
                            .foregroundStyle(Color(.sSubHead))
                            .kerning(-0.43)
                    }
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        await MainActor.run {
                            UserDefaults.standard.removeObject(forKey: "isSignedIn")
                            coordinator.dismissSheet()
                            coordinator.popToRoot()
                        }
                    }
                }
                .ignoresSafeArea(.all)
            }
        }
        .disablePopGesture()
    }
}

