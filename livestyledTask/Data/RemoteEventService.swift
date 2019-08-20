//
//  RemoteEventUseCase.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventRemoteFetching {
    func fetchRemoteEvents(completion: @escaping (Result<Data>) -> Void)
}

class RemoteEventService: EventRemoteFetching {
    
    static private let stringURL = "https://my-json-server.typicode.com/livestyled/mock-api/events"
    
    func fetchRemoteEvents(completion: @escaping (Result<Data>) -> Void) {
        guard let url = URL(string: RemoteEventService.stringURL) else {
            fatalError("URL should be available")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(.network))
//                fatalError("Request not possible")
            }
            
            if response != nil, let data = data {
                completion(Result.success(data))
            }
        }
        
        task.resume()
    }
}
