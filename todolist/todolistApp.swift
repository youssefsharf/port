//  todolistApp.swift
//  todolist
//
//  Created by MacBook Air on 1/9/25.
//

import SwiftUI

@main
struct todolistApp: App {
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
            .environmentObject(listViewModel)
        }
    }
}

