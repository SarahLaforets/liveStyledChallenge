//
//  EventFeatureLauncher.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation
import UIKit

class EventFeatureLauncher {
    
    func createPresenter() -> EventPresenting {
        let useCase = RemoteEventService()
        let favouriteUserDefault = FavouriteUserDefauls()
        let cacheUserDefault = EventsUserDefauls()
        let cacheService = CacheService()
        let fetcher = EventRepository(remoteUseCase: useCase, userDefaults: favouriteUserDefault, cacheUserDefaults: cacheUserDefault, cacheService: cacheService)
        let presenter = EventPresenter(fetcher: fetcher, userDefault: favouriteUserDefault, eventCachesDefault: cacheUserDefault)
        
        return presenter
    }
}
