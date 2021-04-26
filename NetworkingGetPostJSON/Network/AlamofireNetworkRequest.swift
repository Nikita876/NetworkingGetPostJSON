//
//  AlamofireNetworkRequest.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 23.04.21.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    // MARK: - Variables
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) ->())?
    // MARK: - Methods
    /// sendRequest
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course])->()) {

        guard let url = URL(string: url) else { return }
        AF.request(url, method: .get).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                var courses = [Course]()
                courses = Course.getArray(from: value)!
                completion(courses)
            case .failure(let error):
                print(error)
            }
        }
    }
    /// downloadImage
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage)->()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let error):
                print(error)
            }
        }
    }
    /// responseData
    static func responseData(url: String) {
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
            guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    /// responseString
    static func responseString(url: String) {
        AF.request(url).responseData { (responseString) in
            
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    /// response
    static func response(url: String) {
        AF.request(url).responseData { (response) in
            
            guard
                let data = response.data,
                let string = String(data: data, encoding: .utf8)
            else { return}
            
            print(string)
        }
    }
    /// downloadImageWithProgress
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().downloadProgress { (progress) in
            print("TotalUnitCount: \(progress.totalUnitCount)\n")
            print("CompletedUnitCount:\(progress.completedUnitCount)\n")
            print("FractionCompleted:\(progress.fractionCompleted)\n")
            print("LoclizedDescription:\(progress.localizedDescription!)\n")
            print("------------------------------------------------------")
            
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
        }.response { (response) in
            guard let data = response.data,
                  let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
            
        }
    }
}
