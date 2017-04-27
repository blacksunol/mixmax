//
//  ItemListViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController {
    
    @IBOutlet weak var itemListCollectionView: UICollectionView!
    fileprivate var items = [Item]()
    
    private var isDropBoxLogin: Bool {
        let kDropBoxToken = "http://localhost/#access_token="
        if let _ = UserDefaults.standard.value(forKey: kDropBoxToken) {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNibs()

        loadItems()
    }
    
    @IBAction func closeIButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(ItemListCollectionViewCell.self, forCellWithReuseIdentifier: "ItemListCollectionViewCell")
    }
    
    
    private func loadItems() {
        let kDropBoxToken = "http://localhost/#access_token="
        let dropBoxTokenString = UserDefaults.standard.value(forKey: kDropBoxToken) ?? ""
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://api.dropboxapi.com/2/files/list_folder")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(dropBoxTokenString)", forHTTPHeaderField: "Authorization")
        let jsonDictionary = ["path": ""]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                let json = try?  JSON(data: data!)
                guard let jsonArray = json?["entries"].array else {
                    return
                }
                
                for jsonItem in jsonArray {
                    let item = Item()
                    item.name = jsonItem["name"].string ?? ""
                    self.items.append(item)
                }
                print("number of items: \(self.items.count)")
                self.itemListCollectionView.reloadData()
            }
        }
        task.resume()
    }
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                      for: indexPath) as! ItemListCollectionViewCell
        cell.backgroundColor = UIColor.green
        return cell
    }
}
