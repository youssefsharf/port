//  ListViewModel.swift
//  todolist
//
//  Created by MacBook Air on 1/15/25.
//

import Foundation

class ListViewModel: ObservableObject {
    @Published var items: [ItemModel] = []
    
    init() {
        getItems()
    }
    
    func getItems() {
        let newItems = [
            ItemModel(title: "This is the first title!", iscompleted: true),
            ItemModel(title: "This is the second title!", iscompleted: false),
            ItemModel(title: "Third", iscompleted: true)
        ]
        items.append(contentsOf: newItems)
    }
    
    func deleteItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    func moveItem(from indexSet: IndexSet, to newOffset: Int) {
        items.move(fromOffsets: indexSet, toOffset: newOffset)
    }
    func addItem(title:String){
        let newItem = ItemModel(title: title, iscompleted: true)
        items.append(newItem)
    }
  
    }
    


