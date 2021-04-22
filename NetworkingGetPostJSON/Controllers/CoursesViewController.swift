//
//  CoursesViewController.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 22.04.21.
//

import UIKit

class CoursesViewController: UIViewController {
    // MARK: - Variable
    private var courses = [Course]()
    private var courseName: String?
    private var courseURL: String?
    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
    // MARK: - Methods
    func fetchData() {
        
        let jsonUrlString = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                self.courses = try decoder.decode([Course].self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("Error serialization", error)
            }
            
        }.resume()
    }
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        let course = courses[indexPath.row]
        cell.courseNameLabel.text = course.name
        
        if let numberOfLessons = course.numberOfLessons {
            cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
        }
        
        if let numberOfTests = course.numberOfTests {
            cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
        }
        
        DispatchQueue.global().async {
            guard let imageURL = URL(string: course.imageUrl!) else { return }
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            
            DispatchQueue.main.async {
                cell.courseImage.image = UIImage(data: imageData)
            }
        }
        
        
    }
    //    // MARK: - Navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        let webViewController = segue.destination as! WebViewController
    //        webViewController.selectedCourse = courseName
    //
    //        if let url = courseURL {
    //            webViewController.courseURL = url
    //        }
    //    }
}

// MARK: - CoursesViewController: UITableViewDelegate, UITableViewDataSource
extension CoursesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        
        configureCell(cell: cell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let course = courses[indexPath.row]
//
//        courseURL = course.link
//        courseName = course.name
//
//        performSegue(withIdentifier: "Description", sender: self)
    }
}
