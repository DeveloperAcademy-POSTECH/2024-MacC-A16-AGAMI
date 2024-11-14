//
//  DeleteAccountView.swift
//  AGAMI
//
//  Created by yegang on 11/4/24.
//

import SwiftUI

struct SignOutView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 25) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Color(.pPrimary))
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .fill(Color(.pWhite))
                        .frame(width: 82, height: 82)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 76, height: 76)
                        .foregroundStyle(Color(.pPrimary))
                }
                
                switch viewModel.deleteAccountProcess {
                case .inProgress:
                    Text("회원 탈퇴중입니다...")
                        .font(.pretendard(weight: .semiBold600, size: 24))
                        .foregroundStyle(Color(.pBlack))
                default:
                    Text("회원 탈퇴 완료!")
                        .font(.pretendard(weight: .semiBold600, size: 24))
                        .foregroundStyle(Color(.pBlack))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                UserDefaults.standard.removeObject(forKey: "isSignedIn")
                                coordinator.popToRoot()
                            }
                        }
                }
            }
        }
        .navigationTitle("")
        .disablePopGesture()
    }
}