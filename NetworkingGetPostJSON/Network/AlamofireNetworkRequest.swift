//
//  AlamofireNetworkRequest.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 23.04.21.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {

    static func sendRequest(url: String) {

        guard let url = URL(string: url) else { return }
        AF.request(url, method: .get).response { (data) in
            
        }
    }
}
