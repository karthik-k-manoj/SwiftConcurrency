//
//  ThrowingTaskGroup.swift
//  SwiftConcurrency
//
//  Created by Karthik K Manoj on 03/07/24.
//

import Foundation

func loadPosterImages(
    session: URLSession,
    for episodes: [Episode]
) async throws -> [Episode.ID: Data] {
    
    // this creates a throwing task group
    try await withThrowingTaskGroup(of: (id: Episode.ID, image: Data).self, body: {
        // parent task
        group in
        for episode in episodes {
            group.addTask {
                // child task
                let (imageData, _) = try await session.data(from: episode.poster_url)
                return (episode.id, imageData)
            }
        }
        
        // await here makes sure all the child tasks are completed before performing reduce
        return try await group.reduce(into: [:]) { dict, pair in
            dict[pair.id] = pair.image
        }
    })
}
