//
//  SwiftUIView.swift
//  
//
//  Created by Shea Sullivan on 2023-03-25.
//

import SwiftUI
import Models

struct LeaguesListRowView: View {
    
  let league: SportInfo
  
    var body: some View {
      HStack {
        Label {
          Text(league.name)
        } icon: {
          Image(systemName: league.icon ?? "trophy")
            .font(.system(size: 24))
            .foregroundColor(.primary)
        }
      }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct LeaguesListRowView_Previews: PreviewProvider {
    static var previews: some View {
      LeaguesListRowView(league: .mock())
    }
}
