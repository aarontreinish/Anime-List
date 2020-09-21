//
//  MyListViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

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
    
    func convertToJSONArray(entity: [NSManagedObject]) -> Any {
        var jsonArray: [[String: Any]] = []
        for item in entity {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    func saveJSONToDevice(array: Any) {
        guard let watchingData = try? JSONSerialization.data(withJSONObject: array) else { return }
        print(watchingData)
        UserDefaults.standard.set(watchingData, forKey: "watching")
        
//        do {
//            let fileURL = try FileManager.default
//                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                .appendingPathComponent("watching.json")
//
//            try JSONSerialization.data(withJSONObject: array)
//                .write(to: fileURL)
//        } catch {
//            print(error)
//        }
    }
    
    func readJSONFromDevice() {
        
        let data = UserDefaults.standard.object(forKey: "watching")
        print(data)
        
        guard let anime = try? JSONDecoder().decode([AnimeWidget].self, from: data as! Data) else { return }
        
        print(anime)
//        do {
//            let fileURL = try FileManager.default
//                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                .appendingPathComponent("watching.json")
//
//            let data = try Data(contentsOf: fileURL)
//            let foo = try JSONDecoder().decode([AnimeWidget].self, from: data)
//            print(foo)
//        } catch {
//            print(error)
//        }
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
    
    func getSavedAnime() {
        let planToWatchList = persistenceManager.fetchSortedDataByName(PlanToWatch.self)
        planToWatch = planToWatchList
        
        let watchingList = persistenceManager.fetchSortedDataByName(Watching.self)
        watching = watchingList
        
        let convertedEntity = convertToJSONArray(entity: watching)
        saveJSONToDevice(array: convertedEntity)
        
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
