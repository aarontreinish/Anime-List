//
//  ScheduleViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/23/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dayString = "monday"
    
    var scheduleArray: [Day] = []
    
    var networkManager = NetworkManager()
    
    var selection = 0
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
        
        tableView.isHidden = true
        
        activityIndicator.startAnimating()
        
        navigationItem.largeTitleDisplayMode = .always
        
        getMondayData()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
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
        
        activityIndicator.startAnimating()

        networkManager.getMondaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getTuesdayData() {
        
        activityIndicator.startAnimating()

        networkManager.getTuesdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getWednesdayData() {
        
        activityIndicator.startAnimating()

        networkManager.getWednesdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getThursdayData() {
        
        activityIndicator.startAnimating()

        networkManager.getThursdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getFridayData() {
        
        activityIndicator.startAnimating()

        networkManager.getFridaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getSaturdayData() {
        
        activityIndicator.startAnimating()

        networkManager.getSaturdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func getSundayData() {
        
        activityIndicator.startAnimating()

        networkManager.getSundaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            dayString = "monday"
            tableView.isHidden = true
            getMondayData()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            dayString = "tuesday"
            tableView.isHidden = true
            getTuesdayData()
        } else if segmentedControl.selectedSegmentIndex == 2 {
            dayString = "wednesday"
            tableView.isHidden = true
            getWednesdayData()
        } else if segmentedControl.selectedSegmentIndex == 3 {
            dayString = "thursday"
            tableView.isHidden = true
            getThursdayData()
        } else if segmentedControl.selectedSegmentIndex == 4 {
            dayString = "friday"
            tableView.isHidden = true
            getFridayData()
        } else if segmentedControl.selectedSegmentIndex == 5 {
            dayString = "saturday"
            tableView.isHidden = true
            getSaturdayData()
        } else if segmentedControl.selectedSegmentIndex == 6 {
            dayString = "sunday"
            tableView.isHidden = true
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
