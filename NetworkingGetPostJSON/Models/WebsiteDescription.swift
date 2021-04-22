//
//  WebsiteDescription.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 22.04.21.
//

import Foundation

struct WebsiteDescription: Decodable {
    let websiteDescription: String
    let websiteName: String
    let courses: [Course]
}
