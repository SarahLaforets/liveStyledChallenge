//
//  EventViewModel.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 11/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

struct Event {
    let id: String
    let imageURL: URL
    let title: String
    let date: Date
    var isFavourite: Bool
}
