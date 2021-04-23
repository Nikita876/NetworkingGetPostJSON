//
//  ImageProperties.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 23.04.21.
//

import UIKit

struct ImageProperties {
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
}
