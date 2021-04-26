//
//  ImageViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 21.04.21.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {
    // MARK: - Variables
    private let url: String = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    // MARK: - Outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        fetchImage()
    }
    // MARK: - Method
    func fetchImage() {
        
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        
        NetworkManager.downloadImage(url: url) { (image) in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
    
    func fetchDataWithAlamofire() {
        AF.request(url).responseData { (responseData) in
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            case .failure(let error):
                print(error)
            }
        }
    }
}
