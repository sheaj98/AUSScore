//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-07-03.
//

import SwiftUI

public struct SimplePageHeader: View {
 
  /// An int representing the selected index
   @Binding var selected: Int

   /// An array of title to display
   let labels: [String]
  
  public init(selected: Binding<Int>, labels: [String]) {
    _selected = selected
    self.labels = labels
  }
  
  public var body: some View {
    HStack {
      ForEach(labels.indices, id: \.self) { index in
        // I don't know how to get access to both the type and index from the `ForEach`
        // so for now I am accessing the labels array to get the corresponding element
        let label = labels[index]
        Spacer()
        Button(action: { self.selected = index }) {
          Text(label)
            .font(.caption)
            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
            .foregroundColor(selected == index ? Color(.white) : Color(uiColor: .lightGray))
            .frame(maxWidth: .infinity, alignment: .center)
        }
        Spacer()
      }
    }
    .padding(.bottom)
    .background(Color(.secondarySystemBackground))
  }
}

struct SimplePageHeaderView_Previews: PreviewProvider {
  @State static var selected = 1
  static var previews: some View {
    VStack {
      SimplePageHeader(selected: $selected, labels: ["ONE", "TWO", "THREE", "FOUR"])
      Text("TestTest")
        .background(Color.red)
        .padding(.top, -8)
    }
    .background(Color.white)
  }
}


