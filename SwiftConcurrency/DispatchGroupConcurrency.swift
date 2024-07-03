//
//  DispatchGroupConcurrency.swift
//  SwiftConcurrency
//
//  Created by Karthik K Manoj on 03/07/24.
//

import Foundation

struct Episode: Identifiable, Codable {
    var id: String
    var poster_url: URL
    var collection: String
    // ...
    
    static let url = URL(string: "https://talk.objc.io/episodes.json")!
}

func loadEpisodes(session: URLSession, completion: @escaping ([Episode]) -> Void) {
    let task = session.dataTask(with: Episode.url) { data, response, error in
        let jsonDecoder = JSONDecoder()
        let mapped = try! jsonDecoder.decode([Episode].self, from: data!)
        completion(mapped)
    }
    
    task.resume()
}

func loadPosterImageForEpisodes(
    session: URLSession,
    episodes: [Episode],
    completion: @escaping ([Episode.ID: Data]) -> Void
) {
    let group = DispatchGroup()
    var childResult = [(Episode.ID, Data)]()
    let resultQueue = DispatchQueue(label: "protect_state")
    
    for episode in episodes {
        group.enter()
        let task = session.dataTask(with: episode.poster_url) { imageData, _, _ in
            if let imageData = imageData {
                resultQueue.sync {
                    childResult.append((episode.id, imageData))
                }
            }
            
            group.leave()
        }
        
        task.resume()
    }
    
    group.notify(queue: resultQueue) {
        let result = childResult.reduce(into: [:]) { dict, pair in
            dict[pair.0] = pair.1
        }
        completion(result)
    }
}

