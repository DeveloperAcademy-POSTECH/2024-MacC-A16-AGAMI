//
//  AccountViewModel.swift
//  AGAMI
//
//  Created by yegang on 11/3/24.
//

import Foundation
import SwiftUICore
import _PhotosUI_SwiftUI

@Observable
final class AccountViewModel {
    var isEditMode: Bool = false
    var isShowingLogoutAlert: Bool = false
    var userName: String = "가자미가자미가자미"
    
    var selectedItem: PhotosPickerItem?
    var postImage: Image?
    
    func convertImage(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.postImage = Image(uiImage: uiImage)
    }
}
