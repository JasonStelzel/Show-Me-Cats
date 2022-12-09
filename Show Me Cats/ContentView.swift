//
//  ContentView.swift
//  Show Me Cats
//
//  Created by Jason Stelzel on 12/5/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            NavigationLink(destination: CatListView(), label: showLabel)
        }
    }
    
    
    func showLabel() -> some View {
        VStack {
            Image("Subject")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
            Text("Let's See Some Cats!")
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
