//
//  EventRepository.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventFetching {
    func fetchEvents(completion: @escaping ([Event]) -> Void)
}

class EventRepository: EventFetching {
    
    private let remoteUseCase: RemoteEventUseCase
    
    init(remoteUseCase: RemoteEventUseCase) {
        self.remoteUseCase = remoteUseCase
    }
    
    func fetchEvents(completion: @escaping ([Event]) -> Void) {
        remoteUseCase.fetchRemoteEvents { (response) in
            guard let jsonArray = response as? [[String: Any]] else {
                return
            }
            
            let events: [Event] = jsonArray.map { jsonEvent in
                
                guard let title = jsonEvent["title"] as? String,
                    let imageStringURL = jsonEvent["image"] as? String,
                    let timestamp = jsonEvent["startDate"] as? Int,
                    let id = jsonEvent["id"] as? String,
                    let timeInterval = TimeInterval(exactly: timestamp),
                    let imageURL = URL(string: imageStringURL) else {
                    fatalError("Can't parse json properly")
                }
                
                let startDate = Date(timeIntervalSince1970: timeInterval)
                
                return Event(id: id,
                                  imageURL: imageURL,
                                  title: title,
                                  date: startDate,
                                  isFavourite: false)
            }
            
            completion(events)
        }
    }
}
