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
    @IBOutlet var mainView: UIView!
    
    var errorView = UIView()
    var errorLabel = UILabel()

    let searchController = UISearchController(searchResultsController: nil)
    var filteredMovies = [NSDictionary]()
    
    var movies: [NSDictionary]?
    var endpoint: String! = "top_rated"
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        
        self.refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        //        refreshControl.addTarget(self, action: "refresh", for: UIControlEvents.valueChanged)
        
        errorView.frame = CGRect(x: 0, y: 20, width: 320, height: 30)
        errorLabel.frame = CGRect(x: 10, y: 3, width: 320, height: 30)
//        errorView.backgroundColor = UIColor(red: 144, green: 195, blue: 219, alpha: 1)
        errorView.backgroundColor = UIColor.green
        errorLabel.text = "Networking Error, Please Try Later"
        errorLabel.font = errorLabel.font.withSize(14)
        errorLabel.sizeToFit()
        errorLabel.center = CGPoint(x: errorView.frame.width/2, y: errorView.frame.height/2)
        errorView.insertSubview(errorLabel, at: 0)
        
        errorView.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(errorView)

        tableView.insertSubview(refreshControl, at: 1)
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(red: 144/255, green: 195/255, blue: 219/255, alpha: 0.85)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
//            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
//            navigationBar.titleTextAttributes = [
//                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22),
//                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
//                NSShadowAttributeName : shadow
//            ]
        }
        
        performDataRequest()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filteredSearchContent(_ searchText: String) {
        var temp: String = ""
        filteredMovies = movies!.filter { movie in
            temp = (movie["title"] as? String)!
            if temp.lowercased().contains(searchText.lowercased()) {
                print(temp)
                return true
            } else {
                return false
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        var movie = NSDictionary()
        if searchController.isActive && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }

        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        let baseURL = "https://image.tmdb.org/t/p/w500/"
        cell.titleLabel?.text = title
        cell.overviewLabel?.text = overview
        cell.overviewLabel.sizeToFit()
//        cell.selectionStyle = .none
        let backgroundView = UIView()
        let specialBlue = UIColor(red: 144/255, green: 195/255, blue: 219/255, alpha: 0.85)

        backgroundView.backgroundColor = specialBlue
        cell.selectedBackgroundView = backgroundView
        cell.backgroundColor = UIColor(red: 211/255, green: 236/255, blue: 245/255, alpha: 0.9)
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
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
    
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if let responseData = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary
                {
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                    
                }
            } else {
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
                self.errorView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
                    // Put your code which should be executed with a delay here
                    self.errorView.isHidden = true
                })
                print("ERRROORRROOROROORORORRRRRR__________\n\n\(error)\n\n________")
            }
        })
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredMovies.count
            } else {
                return movies.count
            }
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
        var movie = NSDictionary()
        print("Index Path for Segue: \(indexPath?.row)")
        if searchController.isActive && searchController.searchBar.text != "" {
            movie = filteredMovies[(indexPath?.row)!]
        } else {
            movie = movies![(indexPath?.row)!]
        }
        let movieDetailViewController = segue.destination as! MovieDetailsViewController
        movieDetailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filteredSearchContent(searchController.searchBar.text!)
    }
    
    
}
