//
//  ListView.swift
//  todolist
//
//  Created by MacBook Air on 1/9/25.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var listViewModel : ListViewModel
   
    var body: some View {
        List{
            ForEach(listViewModel.items){ item in ListRowView(item: item)
            }
            .onDelete(perform: listViewModel.deleteItem)
            .onMove(perform:  listViewModel.moveItem)
            }
    
        .listStyle(PlainListStyle())
        .navigationTitle("todo list")
        .navigationBarItems(
            leading: EditButton(),
            trailing: NavigationLink("add", destination: AddView())
        )
    
    }
   
}
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ListView()
                .environmentObject(ListViewModel())
        }
         
        
        
    }
}


