//
//  RemoteEventUseCase.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

enum RemoteError {
    case connectionIssue(Error)
    case parsingIssue(Error)
}

protocol EventRemoteFetching {
    func fetchRemoteEvents(completion: @escaping (Any?, RemoteError?) -> Void)
}

class RemoteEventUseCase: EventRemoteFetching {
    
    static private let stringURL = "https://my-json-server.typicode.com/livestyled/mock-api/events"
    
    func fetchRemoteEvents(completion: @escaping (Any?, RemoteError?) -> Void) {
        guard let url = URL(string: RemoteEventUseCase.stringURL) else {
            fatalError("URL should be available")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, .connectionIssue(error!))
//                fatalError("Request not possible")
            }
            
            if response != nil, let data = data {
                do {
                    let responseDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(responseDictionary, nil)
                    
                } catch let parsingError {
                    print("Error: %@", parsingError)
                    completion(nil, .parsingIssue(parsingError))
                }
            }
        }
        
        task.resume()
    }
}
