//
//  SignOutView.swift
//  AGAMI
//
//  Created by yegang on 11/4/24.
//

import SwiftUI

struct SignOutView: View {
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
                
                Text("회원 탈퇴 완료!")
                    .font(.pretendard(weight: .semiBold600, size: 24))
                    .foregroundStyle(Color(.pBlack))
            }
        }
    }
}

#Preview {
    SignOutView()
}
