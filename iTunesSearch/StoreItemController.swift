//
//  StoreItemController.swift
//  iTunesSearch
//
//  Created by Nazrin Sultanlı on 29.01.25.
//

import Foundation
import UIKit

class StoreItemController {
    let query = [
        "term": "Apple",
        "media": "ebook",
        "attribute": "authorTerm",
        "lang": "en_us",
        "limit": "10"
    ]


    func fetchItems(matching query: [String:String]) async throws -> [StoreItem] {
        var urlComponent = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponent.queryItems = query.map {
            URLQueryItem(name: $0.key , value: $0.value)
        }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponent.url!)
        
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
            throw StoreItemError.itemsNotFound
        }
        
        let jsDecoder = JSONDecoder()
        let jsData = try jsDecoder.decode(SearchResponse.self, from: data)
        return jsData.results
    }
    
    func fetchItemPhoto(url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.imageNotFound
        }
        guard let photo = UIImage(data: data) else {
            throw StoreItemError.imageNotFound
        }
        
        return photo
    }

}
