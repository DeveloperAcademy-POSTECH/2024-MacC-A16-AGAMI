//
//  AccountView.swift
//  AGAMI
//
//  Created by yegang on 11/19/24.
//

import SwiftUI

struct AccountView: View {
    @State private var viewModel: AccountViewModel = .init()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SologCoordinator.self) private var coordinator
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if case .none = viewModel.deleteAccountProcess {
                    ContentView(viewModel: viewModel)
                } else {
                    DeleteAccountView(viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        if viewModel.deleteAccountProcess == .none {
                            Text("닫기")
                                .font(.notoSansKR(weight: .regular400, size: 17))
                                .foregroundStyle(Color(.sButton))
                        }
                    }
                }
            }
            .navigationTitle("계정 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.sWhiteBack), for: .navigationBar)
            .ignoresSafeArea(edges: .bottom)
            .alert("로그아웃", isPresented: $viewModel.isShowingSignOutAlert) {
                SignOutAlertActions(viewModel: viewModel)
            } message: {
                Text("로그아웃을 진행하시겠어요?\n이전에 기록한 데이터는 유지됩니다.")
                    .font(.notoSansKR(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.sBodyText))
            }
            .alert("회원 탈퇴", isPresented: $viewModel.isShowingDeleteAccountAlert) {
                DeleteAccountAlertActions(viewModel: viewModel)
            } message: {
                Text("회원 탈퇴 시 모든 기록이 삭제되고\n복구할 수 없습니다.")
                    .font(.notoSansKR(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.sBodyText))
            }
        }
    }
}

private struct ContentView: View {
    @Environment(\.openURL) private var openURL
    let viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            Color(.sMain)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 14) {
                    Button {
                        if let url = viewModel.termsOfServiceURL {
                            openURL(url)
                        } else {
                            dump("잘못된 URL입니다.")
                        }
                    } label: {
                        ButtonLabel(type: .termsOfService)
                    }
                    
                    Button {
                        viewModel.isShowingDeleteAccountAlert.toggle()
                    } label: {
                        ButtonLabel(type: .deleteAccount)
                    }
                }
                
                Button {
                    viewModel.isShowingSignOutAlert.toggle()
                } label: {
                    ButtonLabel(type: .signOut)
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
        }
    }
}

private struct ButtonLabel: View {
    let type: AccountButtonType
    
    var body: some View {
        HStack(spacing: 0) {
            Text(type.title)
                .font(type.fontType)
                .foregroundStyle(type.fontColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(type.backgroundColor)
        )
    }
}

private struct SignOutAlertActions: View {
    @Environment(SologCoordinator.self) private var coordinator
    let viewModel: AccountViewModel
    
    var body: some View {
        Button(role: .cancel) {
            viewModel.cancelSignOutAlert()
            
        } label: {
            Text("취소")
                .font(.notoSansKR(weight: .regular400, size: 16))
                .foregroundStyle(Color(.sSubHead))
        }
        
        Button(role: .destructive) {
            viewModel.confirmSignOut()
            coordinator.dismissSheet()
            coordinator.popToRoot()
        } label: {
            Text("로그아웃")
                .font(.notoSansKR(weight: .semiBold600, size: 16))
                .foregroundStyle(Color(.sRed))
        }
    }
}

private struct DeleteAccountAlertActions: View {
    @Environment(SologCoordinator.self) private var coordinator
    let viewModel: AccountViewModel
    
    var body: some View {
        Button(role: .cancel) {
            viewModel.cancelDeleteAccountAlert()
        } label: {
            Text("취소")
                .font(.notoSansKR(weight: .regular400, size: 16))
                .foregroundStyle(Color(.sSubHead))
        }
        
        Button(role: .destructive) {
            viewModel.deleteAccount()
        } label: {
            Text("탈퇴하기")
                .font(.notoSansKR(weight: .semiBold600, size: 16))
                .foregroundStyle(Color(.sRed))
        }
    }
}

enum AccountButtonType {
    case termsOfService
    case signOut
    case deleteAccount
    
    var title: String {
        switch self {
        case .termsOfService: return "이용약관"
        case .signOut: return "로그아웃"
        case .deleteAccount: return "회원탈퇴"
        }
    }
    
    var fontType: Font {
        switch self {
        case .termsOfService: return .notoSansKR(weight: .medium500, size: 17)
        case .signOut: return .notoSansKR(weight: .semiBold600, size: 17)
        case .deleteAccount: return .notoSansKR(weight: .medium500, size: 17)
        }
    }
    
    var fontColor: Color {
        switch self {
        case .termsOfService: return Color(.sButton)
        case .signOut: return Color(.sWhite)
        case .deleteAccount: return Color(.sButton)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .termsOfService: return Color(.sWhite)
        case .signOut: return Color(.sTitleText)
        case .deleteAccount: return Color(.sWhite)
        }
    }
}
