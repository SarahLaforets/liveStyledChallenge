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
    func startPresenting()
    func buttonPressed(id: String)
    func formatDate(with date: Date) -> String
    func downloadImage(imageURL: URL, cell: EventTableViewCell)
}

class EventPresenter: EventPresenting {
    
    private let fetcher: EventFetching
    private let userDefault: FavouriteDataSource
    private let eventCachesDefault: EventsDataSource
    
    weak var view: EventDisplayable?
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
        fetcher.fetchEvents { (events, error) in
            if error != nil, events == nil {
                DispatchQueue.main.async {
                    self.view?.presentAlert(title: "Connection issues", message: "Please check your connection status. No event are cached.")
                }
            } else if error != nil, let events = events {
                DispatchQueue.main.async {
                    self.view?.presentAlert(title: "Connection issues", message: "Please check your connection status. We've loaded events that were cached.")
                    self.handleEvents(with: events)
                }
            } else if let events = events {
                self.handleEvents(with: events)
            } else {
                DispatchQueue.main.async {
                    self.view?.presentAlert(title: "Something went wrong", message: "Please contact support.")
                }
            }
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
