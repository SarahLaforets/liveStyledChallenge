//
//  FavouriteUserDefaults.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 14/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

protocol FavouriteDataSource {
    func statusChange(for id: String)
    func getFavourites() -> [String]?
}

class FavouriteUserDefauls: FavouriteDataSource {
    
    private let defaults = UserDefaults.standard
    private let key = "Favourites"
    
    private func saveFavourite(for id: String) {
        var favourites = getFavourites() ?? [String]()
        favourites.append(id)
        setFavourite(favourites)
    }
    
    private func removeFavourite(for id: String) {
        var favourites = getFavourites()
        favourites?.removeAll(where: { $0 == id })
        setFavourite(favourites)
    }
    
    func statusChange(for id: String) {
        guard let favourites = getFavourites() else {
            saveFavourite(for: id)
            return
        }
        
        favourites.contains(id) ? removeFavourite(for: id) : saveFavourite(for: id)
    }
    
    func getFavourites() -> [String]? {
        return defaults.array(forKey: key) as? [String]
    }
    
    private func setFavourite(_ favourites: [String]?) {
        defaults.set(favourites, forKey: key)
    }
}
