//
//  ScheduleViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/23/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import Firebase

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dayString = "monday"
    
    var scheduleArray: [Day] = []
    
    var networkManager = NetworkManager()
    
    var nsfwAnimeArray: [Int] = []
    
    var selection = 0
    
    let activityIndicator = UIActivityIndicatorView()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refresher
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.startAnimating()
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .systemRed
        } else {
            segmentedControl.tintColor = .systemRed
        }
        
        fetchFirebaseData()
        
        getMondayData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
        
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func fetchFirebaseData() {
        
        Database.database().reference().child("AnimeCache").child("nsfw").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if !snapshot.exists() {
                return
                
            } else {
                let animeNfwCache = snapshot.value
                
                self?.nsfwAnimeArray = animeNfwCache as! [Int]
                
            }
        }

    }
    
    func filterScheduleData() {
        for (index, malId) in scheduleArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                scheduleArray.remove(at: index)
            }
        }
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            activityIndicator.color = UIColor.black
        }
        
    }
    
    @objc func refreshData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            getMondayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 1 {
            getTuesdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 2 {
            getWednesdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 3 {
            getThursdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 4 {
            getFridayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 5 {
            getSaturdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 6 {
            getSundayData()
        }
        
        refresher.endRefreshing()
    }
    
    func getMondayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getMondaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getTuesdayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getTuesdaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getWednesdayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getWednesdaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getThursdayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getThursdaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getFridayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getFridaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getSaturdayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getSaturdaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func getSundayData() {
        tableView.isHidden = true
        
        activityIndicator.startAnimating()

        networkManager.getSundaySchedule(day: dayString) { [weak self] (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self?.scheduleArray = day
                self?.filterScheduleData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            dayString = "monday"
            scheduleArray.removeAll()
            getMondayData()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            dayString = "tuesday"
            scheduleArray.removeAll()
            getTuesdayData()
        } else if segmentedControl.selectedSegmentIndex == 2 {
            dayString = "wednesday"
            scheduleArray.removeAll()
            getWednesdayData()
        } else if segmentedControl.selectedSegmentIndex == 3 {
            dayString = "thursday"
            scheduleArray.removeAll()
            getThursdayData()
        } else if segmentedControl.selectedSegmentIndex == 4 {
            dayString = "friday"
            scheduleArray.removeAll()
            getFridayData()
        } else if segmentedControl.selectedSegmentIndex == 5 {
            dayString = "saturday"
            scheduleArray.removeAll()
            getSaturdayData()
        } else if segmentedControl.selectedSegmentIndex == 6 {
            dayString = "sunday"
            scheduleArray.removeAll()
            getSundayData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ScheduleTableViewCell else { return UITableViewCell() }
        
        let day: Day
        
        day = scheduleArray[indexPath.row]
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let updatedAtStr = day.airing_start ?? ""
        let updatedAt = dateFormatter.date(from: updatedAtStr)
        
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = dateFormatter.string(from: updatedAt ?? Date())
        
        cell.dateLabel.text = "Started airing: \n\(dateString)"
        cell.titleLabel.text = day.title ?? ""
        cell.scheduleImageView.loadImageUsingCacheWithUrlString(urlString: day.image_url ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let day: Day
        
        day = scheduleArray[indexPath.row]
        selection = day.mal_id ?? 0
        self.performSegue(withIdentifier: "scheduleDetailsSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        }
    }
    
}
