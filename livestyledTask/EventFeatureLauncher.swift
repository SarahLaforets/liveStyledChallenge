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
    
    func createDependencies(view: EventDisplayable) {
        guard let viewController = view as? ViewController else {
            fatalError()
        }
        
        let useCase = RemoteEventUseCase()
        let fetcher = EventRepository(remoteUseCase: useCase)
        let presenter = EventPresenter(fetcher: fetcher)
        
        presenter.view = viewController
        viewController.presenter = presenter
    }
}