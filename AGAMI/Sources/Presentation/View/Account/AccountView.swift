//
//  AccountView.swift
//  AGAMI
//
//  Created by yegang on 11/2/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct AccountView: View {
    @State var viewModel: AccountViewModel = .init()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    
    var body: some View {
        ZStack {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    ProfileView(viewModel: viewModel)
                        .padding(.top, 28)
                    InformationView(viewModel: viewModel)
                        .padding(.top, 33)
                }
                Spacer()
                
                LogoutButton(viewModel: viewModel)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 8)
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .navigationTitle("계정")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
//        .toolbar {
//            if !viewModel.isScucessDeleteAccount {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        coordinator.pop()
//                    } label: {
//                        Image(systemName: "chevron.backward")
//                            .font(.pretendard(weight: .semiBold600, size: 17))
//                            .foregroundStyle(Color(.pPrimary))
//                    }
//                }
//            }
//        }
        .onTapGesture {
            hideKeyboard()
        }
        .confirmationDialog("", isPresented: $viewModel.isProfileImageDialogPresented) {
            ProfileImageDialogActions(viewModel: viewModel)
        }
        .photosPicker(isPresented: $viewModel.showPhotoPicker,
                      selection: $viewModel.selectedItem,
                      matching: .images)
        .onChange(of: viewModel.selectedItem) { _, newValue in
            viewModel.convertImage(item: newValue)
        }
        .alert("로그아웃", isPresented: $viewModel.isShowingSignOutAlert) {
            SignOutAlertActions(viewModel: viewModel)
        } message: {
            Text("현재 기기에서 로그아웃 합니다.")
        }
        .alert("회원 탈퇴", isPresented: $viewModel.isDeletingAccount) {
            DeleteAccountAlertActions(viewModel: viewModel)
        } message: {
            Text("탈퇴한 계정은 복구할 수 없습니다.")
        }
    }
}

private struct ProfileView: View {
    @Bindable var viewModel: AccountViewModel
    
    var body: some View {
        VStack(spacing: 11) {
            HStack(spacing: 0) {
                Text("프로필")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                
                Spacer()
                
                Button {
                    if viewModel.isEditMode {
                        viewModel.endEditButtonTaped()
                    } else {
                        viewModel.startEditButtonTaped()
                    }
                } label: {
                    Text(viewModel.isEditMode ? "완료" : "편집")
                        .font(.pretendard(weight: .regular400, size: 16))
                        .foregroundStyle(Color(.pPrimary))
                }
            }
            .padding(.horizontal, 8)
            
            HStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Button {
                        viewModel.isProfileImageDialogPresented = true
                    } label: {
                        Group {
                            if let postImage = viewModel.postImage {
                                Image(uiImage: postImage)
                                    .resizable()
                            } else if !viewModel.imageURL.isEmpty {
                                KFImage(URL(string: viewModel.imageURL))
                                    .resizable()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 94, height: 94)
                        .foregroundStyle(Color(.pGray2))
                        .overlay(alignment: .bottomTrailing) {
                            if viewModel.isEditMode {
                                Circle()
                                    .frame(width: 33, height: 33, alignment: .center)
                                    .foregroundStyle(Color(.pLightGray))
                                    .overlay {
                                        Image(systemName: "camera.circle.fill")
                                            .resizable()
                                            .frame(width: 27, height: 27, alignment: .center)
                                            .foregroundStyle(Color(.pPrimary))
                                    }
                                    .offset(x: 3, y: 3)
                            }
                        }
                    }
                    .disabled(!viewModel.isEditMode)
                    
                    TextField(viewModel.userName, text: $viewModel.userName)
                        .font(.pretendard(weight: .semiBold600, size: 28))
                        .foregroundStyle(Color(.pBlack))
                        .tint(Color(.pPrimary))
                        .frame(width: 221)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.isEditMode ?
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.pGray2))
                            : nil
                        )
                        .disabled(!viewModel.isEditMode)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 26, leading: 0, bottom: 20, trailing: 0))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.pWhite))
            )
            .onAppear {
                viewModel.fetchUserInformation()
            }
        }
    }
}

private struct InformationView: View {
    @Environment(\.openURL) private var openURL
    let viewModel: AccountViewModel
    
    var body: some View {
        VStack(spacing: 13) {
            HStack(spacing: 0) {
                Text("개인정보 보호")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                
                Spacer()
            }
            .padding(.leading, 8)
            
            VStack(spacing: 8) {
                Button {
                    if let url = URL(string: "https://posacademy.notion.site/Plake-1302b843d5af81969d94daddfac63fde?pvs=4") {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: 0) {
                        Text("이용 약관")
                            .font(.pretendard(weight: .medium500, size: 16))
                            .foregroundStyle(Color(.pBlack))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 17))
                            .foregroundStyle(Color(.pPrimary))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.pWhite))
                    )
                }
                
                Button {
                    viewModel.isDeletingAccount = true
                } label: {
                    HStack(spacing: 0) {
                        Text("회원 탈퇴")
                            .font(.pretendard(weight: .medium500, size: 16))
                            .foregroundStyle(Color(.pBlack))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.pWhite))
                    )
                }
            }
        }
    }
}

private struct LogoutButton: View {
    let viewModel: AccountViewModel
    
    var body: some View {
        Button {
            viewModel.isShowingSignOutAlert = true
        } label: {
            Text("로그아웃")
                .font(.pretendard(weight: .medium500, size: 20))
                .foregroundStyle(Color(.pWhite))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 13)
                        .foregroundStyle(Color(.pPrimary))
                )
        }
    }
}

private struct ProfileImageDialogActions: View {
    @Bindable var viewModel: AccountViewModel
    
    var body: some View {
        Button {
            viewModel.showPhotoPicker.toggle()
        } label: {
            Text("앨범에서 가져오기")
                .font(.pretendard(weight: .regular400, size: 18))
                .foregroundStyle(Color(.pBlack))
        }
        
        Button {
            viewModel.changeDefaultImage()
        } label: {
            Text("기본 이미지로 변경")
                .font(.pretendard(weight: .regular400, size: 18))
                .foregroundStyle(Color(.pPrimary))
        }
    }
}

private struct SignOutAlertActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AccountViewModel
    
    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.isShowingSignOutAlert = false
        }
        
        Button("확인", role: .destructive) {
            viewModel.signOut()
            coordinator.popToRoot()
            viewModel.isShowingSignOutAlert = false
        }
    }
}

private struct DeleteAccountAlertActions: View {
    let viewModel: AccountViewModel
    
    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.isDeletingAccount = false
        }
        
        Button("탈퇴", role: .destructive) {
            viewModel.deleteAccount()
        }
    }
}

#Preview {
    AccountView()
}
