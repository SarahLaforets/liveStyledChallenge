//
//  RemoteEventUseCase.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventRemoteFetching {
    func fetchRemoteEvents(completion: @escaping (Any) -> Void)
}

class RemoteEventUseCase: EventRemoteFetching {
    func fetchRemoteEvents(completion: @escaping (Any) -> Void) {
        guard let url = URL(string: "https://my-json-server.typicode.com/livestyled/mock-api/events") else {
            fatalError("URL should be available")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                // Handle error
                print(error!)
            }
            
            if response != nil, let data = data {
                do {
                    let responseDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(responseDictionary)
                    
                    completion(responseDictionary)
                    
                } catch let parsingError {
                    print("Error: %@", parsingError)
                }
            }
        }
        
        task.resume()
    }
}
