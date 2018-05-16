//
//  LocalPath.swift
//  mixmax
//
//  Created by Apple on 5/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//
import CoreData

class LocalPath {
    
    func fetchLocalPath(items: [Item]) -> [Item] {
        
        return items.map { fetchLocalItem(item: $0)}
    }
    
    func fetchLocalItem(item: Item) -> Item {
        
        var copyItem = item
        localItems.forEach {
            
            if $0.0 == copyItem.localPath {
                
                copyItem.track.localUrl = $0.1
                print("#localItem3: \($0)")
            }
        }

        return copyItem
    }
    
    func save(path: String, url: String) {
        
        let context = Storage.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "LocalItem", in: context)!
        
        let localItem = NSManagedObject(entity: entity, insertInto: context)
        
        localItem.setValue(path, forKeyPath: "path")
        localItem.setValue(url, forKeyPath: "url")
        
        do {
            
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func delete(path: String) {
        
        let context = Storage.shared.context
        context.perform {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalItem")
            let predicate = NSPredicate(format: "path == %@", path)
            request.predicate = predicate
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                objectIDs.forEach { objectID in
                     let item = context.object(with: objectID)
                    context.refresh(item, mergeChanges: false)
                }
            } catch {
                fatalError("Failed to execute request: \(error)")
            }
        }
    }

    var localItems: [(String, String)] {
        
        let context = Storage.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalItem")
        
        do {
            
            let localItem = try context.fetch(fetchRequest)
            
            let localPaths = localItem.flatMap {
                
                (String(describing: $0.value(forKeyPath: "path") ?? ""), String(describing: $0.value(forKeyPath: "url") ?? ""))
            }
            
            return localPaths
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL, fileName: String?) -> URL {
        
        let name = fileName ?? ""
        let path = documentsPath.appendingPathComponent(name)
        
//        if let localPath = item?.localPath {
//            
//            let localPath2 = LocalPath()
//            localPath2.save(path: localPath, url: path.absoluteString)
//        }
        
        return path
    }
}
