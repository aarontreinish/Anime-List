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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //tableView.isHidden = true
        navigationItem.largeTitleDisplayMode = .always
        
        getMondayData()
    }
    
    func getMondayData() {
        networkManager.getMondaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getTuesdayData() {
        networkManager.getTuesdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getWednesdayData() {
        networkManager.getWednesdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getThursdayData() {
        networkManager.getThursdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getFridayData() {
        networkManager.getFridaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getSaturdayData() {
        networkManager.getSaturdaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getSundayData() {
        networkManager.getSundaySchedule(day: dayString) { (day, error) in
            if let error = error {
                print(error)
            }
            
            if let day = day {
                self.scheduleArray = day
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            dayString = "monday"
            getMondayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 1 {
            dayString = "tuesday"
            getTuesdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 2 {
            dayString = "wednesday"
            getWednesdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 3 {
            dayString = "thursday"
            getThursdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 4 {
            dayString = "friday"
            getFridayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 5 {
            dayString = "saturday"
            getSaturdayData()
        }
        
        if segmentedControl.selectedSegmentIndex == 6 {
            dayString = "sunday"
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
