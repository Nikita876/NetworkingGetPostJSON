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
    /// postRequest
    static func postRequest(url: String, completion: @escaping (_ courses: [Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name": "Network Requests",
                                      "link": "https://swiftbook.ru/contents/our-first-applications/",
                                      "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                      "numberOfLessons": 18,
                                      "numberOfTests": 10  ]
        
        AF.request(url, method: .post, parameters: userData).responseJSON { (responseJSON) in
            guard let statucCode = responseJSON.response?.statusCode else { return }
            print("StatusCode: \(statucCode)")
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                
                guard let jsonObject = value as? [String: Any],
                      let course = Course(json: jsonObject)
                else { return }
                
                var courses = [Course]()
                courses.append(course)
                
                completion(courses)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    /// putRequest
    static func putRequest(url: String, completion: @escaping (_ courses: [Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name": "Network Requests with Alamofire",
                                      "link": "https://swiftbook.ru/contents/our-first-applications/",
                                      "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                      "numberOfLessons": "18",
                                      "numberOfTests": "10"  ]
        
        AF.request(url, method: .put, parameters: userData).responseJSON { (responseJSON) in
            guard let statucCode = responseJSON.response?.statusCode else { return }
            print("StatusCode: \(statucCode)")
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                
                guard let jsonObject = value as? [String: Any],
                      let course = Course(json: jsonObject)
                else { return }
                
                var courses = [Course]()
                courses.append(course)
                
                completion(courses)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    /// uploadImage
//    static func uploadImage(url: String) {
//
//        guard let url = URL(string: url) else { return }
//
//        let image = UIImage(named: "Notification")!
//        let data = image.pngData()!
//        
//        let httpHeaders = ["Authorization": "Client-ID 580bdaf0b4320ed"]
//
//        AF.upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(data, withName: "image")
//
//        }, to: url,
//           headers: httpHeaders) { (encodingCompletion) in
//
//            switch encodingCompletion {
//
//                case .success(request: let uploadRequest,
//                              streamingFromDisk: let streamingFromDisk,
//                              streamFileURL: let streamFileURL):
//
//                print(uploadRequest)
//                print(streamingFromDisk)
//                print(streamFileURL ?? "strimingFileURL is NIL")
//
//                    AF.uploadRequest.validate().responseJSON(completionHandler: { (responseJSON) in
//
//                    switch responseJSON.result {
//
//                    case .success(let value):
//                        print(value)
//                    case .failure(let error):
//                        print(error)
//                    }
//                })
//
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
}
