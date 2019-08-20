//
//  EventPresenter.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation
import UIKit

protocol EventDisplayable: class {
    func show(events: [Event])
    func loadImage(with image: UIImage, cell: EventTableViewCell)
    func presentAlert(title: String, message: String)
}

protocol EventPresenting: class {
    var view: EventDisplayable? { get set }

    func startPresenting()
    func buttonPressed(id: String)
    func formatDate(with date: Date) -> String
    func downloadImage(imageURL: URL, cell: EventTableViewCell)
}

class EventPresenter: EventPresenting {
    
    weak var view: EventDisplayable?
    
    private let fetcher: EventFetching
    private let userDefault: FavouriteDataSource
    private let eventCachesDefault: EventsDataSource
    
    private var events: [Event] = [Event]()

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_UK")
        formatter.setLocalizedDateFormatFromTemplate("y MMMMd, HH:mm")
        return formatter
    }()
    
    init(fetcher: EventFetching, userDefault: FavouriteDataSource, eventCachesDefault: EventsDataSource) {
        self.fetcher = fetcher
        self.userDefault = userDefault
        self.eventCachesDefault = eventCachesDefault
    }

    func startPresenting() {
        fetcher.fetchEvents { (result) in
            switch result {
            case .success(let events):
                self.handleEvents(with: events)
            case .failure(let errorState):
                self.handleFailedPostsDelivery(with: errorState)
            }
        }
    }
    
    private func handleFailedPostsDelivery(with errorState: ErrorState) {
        let title: String
        let message: String
        
        switch errorState {
        case .network:
            title = "Connection issue"
            message = "Seems that your aren't connected to Internet. To pull latest events you need a connection."
        case .parsing:
            title = "Something went wrong"
            message = "Please try again. If the issue persists, contact support."
        }
        
        DispatchQueue.main.async {
            self.view?.presentAlert(title: title, message: message)
        }
    }
    
    private func handleEvents(with events: [Event]) {
        self.events = events.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        DispatchQueue.main.async {
            self.view?.show(events: self.events)
        }
    }
    
    func formatDate(with date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func buttonPressed(id: String) {
        userDefault.statusChange(for: id)
    }
    
    func downloadImage(imageURL: URL, cell: EventTableViewCell) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: imageURL), let image: UIImage = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.view?.loadImage(with: image, cell: cell)
            }
        }
    }
}
