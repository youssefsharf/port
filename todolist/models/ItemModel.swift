//
//  ItemModel.swift
//  todolist
//
//  Created by MacBook Air on 1/11/25.
//

import Foundation

struct ItemModel :Identifiable {
    let id :String = UUID().uuidString
    let title :String
    let iscompleted: Bool
}
