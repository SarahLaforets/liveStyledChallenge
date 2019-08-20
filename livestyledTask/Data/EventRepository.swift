//
//  EventRepository.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventFetching {
    func fetchEvents(completion: @escaping (Result<[Event]>) -> Void)
}

class EventRepository: EventFetching {
    
    private let remoteUseCase: RemoteEventService
    private let favouriteUserDefaults: FavouriteDataSource
    private let cacheUserDefaults: EventsDataSource
    private let cacheService: CacheFetching
    private static let cacheFileName = "eventsCache"
    
    init(remoteUseCase: RemoteEventService, userDefaults: FavouriteDataSource, cacheUserDefaults: EventsDataSource, cacheService: CacheFetching) {
        self.remoteUseCase = remoteUseCase
        self.favouriteUserDefaults = userDefaults
        self.cacheUserDefaults = cacheUserDefaults
        self.cacheService = cacheService
    }
    
    func fetchEvents(completion: @escaping (Result<[Event]>) -> Void) {
        remoteUseCase.fetchRemoteEvents { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.cacheService.saveDataToCache(with: data, fileName: EventRepository.cacheFileName)
                self?.handleData(with: data, completion: completion)
            case .failure(let errorState):
                switch errorState {
                case .network:
                    self?.cacheService.getCache(from: EventRepository.cacheFileName, completion: { (result) in
                        switch result {
                        case .success(let data):
                            self?.handleData(with: data, completion: completion)
                        case .failure(let errorState):
                            completion(.failure(errorState))
                        }
                    })
                default: completion(.failure(errorState))
                }
            }
        }
    }
    
    private func handleData(with data: Data, completion: @escaping ((Result<[Event]>) -> Void)) {
        let eventsResult = parseJSON(with: data)
        
        switch eventsResult {
        case .success(let events):
            completion(.success(events))
        case .failure(let errorState):
            completion(.failure(errorState))
        }
    }
    
    private func parseJSON(with data: Data) -> Result<[Event]> {
        do {
            let responseDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            guard let jsonArray = responseDictionary as? [[String: Any]] else {
                return .failure(.parsing)
            }
            
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
            
            return .success(events)
            
        } catch {
            return .failure(.parsing)
        }
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
