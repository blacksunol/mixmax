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
    var item = Item()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNibs()
        loadItems()
    }
    
    @IBAction func closeIButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(UINib(nibName: "ItemListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemListCollectionViewCell")
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
        let jsonDictionary = ["path": item.path]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async { [weak self] in
                    let json = try?  JSON(data: data!)
                    guard let jsonArray = json?["entries"].array else {
                        return
                    }
                    
                    for jsonItem in jsonArray {
                        let item = Item()
                        item.name = jsonItem["name"].string ?? ""
                        item.tag = jsonItem[".tag"].string ?? ""
                        item.path = jsonItem["path_lower"].string ?? ""
                        self?.items.append(item)
                    }
                    self?.itemListCollectionView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    fileprivate func loadItemLink() {
        let kDropBoxToken = "http://localhost/#access_token="
        let dropBoxTokenString = UserDefaults.standard.value(forKey: kDropBoxToken) ?? ""
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://api.dropboxapi.com/2/files/get_temporary_link")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(dropBoxTokenString)", forHTTPHeaderField: "Authorization")
        let jsonDictionary = ["path": item.path]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async { [weak self] in
                    let json = try?  JSON(data: data!)
                    if let link = json?["link"].string {
                        print("*##"+link)
                        let storyboard = UIStoryboard(name: "JukeViewController", bundle: nil)
                        if let jukeViewController = storyboard.instantiateViewController(withIdentifier :"JukeViewController") as? JukeViewController {
                            jukeViewController.link = link
                            self?.present(jukeViewController, animated: true)
                        }
                    }
                }
            }
        }
        task.resume()

    }
    
    private func loadGoogle() {
        self.itemListCollectionView.reloadData()
    }
    
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                      for: indexPath) as! ItemListCollectionViewCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        print(item.path)
        if item.tag == "file" {
            self.item = item
            loadItemLink()
            return
        }
        let storyboard = UIStoryboard(name: "ItemListViewController", bundle: nil)
        if let itemListViewController = storyboard.instantiateViewController(withIdentifier :"ItemListViewController") as? ItemListViewController {
            let item = items[indexPath.row]
            itemListViewController.item = item
            present(itemListViewController, animated: true)
        }
    }
}
