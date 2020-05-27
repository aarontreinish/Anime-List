//
//  PersistanceManager.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation
import CoreData

final class PersistanceManager {
    
    init() {}
    
    static let shared = PersistanceManager()
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "SavedList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Saved successfully")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            
            return fetchedObjects ?? [T]()
            
        } catch {
            print(error)
            return [T]()
        }
    }
    
    func fetchSortedDataByName<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let nameSort = NSSortDescriptor(key:"name", ascending: true)
        
        fetchRequest.sortDescriptors = [nameSort]
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            
            return fetchedObjects ?? [T]()
            
        } catch {
            print(error)
            return [T]()
        }
    }
    
    func fetchSortedDataByNameDescending<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let nameSort = NSSortDescriptor(key:"name", ascending: false)
        
        fetchRequest.sortDescriptors = [nameSort]
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            
            return fetchedObjects ?? [T]()
            
        } catch {
            print(error)
            return [T]()
        }
    }
    
    func delete<T: NSManagedObject>(_ objectType: T.Type, malId: Float) {
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "mal_id == %f", malId)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as? [NSManagedObject] ?? [] {
                    if result.value(forKey: "mal_id") != nil {
                        context.delete(result)
                        
                        do {
                            try context.save()
                            print("Deleted successfully")
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAllRecords<T: NSManagedObject>(_ objectType: T.Type) {
        
        let entityName = String(describing: objectType)

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func checkIfExists<T: NSManagedObject>(_ objectType: T.Type, malId: Float, attributeName: String) -> Bool {
    
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %f", malId)
        
        var results: [T] = []
        
        do {
            results = try (context.fetch(fetchRequest) as? [T] ?? [])
        } catch {
            print(error)
        }
        
        return results.count > 0
    
    }
}
