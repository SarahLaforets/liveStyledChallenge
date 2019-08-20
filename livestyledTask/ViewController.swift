//
//  ViewController.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var presenter: EventPresenting?
    
    private var indicator = UIActivityIndicatorView()
    private var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dependencies = EventFeatureLauncher()
        presenter = dependencies.createPresenter()
        
        presenter?.view = self
        
        activityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        indicator.startAnimating()
        presenter?.startPresenting()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let event = events[indexPath.row]
        cell.titleLabel.text = event.title
        cell.startDateLabel.text = presenter?.formatDate(with: event.date)
        
        cell.favouriteButton.setTitle(buttonTitle(isFavourite: event.isFavourite), for: .normal)
        cell.cellDelegate = self
        
        cell.activityIndicator.startAnimating()
        presenter?.downloadImage(imageURL: event.imageURL, cell: cell)
        
        return cell
    }
    
    private func buttonTitle(isFavourite: Bool) -> String {
        return isFavourite ? "UnFollow" : "Follow"
    }

    private func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
    }
}

extension ViewController: FavouriteStateChanging {
    func didPressButton(with cell: EventTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure("IndexPath not found")
            return
        }
        
        events[indexPath.row].isFavourite = !events[indexPath.row].isFavourite
        cell.favouriteButton.setTitle(buttonTitle(isFavourite: events[indexPath.row].isFavourite), for: .normal)
        presenter?.buttonPressed(id: events[indexPath.row].id)
    }
}

extension ViewController: EventDisplayable {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func show(events: [Event]) {
        self.events = events
        indicator.stopAnimating()
        tableView.separatorStyle = .singleLine
        tableView.reloadData()
    }
    
    func loadImage(with image: UIImage, cell: EventTableViewCell) {
        cell.activityIndicator.stopAnimating()
        cell.eventImageView.layer.cornerRadius = cell.eventImageView.frame.size.height/2
        cell.eventImageView.layer.masksToBounds = true
        cell.eventImageView.layer.borderWidth = 0
        cell.eventImageView.image = image
    }
}

