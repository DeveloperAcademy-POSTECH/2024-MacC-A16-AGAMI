//
//  Date+.swift
//  AGAMI
//
//  Created by taehun on 11/1/24.
//

import SwiftUI

extension Date {
  func isWithinPast(minutes: Int) -> Bool {
    let now = Date.now
    let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
    let range = timeAgo...now
    return range.contains(self)
  }
}
