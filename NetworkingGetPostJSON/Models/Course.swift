//
//  Course.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 22.04.21.
//

import Foundation

struct Course: Decodable {
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
}
