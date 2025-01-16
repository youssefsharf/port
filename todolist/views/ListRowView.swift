//  ListRowView.swift
//  todolist
//
//  Created by MacBook Air on 1/11/25.
//

import SwiftUI
struct ListRowView: View {
    let item: ItemModel
    var body: some View {
        HStack {
            Image(systemName: item.iscompleted ? "checkmark.circle" : "circle")
                .foregroundColor(item.iscompleted ? .green : .red)
            Text(item.title)
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, 8)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var item1 = ItemModel(title: "This is the first title!", iscompleted: false)
    static var item2 = ItemModel(title: "This is the second title!", iscompleted: true)
    
    static var previews: some View {
        Group {
            ListRowView(item: item1)
            ListRowView(item: item2)
        }
        .previewLayout(.sizeThatFits)
    }
}

