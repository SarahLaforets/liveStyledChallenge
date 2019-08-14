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
}

protocol EventPresenting: class {
    func startPresenting()
    func buttonPressed(id: String)
    func formatDate(with date: Date) -> String
    func downloadImage(imageURL: URL, cell: EventTableViewCell)
}

class EventPresenter: EventPresenting {
    
    let fetcher: EventFetching
    weak var view: EventDisplayable?
    var events: [Event] = [Event]()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_UK")
        formatter.setLocalizedDateFormatFromTemplate("y MMMMd, HH:mm")
        return formatter
    }()
    
    init(fetcher: EventFetching) {
        self.fetcher = fetcher
    }
    
    func startPresenting() {
        fetcher.fetchEvents { (events) in
            self.events = events.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
            DispatchQueue.main.async {
                self.view?.show(events: self.events)
            }
        }
    }
    
    func formatDate(with date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func buttonPressed(id: String) {
//        guard var event = events?.first(where: {$0.id == id}) else {
//            fatalError("Cannot recorer event")
//        }
//        event.isFavourite = !event.isFavourite
    }
    
    func downloadImage(imageURL: URL, cell: EventTableViewCell) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: imageURL), let image: UIImage = UIImage(data: data) else {
                fatalError("Image can't be loaded")
            }
            
            DispatchQueue.main.async {
                self.view?.loadImage(with: image, cell: cell)
            }
        }
    }
}
