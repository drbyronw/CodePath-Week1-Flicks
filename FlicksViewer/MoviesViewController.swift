//
//  MovieViewController.swift
//  FlicksViewer
//
//  Created by Byron J. Williams on 10/11/16.
//  Copyright © 2016 Byron J. Williams. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String! = "top_rated"
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        self.refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        //        refreshControl.addTarget(self, action: "refresh", for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
        performDataRequest()
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
        cell.titleLabel?.text = title
        cell.overviewLabel?.text = overview
        
        let posterPath = movie["poster_path"] as? String
        
        if let posterPath = posterPath {
            let imageString = baseURL + posterPath
            //            let imageURL = URL(string: imageString)
            //            cell.posterView.setImageWith(imageURL!)
            let imageRequest = URLRequest(url: URL(string: imageString)!)
            cell.posterView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        //        print("Title: \(title) Row: \(indexPath.row)")
        
        return cell
    }
    
    func performDataRequest() {
        let apikey = "9d3c8941bb5a7d5abef3326b3cd2cab8"
        let stringURL = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apikey)"
        let url = URL(string: stringURL)
        let request = URLRequest(url: url!)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if let responseData = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary
                {
                    //                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                    
                }
            }
        })
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        performDataRequest()
        print("Performed Refresh")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath?.row)!]
        
        let movieDetailViewController = segue.destination as! MovieDetailsViewController
        movieDetailViewController.movie = movie
        
        print("prepare(for segue:...)")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
}
