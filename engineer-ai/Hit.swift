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
    var nbPages: Int
}

struct Hit: Decodable {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    var createdAt: Date
    var title: String
    var objectID: String
}
