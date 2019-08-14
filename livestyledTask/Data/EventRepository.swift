//
//  EventRepository.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventFetching {
    func fetchEvents(completion: @escaping ([Event]?, RemoteError?) -> Void)
}

class EventRepository: EventFetching {
    
    private let remoteUseCase: RemoteEventUseCase
    private let favouriteUserDefaults: FavouriteDataSource
    private let cacheUserDefaults: EventsDataSource
    
    init(remoteUseCase: RemoteEventUseCase, userDefaults: FavouriteDataSource, cacheUserDefaults: EventsDataSource) {
        self.remoteUseCase = remoteUseCase
        self.favouriteUserDefaults = userDefaults
        self.cacheUserDefaults = cacheUserDefaults
    }
    
    func fetchEvents(completion: @escaping ([Event]?, RemoteError?) -> Void) {
        remoteUseCase.fetchRemoteEvents { (response, error) in
            if error != nil {
                switch error! {
                case .parsingIssue(let error):
                    assertionFailure(error.localizedDescription)
                    print(error.localizedDescription)
                case .connectionIssue(let error):
                    assertionFailure(error.localizedDescription) // Comment this line to use the app without network
                    print(error.localizedDescription)
                }

                completion(self.parseEvents(with: self.cachedEvents()), error)
            }
            
            let events = self.parseEvents(with: response)

            completion(events, nil)
        }
    }
    
    private func parseEvents(with response: Any?) -> [Event]? {
        guard let jsonArray = response as? [[String: Any]] else {
            return nil
        }
        
        cacheResponse(with: jsonArray)
        
        let events: [Event] = jsonArray.map { jsonEvent in
            guard let title = jsonEvent["title"] as? String,
                let imageStringURL = jsonEvent["image"] as? String,
                let timestamp = jsonEvent["startDate"] as? Int,
                let id = jsonEvent["id"] as? String,
                let timeInterval = TimeInterval(exactly: timestamp),
                let imageURL = URL(string: imageStringURL) else {
                    fatalError("Can't parse event")
            }
            
            let startDate = Date(timeIntervalSince1970: timeInterval)
            
            return Event(id: id,
                         imageURL: imageURL,
                         title: title,
                         date: startDate,
                         isFavourite: self.isFavourite(id: id))
        }
        
        return events
    }
    
    func cacheResponse(with jsonArray: [[String: Any]]) {
        cacheUserDefaults.cacheEvents(with: jsonArray)
    }
    
    private func cachedEvents() -> [[String: Any]] {
        guard let events = self.cacheUserDefaults.getEvents() else {
            fatalError("No event were cached")
        }
        
        return events
    }
    
    private func isFavourite(id: String) -> Bool {
        guard let favourites = favouriteUserDefaults.getFavourites(), !favourites.isEmpty else {
            return false
        }
        
        return favourites.contains(id)
    }
}
