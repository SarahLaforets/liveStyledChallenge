//
//  CacheEventUserDefaults.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 14/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol EventsDataSource {
    func cacheEvents(with events: [[String: Any]])
    func getEvents() -> [[String: Any]]?
}

class EventsUserDefauls: EventsDataSource {
    
    private let defaults = UserDefaults.standard
    private let key = "Events"
    
    func cacheEvents(with events: [[String: Any]]) {
        defaults.set(events, forKey: key)
    }
    
    func getEvents() -> [[String: Any]]? {
        return defaults.array(forKey: key) as? [[String: Any]]
    }
}
