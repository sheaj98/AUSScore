import SwiftUI

/*
 See: https://stackoverflow.com/a/61708675/1615621
 The underline view is is a 2 point high Rectangle, put in an .overlay() on top of the HStack.
 The underline view is aligned to .bottomLeading, so that we can programmatically set its .padding(.leading, _) using a @State value.
 The underline view's .frame(width:) is also set using a @State value.
 The HStack is set as the .coordinateSpace(name: "container") so we can find the frame of our buttons relative to this.
 The MoveUnderlineButton uses a GeometryReader to find its own width and minX in order to set the respective values for the underline view
 The MoveUnderlineButton is set as the .overlay() for the Text view containing the text of that button so that its GeometryReader inherits its size from that Text view.
  */
public struct PageHeader: View {
    /// An int representing the selected index
    @Binding var selected: Int

    /// An array of title to display
    let labels: [String]
  
    public init(selected: Binding<Int>, labels: [String]) {
      self._selected = selected
      self.labels = labels
    }

    @State private var offset: CGFloat = 0
    @State private var width: CGFloat = 0

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false, content: {
            ScrollViewReader { scrollProxy in
                // Primitive types do not conform to identifiable
                // therefore use self as identifier, this tells SwiftUI that each value in the array is unique
                // See https://www.hackingwithswift.com/quick-start/swiftui/how-to-fix-initializer-init-rowcontent-requires-that-sometype-conform-to-identifiable
                HStack {
                    ForEach(labels.indices, id: \.self) { index in
                        // I don't know how to get access to both the type and index from the `ForEach`
                        // so for now I am accessing the labels array to get the corresponding element
                        let label = labels[index]
                        Text(label)
                            .font(.caption)
                            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.blue)
                            .overlay(MoveUnderlineButton(offset: $offset, width: $width, isSelected: $selected, index: index))
                            .id(index) // identifies the view for the scrollproxy
                    }
                }
                .padding(.bottom)
                .coordinateSpace(name: "container")
                .overlay(underline, alignment: .bottomLeading)
                .animation(.default, value: width)
                .onChange(of: selected, perform: { value in
                    withAnimation {
                        scrollProxy.scrollTo(value, anchor: .center)
                    }
                })
                .onAppear(perform: {
                    withAnimation {
                        // probably should be only first time
                        scrollProxy.scrollTo(selected, anchor: .center)
                    }
                })
            }
        }).padding(.horizontal, 20)
    }

    var underline: some View {
        Rectangle()
            .frame(height: 4)
            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
            .frame(width: width)
            .padding(.leading, offset)
    }

    struct MoveUnderlineButton: View {
        @Binding var offset: CGFloat
        @Binding var width: CGFloat
        @Binding var isSelected: Int
        var index: Int

        var body: some View {
            GeometryReader { geometry in
                Button(action: {
                    self.isSelected = index
                }) {
                    Rectangle().foregroundColor(.clear)
                }
                .onAppear(perform: {
                    if isSelected == index {
                        self.offset = geometry.frame(in: .named("container")).minX
                        self.width = geometry.size.width
                    }
                })
                .onChange(of: isSelected, perform: { _ in
                    guard isSelected == index else { return }
                    self.offset = geometry.frame(in: .named("container")).minX
                    self.width = geometry.size.width
                })
            }
        }
    }
}

struct PageHeaderView_Previews: PreviewProvider {
  @State static var selected: Int = 1
  static var previews: some View {
    PageHeader(selected: $selected, labels: ["ONE", "TWO", "THREE", "FOUR"])
  }}
   
