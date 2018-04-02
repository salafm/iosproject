//
//  News.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/13/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

class News: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var newsCons: NSLayoutConstraint!
    @IBOutlet weak var eventCons: NSLayoutConstraint!
    @IBOutlet weak var event: UICollectionView!
    @IBOutlet weak var news: UICollectionView!
    @IBOutlet weak var eventLine: UIView!
    @IBOutlet weak var newsLine: UIView!
    
    var eventArray = [Dictionary<String, Any>]()
    var newsArray = [Dictionary<String, Any>]()
    
    var eventCount = 0
    var newsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventLine.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        newsLine.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        
        event.bounces = false
        news.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isTranslucent = false
        
        eventCount = 3
        newsCount = 3
        
        get_event(eventCount)
        get_news(newsCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == event {
            return eventArray.count
        }else{
            return newsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == event {
            let cell = event.dequeueReusableCell(withReuseIdentifier: "EventCollection", for: indexPath) as! EventCollection
            
            let imageString = eventArray[indexPath.row]["gambar"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            
            cell.pics.image = UIImage(data: imageData! as Data)
            
            eventCons.constant = cell.frame.size.height
            
            return cell
        }else{
            let cell = news.dequeueReusableCell(withReuseIdentifier: "NewsCollection", for: indexPath) as! NewsCollection
            
            let imageString = newsArray[indexPath.row]["gambar"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            
            cell.pics.image = UIImage(data: imageData! as Data)
            
            newsCons.constant = cell.frame.size.height
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == event {
            if self.eventArray[indexPath.row]["link"] as! String != "" {
                UIApplication.shared.open(URL(string: self.eventArray[indexPath.row]["link"] as! String)!, options: [:], completionHandler: nil)
            }
        }else{
            if self.newsArray[indexPath.row]["link"] as! String != "" {
                UIApplication.shared.open(URL(string: self.newsArray[indexPath.row]["link"] as! String)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == event {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "eventNext", for: indexPath)
            
            return view
        }else{
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "newsNext", for: indexPath)
            
            return view
        }

    }
    
    func get_news(_ count: Int){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let start: String
            let count: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/event")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            start: "0",
            count: "\(count)"
        )
        
        do{
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(params)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
            request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
            request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
            request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        }catch{
            print(error)
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                return
            }
            
            //            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //            print("responseString = \(responseString!)")
            
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
//                        let response = temp["response"]! as! Array<Dictionary<String, Any>>
//                        print(response)
                        self.newsArray = temp["response"]! as! Array<Dictionary<String, Any>>
                        
                        
                        self.news.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        Loader.shared.stopLoader()
                    }
                }catch{
                    print(error)
                }
                
            }
        }
        task.resume()
    }
    
    func get_event(_ count:Int){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let start: String
            let count: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/news_promo")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            start: "0",
            count: "\(count)"
        )
        
        do{
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(params)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
            request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
            request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
            request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        }catch{
            print(error)
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                return
            }
            
            //            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //            print("responseString = \(responseString!)")
            
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.eventArray = temp["response"]! as! Array<Dictionary<String, Any>>
//                        let response = temp["response"]! as! Array<Dictionary<String, Any>>
//                        print(response)
                        
                        self.event.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        Loader.shared.stopLoader()
                    }
                }catch{
                    print(error)
                }
                
            }
        }
        task.resume()
    }
    

    @IBAction func loadEvent(_ sender: UIButton) {
        eventCount += 2
        get_event(eventCount)
    }
    
    @IBAction func loadNews(_ sender: UIButton) {
        newsCount += 2
        get_news(newsCount)
    }
    
}
