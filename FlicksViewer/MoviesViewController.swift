//
//  MovieViewController.swift
//  FlicksViewer
//
//  Created by Byron J. Williams on 10/11/16.
//  Copyright © 2016 Byron J. Williams. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String! = "top_rated"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
       
        let apikey = "9d3c8941bb5a7d5abef3326b3cd2cab8"
        let stringURL = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apikey)"
        let url = URL(string: stringURL)
        let request = URLRequest(url: url!)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if let responseData = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary
                {
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()

                }
            }
        })
        task.resume()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        let baseURL = "https://image.tmdb.org/t/p/w500/"
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPath = movie["poster_path"] as? String

        if let posterPath = posterPath {
            let imageURL = URL(string: baseURL + posterPath)
              cell.posterView.setImageWith(imageURL!)
        }

              
        print("row \(indexPath.row)")
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath?.row)!]
        
        let movieDetailViewController = segue.destination as! MovieDetailsViewController
        movieDetailViewController.movie = movie
        
        print("prepare(for seqgue:...)")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }
    

}
