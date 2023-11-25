//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-11-25.
//

import Models
import NukeUI
import SwiftUI

public struct FavoritesBarCell: View {
  let itemType: ItemType
  
  public var body: some View {
    VStack {
      switch itemType {
      case .team(let teamInfo):
        Group {
          if let logoUrl = teamInfo.school.logo {
            LazyImage(url: logoUrl)
          } else {
            Image(systemName: "sportscourt.circle")
          }
        }
        .frame(width: 30, height: 30)
        Text(teamInfo.school.displayName)
      case .sport(let sportInfo):
        Image(systemName: sportInfo.icon ?? "sportscourt.circle")
          .resizable()
          .frame(width: 24, height: 24)
          .padding(12)
          .background {
            Circle().fill(Color(uiColor: .secondarySystemFill))
          }
        Text(sportInfo.gender == .male ? "Mens" : "Womens")
          .textCase(.uppercase)
          .font(.system(size: 12))
          .fontWeight(.medium)
      }
    }
  }
  
  public enum ItemType {
    case team(TeamInfo)
    case sport(SportInfo)
  }
}

public struct FavoritesBar: View {
  let favoriteSports: [SportInfo]
  let didClickSport: (SportInfo) -> Void
  
  public init(favoriteSports: [SportInfo], didClickSport: @escaping (SportInfo) -> Void) {
    self.favoriteSports = favoriteSports
    self.didClickSport = didClickSport
  }

  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 16) {
        ForEach(favoriteSports) { sport in
          Button(action: { didClickSport(sport) }, label: {
            FavoritesBarCell(itemType: .sport(sport))
          })
          .foregroundStyle(Color(uiColor: .white))
        }
      }
    }
    .padding(.leading)
    .padding(.trailing)
  }
}

#Preview {
  FavoritesBar(favoriteSports: [.mock()], didClickSport: { _ in })
}
