//
//  Hit.swift
//  engineer-ai
//
//  Created by Vitalii Yevtushenko on 09.10.2019.
//  Copyright © 2019 ArcherSoft. All rights reserved.
//

import Foundation

struct Hits: Decodable {
    var hits: [Hit]
}

struct Hit: Decodable {
    var createdAtI: Date
    var title: String
    var objectID: String
}
