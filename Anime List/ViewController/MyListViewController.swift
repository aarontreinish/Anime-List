//
//  MyListViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import CoreData
import NotificationBannerSwift

class MyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let persistenceManager = PersistanceManager()
    
    var planToWatch = [PlanToWatch]()
    var watching = [Watching]()
    var savedAnime = [SavedAnime]()
    var onHoldAnime = [OnHoldAnime]()
    var droppedAnime = [DroppedAnime]()
    
    var planToRead = [PlanToRead]()
    var reading = [Reading]()
    var savedManga = [SavedManga]()
    var onHoldManga = [OnHoldManga]()
    var droppedManga = [DroppedManga]()
    
    var selection = 0
    
    private enum Order {
        case notOrdered
        case orderedByName
    }
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var watchSegmentedController: UISegmentedControl!
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = refresher
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
        tableView.addGestureRecognizer(longPress)
        
        if #available(iOS 13.0, *) {
            segmentedController.selectedSegmentTintColor = .systemRed
            watchSegmentedController.selectedSegmentTintColor = .systemRed
            let font = UIFont.systemFont(ofSize: 11)
            watchSegmentedController.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        } else {
            segmentedController.tintColor = .systemRed
            watchSegmentedController.tintColor = .systemRed
            let font = UIFont.systemFont(ofSize: 11)
            watchSegmentedController.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        getSavedAnime()
        getSavedManga()
        
        tableView.reloadData()
    }
    
    @objc func longPressOnTableView(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                if segmentedController.selectedSegmentIndex == 0 {
                    if watchSegmentedController.selectedSegmentIndex == 0 {
                        let malId = planToWatch[indexPath.row].mal_id
                        print(malId)
                        let name = planToWatch[indexPath.row].name ?? ""
                        let imageURL = planToWatch[indexPath.row].image_url ?? ""
                        showLongPressActionSheetAnime(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 1 {
                        let malId = watching[indexPath.row].mal_id
                        print(malId)
                        let name = watching[indexPath.row].name ?? ""
                        let imageURL = watching[indexPath.row].image_url ?? ""
                        showLongPressActionSheetAnime(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 2 {
                        let malId = savedAnime[indexPath.row].mal_id
                        print(malId)
                        let name = savedAnime[indexPath.row].name ?? ""
                        let imageURL = savedAnime[indexPath.row].image_url ?? ""
                        showLongPressActionSheetAnime(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 3 {
                        let malId = onHoldAnime[indexPath.row].mal_id
                        print(malId)
                        let name = onHoldAnime[indexPath.row].name ?? ""
                        let imageURL = onHoldAnime[indexPath.row].image_url ?? ""
                        showLongPressActionSheetAnime(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 4 {
                        let malId = droppedAnime[indexPath.row].mal_id
                        print(malId)
                        let name = droppedAnime[indexPath.row].name ?? ""
                        let imageURL = droppedAnime[indexPath.row].image_url ?? ""
                        showLongPressActionSheetAnime(name: name, malId: malId, imageURL: imageURL)
                    }
                } else if segmentedController.selectedSegmentIndex == 1 {
                    if watchSegmentedController.selectedSegmentIndex == 0 {
                        let malId = planToRead[indexPath.row].mal_id
                        print(malId)
                        let name = planToRead[indexPath.row].name ?? ""
                        let imageURL = planToRead[indexPath.row].image_url ?? ""
                        
                        showLongPressActionSheetManga(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 1 {
                        let malId = reading[indexPath.row].mal_id
                        print(malId)
                        let name = reading[indexPath.row].name ?? ""
                        let imageURL = reading[indexPath.row].image_url ?? ""
                        
                        showLongPressActionSheetManga(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 2 {
                        let malId = savedManga[indexPath.row].mal_id
                        print(malId)
                        let name = savedManga[indexPath.row].name ?? ""
                        let imageURL = savedManga[indexPath.row].image_url ?? ""
                        
                        showLongPressActionSheetManga(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 3 {
                        let malId = onHoldManga[indexPath.row].mal_id
                        print(malId)
                        let name = onHoldManga[indexPath.row].name ?? ""
                        let imageURL = onHoldManga[indexPath.row].image_url ?? ""
                        
                        showLongPressActionSheetManga(name: name, malId: malId, imageURL: imageURL)
                    } else if watchSegmentedController.selectedSegmentIndex == 4 {
                        let malId = droppedManga[indexPath.row].mal_id
                        print(malId)
                        let name = droppedManga[indexPath.row].name ?? ""
                        let imageURL = droppedManga[indexPath.row].image_url ?? ""
                        
                        showLongPressActionSheetManga(name: name, malId: malId, imageURL: imageURL)
                    }
                }
            }
        }
    }
    
    @objc func refreshData() {
        if segmentedController.selectedSegmentIndex == 0 {
            getSavedAnime()
        } else if segmentedController.selectedSegmentIndex == 1 {
            getSavedManga()
        }
        
        refresher.endRefreshing()
        
        tableView.reloadData()
    }
    
    func showLongPressActionSheetAnime(name: String, malId: Float, imageURL: String) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let planToWatchAction = UIAlertAction(title: "Add to Plan to Watch", style: .default) { (action) in
            
            self.addToPlanToWatch(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedAnime()
            self.tableView.reloadData()
        }
        
        let watchingAction = UIAlertAction(title: "Add to Watching", style: .default) { (action) in
            
            self.addToWatching(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedAnime()
            self.tableView.reloadData()
        }
        
        let completedAction = UIAlertAction(title: "Add to Completed", style: .default) { (action) in
            
            self.addToCompletedAnime(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedAnime()
            self.tableView.reloadData()
        }
        
        let onHoldAction = UIAlertAction(title: "Add to On Hold", style: .default) { (action) in
            
            self.addToOnHoldAnime(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedAnime()
            self.tableView.reloadData()
        }
        
        let droppedAction = UIAlertAction(title: "Add to Dropped", style: .default) { (action) in
            
            self.addToDroppedAnime(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedAnime()
            self.tableView.reloadData()
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
            self.removeFromEntity(malId: malId)
            
            self.getSavedAnime()
            self.tableView.reloadData()
            
            let banner = StatusBarNotificationBanner(title: "\(name) removed successfully", style: .danger)
            banner.show()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(planToWatchAction)
        optionMenu.addAction(watchingAction)
        optionMenu.addAction(completedAction)
        optionMenu.addAction(onHoldAction)
        optionMenu.addAction(droppedAction)
        optionMenu.addAction(removeAction)
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func showLongPressActionSheetManga(name: String, malId: Float, imageURL: String) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let planToReadAction = UIAlertAction(title: "Add to Plan to Read", style: .default) { (action) in
            
            self.addToPlanToRead(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedManga()
            self.tableView.reloadData()
        }
        
        let readingAction = UIAlertAction(title: "Add to Reading", style: .default) { (action) in
            
            self.addToReading(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedManga()
            self.tableView.reloadData()
        }
        
        let completedAction = UIAlertAction(title: "Add to Completed", style: .default) { (action) in
            
            self.addToCompletedManga(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedManga()
            self.tableView.reloadData()
        }
        
        let onHoldAction = UIAlertAction(title: "Add to On Hold", style: .default) { (action) in
            
            self.addToOnHoldManga(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedManga()
            self.tableView.reloadData()
        }
        
        let droppedAction = UIAlertAction(title: "Add to Dropped", style: .default) { (action) in
            
            self.addToDroppedManga(name: name, malId: malId, imageURL: imageURL)
            
            self.getSavedManga()
            self.tableView.reloadData()
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
            self.removeFromEntity(malId: malId)
            
            self.getSavedManga()
            self.tableView.reloadData()
            
            let banner = StatusBarNotificationBanner(title: "\(name) removed successfully", style: .danger)
            banner.show()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(planToReadAction)
        optionMenu.addAction(readingAction)
        optionMenu.addAction(completedAction)
        optionMenu.addAction(onHoldAction)
        optionMenu.addAction(droppedAction)
        optionMenu.addAction(removeAction)
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func addToPlanToWatch(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(PlanToWatch.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let planToWatch = PlanToWatch(context: persistenceManager.context)
            planToWatch.mal_id = malId
            planToWatch.image_url = imageURL
            planToWatch.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) added successfully", style: .success)
            banner.show()
            
        }
    }
    
    func addToWatching(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(Watching.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let watching = Watching(context: persistenceManager.context)
            watching.mal_id = malId
            watching.image_url = imageURL
            watching.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) added successfully", style: .success)
            banner.show()

        }
    }
    
    func addToCompletedAnime(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(SavedAnime.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)

            let savedAnime = SavedAnime(context: persistenceManager.context)
            savedAnime.mal_id = malId
            savedAnime.image_url = imageURL
            savedAnime.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) added successfully", style: .success)
            banner.show()

        }
    }
    
    func addToDroppedAnime(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(DroppedAnime.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)

            let dropped = DroppedAnime(context: persistenceManager.context)
            dropped.mal_id = malId
            dropped.image_url = imageURL
            dropped.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) added successfully", style: .success)
            banner.show()

        }
    }
    
    func addToOnHoldAnime(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(OnHoldAnime.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {

            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let onHold = OnHoldAnime(context: persistenceManager.context)
            onHold.mal_id = malId
            onHold.image_url = imageURL
            onHold.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(String(describing: name)) added successfully", style: .success)
            banner.show()

        }
    }
    
    func addToPlanToRead(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(PlanToRead.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(name) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let planToRead = PlanToRead(context: persistenceManager.context)
            planToRead.mal_id = malId
            planToRead.image_url = imageURL
            planToRead.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(name) added successfully", style: .success)
            banner.show()
        }
    }
    
    func addToReading(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(Reading.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(name) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)

            let reading = Reading(context: persistenceManager.context)
            reading.mal_id = malId
            reading.image_url = imageURL
            reading.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(name) added successfully", style: .success)
            banner.show()
        }
    }
    
    func addToCompletedManga(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(SavedManga.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(name) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let savedManga = SavedManga(context: persistenceManager.context)
            savedManga.mal_id = malId
            savedManga.image_url = imageURL
            savedManga.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(name) added successfully", style: .success)
            banner.show()

        }
    }
    
    func addToDroppedManga(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(OnHoldManga.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(name) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let dropped = DroppedManga(context: persistenceManager.context)
            dropped.mal_id = malId
            dropped.image_url = imageURL
            dropped.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(name) added successfully", style: .success)
            banner.show()
            
        }
    }
    
    func addToOnHoldManga(name: String, malId: Float, imageURL: String) {
        let checkIfSaved = persistenceManager.checkIfExists(OnHoldManga.self, malId: malId, attributeName: "mal_id")
        if checkIfSaved == true {
            let banner = StatusBarNotificationBanner(title: "\(name) is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity(malId: malId)
            
            let onHold = OnHoldManga(context: persistenceManager.context)
            onHold.mal_id = malId
            onHold.image_url = imageURL
            onHold.name = name
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(name) added successfully", style: .success)
            banner.show()
        }
    }
    
    func checkIfSavedAtAllAnime(malId: Float) -> Bool {
        let isCompleted = persistenceManager.checkIfExists(SavedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: Float(selection), attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        
        if isCompleted == true || isPlanToWatch == true || isWatching == true || isOnHold == true || isDropped == true {
            return true
        } else {
            return false
        }
    }
    
    func checkWhichEntityAnimeIsSavedIn(indexPathRow: Int) -> String {
        let isCompleted = persistenceManager.checkIfExists(SavedAnime.self, malId: Float(savedAnime[indexPathRow].mal_id), attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: Float(planToWatch[indexPathRow].mal_id), attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: Float(watching[indexPathRow].mal_id), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldAnime.self, malId: Float(onHoldAnime[indexPathRow].mal_id), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedAnime.self, malId: Float(droppedAnime[indexPathRow].mal_id), attributeName: "mal_id")
        
        if isCompleted == true {
            return "Completed"
        }
        
        if isPlanToWatch == true {
            return "Plan to watch"
        }
        
        if isWatching == true {
            return "Watching"
        }
        
        if isOnHold == true {
            return "On hold"
        }
        
        if isDropped == true {
            return "Dropped"
        }
        
        return ""
    }
    
    func removeFromEntity(malId: Float) {
        let isCompletedAnime = persistenceManager.checkIfExists(SavedAnime.self, malId: malId, attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: malId, attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: malId, attributeName: "mal_id")
        
        let isOnHoldAnime = persistenceManager.checkIfExists(OnHoldAnime.self, malId: malId, attributeName: "mal_id")
        
        let isDroppedAnime = persistenceManager.checkIfExists(DroppedAnime.self, malId: malId, attributeName: "mal_id")
        
        let isCompletedManga = persistenceManager.checkIfExists(SavedManga.self, malId: malId, attributeName: "mal_id")
        
        let isPlanToRead = persistenceManager.checkIfExists(PlanToRead.self, malId: malId, attributeName: "mal_id")
        
        let isReading = persistenceManager.checkIfExists(Reading.self, malId: malId, attributeName: "mal_id")
        
        let isOnHoldManga = persistenceManager.checkIfExists(OnHoldManga.self, malId: malId, attributeName: "mal_id")
        
        let isDroppedManga = persistenceManager.checkIfExists(DroppedManga.self, malId: malId, attributeName: "mal_id")
        
        if isCompletedAnime == true {
            deleteAnime(entity: SavedAnime.self, malId: malId)
        }
        
        if isPlanToWatch == true {
            deleteAnime(entity: PlanToWatch.self, malId: malId)
        }
        
        if isWatching == true {
            deleteAnime(entity: Watching.self, malId: malId)
        }
        
        if isOnHoldAnime == true {
            deleteAnime(entity: OnHoldAnime.self, malId: malId)
        }
        
        if isDroppedAnime == true {
            deleteAnime(entity: DroppedAnime.self, malId: malId)
        }
        
        if isCompletedManga == true {
            deleteAnime(entity: SavedManga.self, malId: malId)
        }
        
        if isPlanToRead == true {
            deleteAnime(entity: PlanToRead.self, malId: malId)
        }
        
        if isReading == true {
            deleteAnime(entity: Reading.self, malId: malId)
        }
        
        if isOnHoldManga == true {
            deleteAnime(entity: OnHoldManga.self, malId: malId)
        }
        
        if isDroppedManga == true {
            deleteAnime(entity: DroppedManga.self, malId: malId)
        }
    }
    
    func deleteAnime<T: NSManagedObject>(entity: T.Type, malId: Float) {
        persistenceManager.delete(entity.self, malId: malId)
    }
    
    func getSavedAnime() {
        let planToWatchList = persistenceManager.fetchSortedDataByName(PlanToWatch.self)
        planToWatch = planToWatchList
        
        let watchingList = persistenceManager.fetchSortedDataByName(Watching.self)
        watching = watchingList
        
        let completedList = persistenceManager.fetchSortedDataByName(SavedAnime.self)
        savedAnime = completedList
        
        let onHoldList = persistenceManager.fetchSortedDataByName(OnHoldAnime.self)
        onHoldAnime = onHoldList
        
        let droppedList = persistenceManager.fetchSortedDataByName(DroppedAnime.self)
        droppedAnime = droppedList
        
    }
    
    func getSavedManga() {
        let planToReadList = persistenceManager.fetchSortedDataByName(PlanToRead.self)
        planToRead = planToReadList
        
        let readingList = persistenceManager.fetchSortedDataByName(Reading.self)
        reading = readingList
        
        let completedList = persistenceManager.fetchSortedDataByName(SavedManga.self)
        savedManga = completedList
        
        let onHoldList = persistenceManager.fetchSortedDataByName(OnHoldManga.self)
        onHoldManga = onHoldList
        
        let droppedList = persistenceManager.fetchSortedDataByName(DroppedManga.self)
        droppedManga = droppedList
    }
    
    func sortByNameAscending() {
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let anime = persistenceManager.fetchSortedDataByName(PlanToWatch.self)
                planToWatch = anime
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let anime = persistenceManager.fetchSortedDataByName(Watching.self)
                watching = anime
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let anime = persistenceManager.fetchSortedDataByName(SavedAnime.self)
                savedAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let anime = persistenceManager.fetchSortedDataByName(OnHoldAnime.self)
                onHoldAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let anime = persistenceManager.fetchSortedDataByName(DroppedAnime.self)
                droppedAnime = anime
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let manga = persistenceManager.fetchSortedDataByName(PlanToRead.self)
                planToRead = manga
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let manga = persistenceManager.fetchSortedDataByName(Reading.self)
                reading = manga
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let manga = persistenceManager.fetchSortedDataByName(SavedManga.self)
                savedManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let manga = persistenceManager.fetchSortedDataByName(OnHoldManga.self)
                onHoldManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let manga = persistenceManager.fetchSortedDataByName(DroppedManga.self)
                droppedManga = manga
            }
        }
        
        tableView.reloadData()
    }
    
    func sortByNameDescending() {
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let anime = persistenceManager.fetchSortedDataByNameDescending(PlanToWatch.self)
                planToWatch = anime
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let anime = persistenceManager.fetchSortedDataByNameDescending(Watching.self)
                watching = anime
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let anime = persistenceManager.fetchSortedDataByNameDescending(SavedAnime.self)
                savedAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let anime = persistenceManager.fetchSortedDataByNameDescending(OnHoldAnime.self)
                onHoldAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let anime = persistenceManager.fetchSortedDataByNameDescending(DroppedAnime.self)
                droppedAnime = anime
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let manga = persistenceManager.fetchSortedDataByNameDescending(PlanToRead.self)
                planToRead = manga
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let manga = persistenceManager.fetchSortedDataByNameDescending(Reading.self)
                reading = manga
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let manga = persistenceManager.fetchSortedDataByNameDescending(SavedManga.self)
                savedManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let manga = persistenceManager.fetchSortedDataByNameDescending(OnHoldManga.self)
                onHoldManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let manga = persistenceManager.fetchSortedDataByNameDescending(DroppedManga.self)
                droppedManga = manga
            }
        }
        
        tableView.reloadData()
    }
    
    func sortByRecentlyAdded() {

        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let planToWatchList = persistenceManager.fetch(PlanToWatch.self)
                planToWatch = planToWatchList
                
                let anime = Array(planToWatch.reversed())
                planToWatch = anime
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let watchingList = persistenceManager.fetch(Watching.self)
                watching = watchingList
                
                let anime = Array(watching.reversed())
                watching = anime
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let completedList = persistenceManager.fetch(SavedAnime.self)
                savedAnime = completedList
                
                let anime = Array(savedAnime.reversed())
                savedAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let onHoldList = persistenceManager.fetch(OnHoldAnime.self)
                onHoldAnime = onHoldList
                
                let anime = Array(onHoldAnime.reversed())
                onHoldAnime = anime
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let droppedList = persistenceManager.fetch(DroppedAnime.self)
                droppedAnime = droppedList
                
                let anime = Array(droppedAnime.reversed())
                droppedAnime = anime
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let planToReadList = persistenceManager.fetch(PlanToRead.self)
                planToRead = planToReadList
                
                let manga = Array(planToRead.reversed())
                planToRead = manga
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let readingList = persistenceManager.fetch(Reading.self)
                reading = readingList
                
                let manga = Array(reading.reversed())
                reading = manga
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let completedList = persistenceManager.fetch(SavedManga.self)
                savedManga = completedList
                
                let manga = Array(savedManga.reversed())
                savedManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let onHoldList = persistenceManager.fetch(OnHoldManga.self)
                onHoldManga = onHoldList
                
                let manga = Array(onHoldManga.reversed())
                onHoldManga = manga
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let droppedList = persistenceManager.fetch(DroppedManga.self)
                droppedManga = droppedList
                
                let manga = Array(droppedManga.reversed())
                droppedManga = manga
            }
        }
        
        tableView.reloadData()
    }
    
    func showDeleteAllAlert<T: NSManagedObject>(entity: T.Type, title: String) {
        
        let alertController = UIAlertController(title: "Are you sure you want to delete all of your \(title)?", message: "", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action2 = UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction) in
            self.persistenceManager.deleteAllRecords(entity.self)
            
            if self.segmentedController.selectedSegmentIndex == 0 {
                if self.watchSegmentedController.selectedSegmentIndex == 0 {
                    self.planToWatch.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 1 {
                    self.watching.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 2 {
                    self.savedAnime.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 3 {
                    self.onHoldAnime.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 4 {
                    self.droppedAnime.removeAll()
                }
            } else if self.segmentedController.selectedSegmentIndex == 1 {
                if self.watchSegmentedController.selectedSegmentIndex == 0 {
                    self.planToRead.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 1 {
                    self.reading.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 2 {
                    self.savedAnime.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 3 {
                    self.onHoldManga.removeAll()
                } else if self.watchSegmentedController.selectedSegmentIndex == 4 {
                    self.droppedManga.removeAll()
                }
            }
            
            self.tableView.reloadData()
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteAll() {
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                showDeleteAllAlert(entity: PlanToWatch.self, title: "Plan to Watch Anime")
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                showDeleteAllAlert(entity: Watching.self, title: "Watching Anime")
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                showDeleteAllAlert(entity: SavedAnime.self, title: "Completed Anime")
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                showDeleteAllAlert(entity: OnHoldAnime.self, title: "On Hold Anime")
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                showDeleteAllAlert(entity: DroppedAnime.self, title: "Dropped Anime")
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                showDeleteAllAlert(entity: PlanToRead.self, title: "Plan to Read Manga")
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                showDeleteAllAlert(entity: Reading.self, title: "Reading Manga")
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                showDeleteAllAlert(entity: SavedManga.self, title: "Completed Manga")
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                showDeleteAllAlert(entity: OnHoldManga.self, title: "On Hold Manga")
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                showDeleteAllAlert(entity: DroppedManga.self, title: "Dropped Manga")
            }
        }
    }
    
    @IBAction func segmentedControllerAction(_ sender: Any) {
        
        if segmentedController.selectedSegmentIndex == 0 {
            watchSegmentedController.setTitle("Plan to Watch", forSegmentAt: 0)
            watchSegmentedController.setTitle("Watching", forSegmentAt: 1)
        } else if segmentedController.selectedSegmentIndex == 1 {
            watchSegmentedController.setTitle("Plan to Read", forSegmentAt: 0)
            watchSegmentedController.setTitle("Reading", forSegmentAt: 1)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func watchSegmentedControllerAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func ellipseButtonAction(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let deleteAllAction = UIAlertAction(title: "Delete All", style: .destructive) { (action) in
            self.deleteAll()
        }
        
        let orderByNameAscendingAction = UIAlertAction(title: "Order by name ascending", style: .default) { (action) in
            self.sortByNameAscending()
        }
        
        let orderByNameDescendingAction = UIAlertAction(title: "Order by name descending", style: .default) { (action) in
            self.sortByNameDescending()
        }
        
        let sortByRecentlyAdded = UIAlertAction(title: "Order by recently added", style: .default) { (action) in
            self.sortByRecentlyAdded()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(sortByRecentlyAdded)
        optionMenu.addAction(orderByNameAscendingAction)
        optionMenu.addAction(orderByNameDescendingAction)
        optionMenu.addAction(deleteAllAction)
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 25))
        
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                totalLabel.text = "Total: \(planToWatch.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                totalLabel.text = "Total: \(watching.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                totalLabel.text = "Total: \(savedAnime.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                totalLabel.text = "Total: \(onHoldAnime.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                totalLabel.text = "Total: \(droppedAnime.count)"
            }
            
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                totalLabel.text = "Total: \(planToRead.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                totalLabel.text = "Total: \(reading.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                totalLabel.text = "Total: \(savedManga.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                totalLabel.text = "Total: \(onHoldManga.count)"
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                totalLabel.text = "Total: \(droppedManga.count)"
            }
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                return planToWatch.count
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                return watching.count
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                return savedAnime.count
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                return onHoldAnime.count
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                return droppedAnime.count
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                return planToRead.count
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                return reading.count
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                return savedManga.count
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                return onHoldManga.count
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                return droppedManga.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myListCell") as? MyListTableViewCell else { return UITableViewCell() }
        
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let anime = planToWatch[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
                cell.titleLabel.text = anime.name
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let anime = watching[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
                cell.titleLabel.text = anime.name
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let anime = savedAnime[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
                cell.titleLabel.text = anime.name
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let anime = onHoldAnime[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
                cell.titleLabel.text = anime.name
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let anime = droppedAnime[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
                cell.titleLabel.text = anime.name
            }
            
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let manga = planToRead[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
                cell.titleLabel.text = manga.name
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let manga = reading[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
                cell.titleLabel.text = manga.name
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let manga = savedManga[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
                cell.titleLabel.text = manga.name
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let manga = onHoldManga[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
                cell.titleLabel.text = manga.name
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let manga = droppedManga[indexPath.row]
                cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
                cell.titleLabel.text = manga.name
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if segmentedController.selectedSegmentIndex == 0 {
                if watchSegmentedController.selectedSegmentIndex == 0 {
                    let anime = planToWatch[indexPath.row]
                    persistenceManager.context.delete(anime)
                    planToWatch.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 1 {
                    let anime = watching[indexPath.row]
                    persistenceManager.context.delete(anime)
                    watching.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 2 {
                    let anime = savedAnime[indexPath.row]
                    persistenceManager.context.delete(anime)
                    savedAnime.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 3 {
                    let anime = onHoldAnime[indexPath.row]
                    persistenceManager.context.delete(anime)
                    onHoldAnime.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 4 {
                    let anime = droppedAnime[indexPath.row]
                    persistenceManager.context.delete(anime)
                    droppedAnime.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                }
            } else if segmentedController.selectedSegmentIndex == 1 {
                if watchSegmentedController.selectedSegmentIndex == 0 {
                    let manga = planToRead[indexPath.row]
                    persistenceManager.context.delete(manga)
                    planToRead.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 1 {
                    let manga = reading[indexPath.row]
                    persistenceManager.context.delete(manga)
                    reading.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 2 {
                    let manga = savedManga[indexPath.row]
                    persistenceManager.context.delete(manga)
                    savedManga.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 3 {
                    let manga = onHoldManga[indexPath.row]
                    persistenceManager.context.delete(manga)
                    onHoldManga.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                } else if watchSegmentedController.selectedSegmentIndex == 4 {
                    let manga = droppedManga[indexPath.row]
                    persistenceManager.context.delete(manga)
                    droppedManga.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    persistenceManager.save()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentedController.selectedSegmentIndex == 0 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let anime = planToWatch[indexPath.row]
                selection = Int(anime.mal_id)
                self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let anime = watching[indexPath.row]
                selection = Int(anime.mal_id)
                self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let anime = savedAnime[indexPath.row]
                selection = Int(anime.mal_id)
                self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let anime = onHoldAnime[indexPath.row]
                selection = Int(anime.mal_id)
                self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let anime = droppedAnime[indexPath.row]
                selection = Int(anime.mal_id)
                self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
            }
        } else if segmentedController.selectedSegmentIndex == 1 {
            if watchSegmentedController.selectedSegmentIndex == 0 {
                let manga = planToRead[indexPath.row]
                selection = Int(manga.mal_id)
                self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 1 {
                let manga = reading[indexPath.row]
                selection = Int(manga.mal_id)
                self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 2 {
                let manga = savedManga[indexPath.row]
                selection = Int(manga.mal_id)
                self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 3 {
                let manga = onHoldManga[indexPath.row]
                selection = Int(manga.mal_id)
                self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
            } else if watchSegmentedController.selectedSegmentIndex == 4 {
                let manga = droppedManga[indexPath.row]
                selection = Int(manga.mal_id)
                self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myListDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        } else if segue.identifier == "myListMangaDetailsSegue" {
            let mangaDetailsViewController = segue.destination as? MangaDetailsViewController
            
            mangaDetailsViewController?.selection = selection
        }
    }
    
}

//if watchSegmentedController.selectedSegmentIndex == 0 {
//
//} else if watchSegmentedController.selectedSegmentIndex == 1 {
//
//} else if watchSegmentedController.selectedSegmentIndex == 2 {
//
//} else if watchSegmentedController.selectedSegmentIndex == 3 {
//
//} else if watchSegmentedController.selectedSegmentIndex == 4 {
//
//}
