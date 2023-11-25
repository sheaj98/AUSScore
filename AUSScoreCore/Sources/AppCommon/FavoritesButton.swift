//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-11-24.
//

import SwiftUI

public struct FavoritesButton: View {
  let isFavorite: Bool
  let action: (Bool) -> Void
  var isUpdating: Bool
  
  public init(isFavorite: Bool, action: @escaping (Bool) -> Void, isUpdating: Bool) {
    self.isFavorite = isFavorite
    self.action = action
    self.isUpdating = isUpdating
  }
  
  public var body: some View {
    Button {
      action(!isFavorite)
    } label: {
      if isFavorite {
        Image(systemName: "star.fill")
          .foregroundStyle(.yellow)
      } else {
        Image(systemName: isUpdating ? "star.fill" : "star")
      }
    }
    .buttonStyle(.borderless)
    .symbolEffect(.variableColor, value: isUpdating)
  }
}
