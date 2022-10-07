//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 6.10.2022.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feedItems: [FeedItem] {
            return items.map(\.modelItem)
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var modelItem: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    class func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }
        return .success(root.feedItems)
    }
    
}
