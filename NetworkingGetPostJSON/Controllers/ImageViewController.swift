//
//  ImageViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 21.04.21.
//

import UIKit

class ImageViewController: UIViewController {
    // MARK: - Variable
    let urlImage: String = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
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
        
        guard let url = URL(string: urlImage) else { return }
        
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.imageView.image = image
                }
            }
        }.resume()
    }
}
