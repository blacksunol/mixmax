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
    
    func save(fileId: String, url: String) {
        
        let context = Storage.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "LocalItem", in: context)!
        
        let localItem = NSManagedObject(entity: entity, insertInto: context)
        
        localItem.setValue(fileId, forKeyPath: "fileId")
        localItem.setValue(url, forKeyPath: "url")
        
        do {
            
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func delete(url: String, completed: (String) -> ()) {
        
        let context = Storage.shared.context
        
        let request: NSFetchRequest<LocalItem> = LocalItem.fetchRequest()
        request.predicate = NSPredicate.init(format: "url == %@", url)

        
        
        if let result = try? context.fetch(request) {
            for object in result {
                print("#delete object")
                context.delete(object)
            }
        }
        
        do {
            
            try context.save()
            if let removeUrl = URL(string: url) {
                try FileManager.default.removeItem(at: removeUrl)
            }
            
            completed(url)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        
    }

    var localItems: [(String, String)] {
        
        let context = Storage.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalItem")
        
        do {
            
            let localItem = try context.fetch(fetchRequest)
            
            let localPaths = localItem.flatMap {
                
                (String(describing: $0.value(forKeyPath: "fileId") ?? ""), String(describing: $0.value(forKeyPath: "url") ?? ""))
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
