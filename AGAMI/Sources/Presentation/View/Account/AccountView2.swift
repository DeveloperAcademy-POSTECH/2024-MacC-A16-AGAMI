//
//  AccountView2.swift
//  AGAMI
//
//  Created by yegang on 11/19/24.
//

import SwiftUI

struct AccountView2: View {
    @State private var isSheetPresented = false
    @State var isShowingSignOutAlert: Bool = false
    @State var isShowingDeletingAccount: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            ContentView(isShowingDeletingAccount: $isShowingDeletingAccount, isShowingSignOutAlert: $isShowingSignOutAlert)
        }
        .ignoresSafeArea(edges: .bottom)
        .alert("로그아웃", isPresented: $isShowingSignOutAlert) {
            SignOutAlertActions()
        } message: {
            Text("로그아웃을 진행하시겠어요?\n다시 돌아오실 때를 기다릴게요!")
        }
        .alert("회원 탈퇴", isPresented: $isShowingDeletingAccount) {
            DeleteAccountAlertActions()
        } message: {
            Text("회원 탈퇴 시 모든 기록이 삭제되고\n복구할 수 없습니다.")
        }
        
    }
}

private struct HeaderView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Text("계정 관리")
                .font(.notoSansKR(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.sTitleText))
            
            HStack(spacing: 0) {
                Button {
                    // 닫기, 코디네이터 연결
                } label: {
                    Text("닫기")
                        .font(.notoSansKR(weight: .regular400, size: 17))
                        .foregroundStyle(Color(.sButton))
                }
                
                Spacer()
            }
            .padding(.leading, 16)
        }
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 17, trailing: 0))
        .background(Color(.sWhiteBack))
    }
}

private struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Binding var isShowingDeletingAccount: Bool
    @Binding var isShowingSignOutAlert: Bool
    
    var body: some View {
        ZStack {
            Color(.sMain)
                .ignoresSafeArea()
            
            // 최상단 VStack (모든 버튼을 감싸는 스택)
            VStack(spacing: 32) {
                // 이용 약관, 회원 탈퇴 버튼이 묶여있는 스택
                VStack(spacing: 14) {
                    Button {
                        // 이용 약관 알럿
                        if let url = URL(string: "https://posacademy.notion.site/Plake-1302b843d5af81969d94daddfac63fde?pvs=4") {
                            openURL(url)
                        } else {
                            dump("잘못된 URL입니다.")
                        }
                    } label: {
                        ButtonLabel(
                            title: "이용 약관",
                            fontType: .notoSansKR(weight: .medium500, size: 17),
                            fontColor: Color(.sButton),
                            backgroundColor: Color(.sWhite))
                    }
                    
                    Button {
                        // 회원 탈퇴 알럿
                        isShowingDeletingAccount.toggle()
                    } label: {
                        ButtonLabel(
                            title: "회원 탈퇴",
                            fontType: .notoSansKR(weight: .medium500, size: 17),
                            fontColor: Color(.sButton),
                            backgroundColor: Color(.sWhite))
                    }
                }
                
                Button {
                    isShowingSignOutAlert.toggle()
                } label: {
                    ButtonLabel(
                        title: "로그아웃",
                        fontType: .notoSansKR(weight: .semiBold600, size: 17),
                        fontColor: Color(.sWhite),
                        backgroundColor: Color(.sTitleText))
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
        }
    }
}

private struct ButtonLabel: View {
    let title: String
    let fontType: Font
    let fontColor: Color
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(fontType)
                .foregroundStyle(fontColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
        )
    }
}

private struct SignOutAlertActions: View {
    
    var body: some View {
        Button("취소", role: .cancel) {
            //
        }
        
        Button("로그아웃", role: .destructive) {
            //
        }
    }
}

private struct DeleteAccountAlertActions: View {
    
    var body: some View {
        Button("취소", role: .cancel) {
            //
        }
        
        Button("탈퇴하기", role: .destructive) {
            //
        }
    }
}

#Preview {
    AccountView2()
}
