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
            Color(.sTitleText)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 44) {
                Image(.deleteViewIcon)
                    .resizable()
                    .frame(maxWidth: 72, maxHeight: 78)
                
                switch viewModel.deleteAccountProcess {
                case .none:
                    EmptyView()
                case .inProgress:
                    //TODO: - 로띠 넣고 spacing이랑 폰트, 색상 수정 해야 됨
                    VStack(alignment: .center, spacing: 0) {
                        Text("회원 탈퇴중...")
                            .font(.notoSansKR(weight: .semiBold600, size: 24))
                            .foregroundStyle(Color(.sMain))
                    }
                default:
                    VStack(alignment: .center, spacing: 14) {
                        Text("회원 탈퇴")
                            .font(.notoSansKR(weight: .semiBold600, size: 24))
                            .foregroundStyle(Color(.sMain))
                            .kerning(-0.43)
                        
                        Text("탈퇴가 완료되었습니다.")
                            .font(.notoSansKR(weight: .regular400, size: 17))
                            .foregroundStyle(Color(.sSubHead))
                            .kerning(-0.43)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            UserDefaults.standard.removeObject(forKey: "isSignedIn")
                            coordinator.dismissSheet()
                            coordinator.popToRoot()
                        }
                    }
                }
            }
        }
        .disablePopGesture()
    }
}
