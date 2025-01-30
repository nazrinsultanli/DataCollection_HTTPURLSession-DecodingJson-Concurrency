//
//  NasaPhoto.swift
//  iTunesSearch
//
//  Created by Nazrin Sultanlı on 30.01.25.
//

import Foundation
import UIKit

//func fetchPhotoInfo() async throws -> PhotoInfo {
////    var urlComponents = URLComponents(string:        "https://api.nasa.gov/planetary/apod")!
////
////    urlComponents.queryItems = ["api_key": "DEMO_KEY"].map {
////        URLQueryItem(name: $0.key, value: $0.value)
////    }
////    let (data, response) = try await URLSession.shared.data(from:urlComponents.url!)
////
//
////    guard let httpResponse = response as? HTTPURLResponse,        httpResponse.statusCode == 200 else {
////        throw PhotoInfoError.itemNotFound
////    }
////    let jsonDecoder = JSONDecoder()
////    let photoInfo = try jsonDecoder.decode(PhotoInfo.self,            from: data)
////    return photoInfo
//}

struct PhotoInfo: Codable {
    var title: String
    var description: String
    var url: URL
    var copyright: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description = "explanation"
        case url
        case copyright
    }
    
}
enum APIRequestError: Error, LocalizedError {
    case itemNotFound
}
struct Report: Codable {
    let creationDate: Date
    let profileID: String
    let readCount: Int
    
    enum CodingKeys: String, CodingKey {
        case creationDate = "report_date"
        case profileID = "profile_id"
        case readCount = "read_count"
    }
}

protocol APIRequest {
    associatedtype Response
    var urlRequest: URLRequest { get }
    func decodeResponse(data: Data) throws -> Response
    
}

func sendRequest<T: APIRequest> (_ request: T) async throws -> T.Response {
    let (data, response) = try await URLSession.shared.data(from: request.urlRequest.url!)
    guard let httpResponse = response as? HTTPURLResponse,        httpResponse.statusCode == 200 else {
        throw APIRequestError.itemNotFound
    }
    let decodedResponse = try request.decodeResponse(data: data)
    return decodedResponse
}

struct PhotoInfoApiRequest: APIRequest {
    typealias Response = PhotoInfo
    var apiKey: String
    
    var urlRequest: URLRequest {
        
        var urlComponents = URLComponents(string:        "https://api.nasa.gov/planetary/apod")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "date", value: "2021-07-15"),
            URLQueryItem(name: "api_key", value: apiKey)]
        return URLRequest(url: urlComponents.url!)
    }
    
    func decodeResponse(data: Data) throws -> Response {
        let jsonDecoder = JSONDecoder()
        let photoInfo = try jsonDecoder.decode(Response.self,            from: data)
        return photoInfo
    }
}
struct ImageApiRequest: APIRequest {
    enum ResponserError: Error {
        case invalidImageData
    }
    typealias Response = UIImage
    
    let url: URL
    var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    func decodeResponse(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ResponserError.invalidImageData
        }
        return image
    }
    
    
}
let photoRequest = PhotoInfoApiRequest(apiKey: "DEMO_KEY")
Task {
    do{
        let photoInfo = try await sendRequest(photoRequest)
        print(photoInfo)
        let imageRequest = ImageApiRequest(url:photoInfo.url)
        let image = try await sendRequest(imageRequest)
        print(image)
    }catch {
        print(error)
    }
}


