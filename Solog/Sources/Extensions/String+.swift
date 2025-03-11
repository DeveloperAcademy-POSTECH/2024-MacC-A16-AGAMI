//
//  String+.swift
//  AGAMI
//
//  Created by 박현수 on 11/20/24.
//

extension String {
  var forceCharWrapping: Self {
    self.map({ String($0) }).joined(separator: "\u{200B}")
  }
}
