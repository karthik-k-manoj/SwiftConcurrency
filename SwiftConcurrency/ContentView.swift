//
//  ContentView.swift
//  SwiftConcurrency
//
//  Created by Karthik K Manoj on 03/07/24.
//

import SwiftUI

struct ContentView: View {
    let session = URLSession.shared
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Test") {
                loadEpisodes(session: session) { episodes in
                    loadPosterImageForEpisodes(session: session, episodes: episodes) { result in
                        print("Result", result)
                    }
                }
            }
            
            Button("Test Swift Concurrency") {
                loadEpisodes(session: session) { episodes in
                    Task {
                        let result = try! await loadPosterImages(session: session, for: episodes)
                        print("Result", result)
                    }
                    
                    print("HELLO WORLD")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
