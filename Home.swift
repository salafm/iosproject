//
//  Home.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/12/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow

class Home: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var iklan: ImageSlideshow!
    @IBOutlet weak var promo: ImageSlideshow!
    @IBOutlet weak var Menu: UICollectionView!
    @IBOutlet weak var heightSlide: NSLayoutConstraint!
    @IBOutlet weak var popularMerchant: UICollectionView!
    
    var array: Array<Dictionary<String, AnyObject>>? = []
    var popArray = [Dictionary<String, Any>]()
    
    var arrayPromo: Array<Dictionary<String, Any>>! = []
    var urlPromo = [String]()
    var gambarPromo = [AlamofireSource]()
    
    var arrayIklan: Array<Dictionary<String, Any>>! = []
    var urlIklan = [String]()
    var gambarIklan = [AlamofireSource]()
    
    let heightRatio = UIScreen.main.bounds.height / 736
    let widthRatio = UIScreen.main.bounds.width / 414
    
    var roundButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request_get()
        self.get_iklan()
        self.get_promo()
        self.get_popMerchant()
        
        Menu.isScrollEnabled = false
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(Home.tapIklan))
        iklan.isUserInteractionEnabled = true
        iklan.addGestureRecognizer(singleTap)
        
        let promoTap = UITapGestureRecognizer(target: self, action: #selector(Home.tapPromo))
        promo.addGestureRecognizer(promoTap)
        
        heightSlide.constant = promo.frame.size.width * widthRatio
        
        popularMerchant.bounces = false
        
        //floatingbutton
        self.roundButton = UIButton(type: .custom)
        self.roundButton.setTitleColor(UIColor.orange, for: .normal)
        self.roundButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(roundButton)
    }
    
    func slideShowPromo(){
        for index in 0...arrayPromo.count-1 {
            gambarPromo.insert(AlamofireSource(urlString: arrayPromo[index]["gambar"] as! String)!, at: index)
            urlPromo.insert(arrayPromo[index]["link"] as! String, at: index)
        }
        
        promo.slideshowInterval = 5.0
        promo.pageControlPosition = PageControlPosition.insideScrollView
        promo.pageControl.currentPageIndicatorTintColor = UIColor.white
        promo.pageControl.pageIndicatorTintColor = UIColor.lightGray
        promo.contentScaleMode = UIViewContentMode.scaleAspectFit
        
        promo.setImageInputs(gambarPromo)
    }
    
    func slideShowIklan(){
        for index in 0...arrayIklan.count-1 {
            gambarIklan.insert(AlamofireSource(urlString: arrayIklan[index]["icon"] as! String)!, at: index)
            urlIklan.insert(arrayIklan[index]["link"] as! String, at: index)
//                    print(arrayIklan[index])
        }
    
        iklan.slideshowInterval = 10.0
        iklan.pageControlPosition = PageControlPosition.hidden
        iklan.contentScaleMode = UIViewContentMode.scaleAspectFit
        
        iklan.setImageInputs(gambarIklan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == Menu {
             return array!.count
        }else{
            return popArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == Menu{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
            let imageString = array![indexPath.row]["icon"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            cell.image.image = UIImage(data: imageData! as Data)
            cell.Desc.text = array![indexPath.row]["nama"] as? String
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popMerchant", for: indexPath) as! popMerchant
            let imageString = popArray[indexPath.row]["foto"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            cell.pics.image = UIImage(data: imageData! as Data)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == Menu {
            let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "CategoryList") as! CategoryList
            nextPage.id = array![indexPath.row]["id_k"] as? String
            
            self.navigationController?.pushViewController(nextPage, animated: true)
        }else{
            let merchantDetail = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailMerchant
            merchantDetail.id = popArray[indexPath.row]["id_m"] as? String
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(merchantDetail, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == Menu {
            var collectionViewSize = collectionView.frame.size
            let width = collectionViewSize.width
            collectionViewSize.width = width/5.0 //Display Three elements in a row.
            collectionViewSize.height = width/5.0
            
            Menu.frame.size.height = width
            
            return collectionViewSize
        }else{
            if UIScreen.main.bounds.height == 812.0 {
                return CGSize(width: 192, height: 225)
            }else{
                return CGSize(width: 192*widthRatio, height: 225*heightRatio)
            }
        }
    }
    
    func request_get(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/kategori"
        
        // parameter
        let urlWithParams = scriptUrl
//            + "?keyword=\(keyword)"
        
        //ubah ke urlquery, biar kalo ada spasi gak jadi nil
        let urlWithSpaces = urlWithParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // convert ke type url swift
        let myUrl = NSURL(string: urlWithSpaces!);
        
        
        // buat url request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        
        // Set method, get ato post
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
        request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
        request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        
        
        // Eksekusi http request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            
            // cuma untuk testing console
//            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            print("responseString = \(responseString!)")
            
            
            //dispacth async call (jelasinnya bingung wkwk)
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    self.array = temp["response"] as? Array<Dictionary<String, AnyObject>>
                    //                print(self.array!);
                    
                    //                self.stopLoader()
                    
                    self.Menu.reloadData()
                    Loader.shared.stopLoader()
                    
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func get_iklan(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/iklan"
        
        // parameter
        let urlWithParams = scriptUrl
        //            + "?keyword=\(keyword)"
        
        //ubah ke urlquery, biar kalo ada spasi gak jadi nil
        let urlWithSpaces = urlWithParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // convert ke type url swift
        let myUrl = NSURL(string: urlWithSpaces!);
        
        
        // buat url request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        
        // Set method, get ato post
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
        request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
        request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        
        
        // Eksekusi http request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            
            // cuma untuk testing console
            //            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //            print("responseString = \(responseString!)")
            
            
            //dispacth async call (jelasinnya bingung wkwk)
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.arrayIklan = temp["response"]! as! Array<Dictionary<String, Any>>
//                                                                print(self.arrayIklan)
                        self.slideShowIklan()
                        Loader.shared.stopLoader()
                        
                    }else{
                        print("iklannya kosong")
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func get_promo(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/promo"
        
        // parameter
        let urlWithParams = scriptUrl
        //            + "?keyword=\(keyword)"
        
        //ubah ke urlquery, biar kalo ada spasi gak jadi nil
        let urlWithSpaces = urlWithParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // convert ke type url swift
        let myUrl = NSURL(string: urlWithSpaces!);
        
        
        // buat url request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        
        // Set method, get ato post
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
        request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
        request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        
        
        // Eksekusi http request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            //dispacth async call (jelasinnya bingung wkwk)
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.arrayPromo = temp["response"]! as! Array<Dictionary<String, Any>>
                        //                    print(self.arrayPromo)
                        self.slideShowPromo()
                        Loader.shared.stopLoader()
                        
                    }else{
                        print("kosong")
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func get_popMerchant(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/merchant/populer"
        
        // parameter
        let urlWithParams = scriptUrl
        //            + "?keyword=\(keyword)"
        
        //ubah ke urlquery, biar kalo ada spasi gak jadi nil
        let urlWithSpaces = urlWithParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // convert ke type url swift
        let myUrl = NSURL(string: urlWithSpaces!);
        
        
        // buat url request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        
        // Set method, get ato post
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
        request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.addValue(UserDefaults.standard.string(forKey: "uid")!, forHTTPHeaderField: "uid")
        request.addValue(UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "token")
        
        
        // Eksekusi http request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            //dispacth async call (jelasinnya bingung wkwk)
            DispatchQueue.main.async {
                do{
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.popArray = temp["response"]! as! Array<Dictionary<String, Any>>
//                                            print(self.popArray)
                        
                        self.popularMerchant.reloadData()
                        Loader.shared.stopLoader()
                        
                    }else{
                        print("kosong")
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //Action
    @objc func tapIklan() {
        if self.urlIklan.count > 0 {
            if self.urlIklan[iklan.currentPage] != "" {
                UIApplication.shared.open(URL(string: self.urlIklan[iklan.currentPage])!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func tapPromo() {
        if self.urlPromo.count > 0 {
            if self.urlPromo[promo.currentPage] != "" {
                UIApplication.shared.open(URL(string: self.urlPromo[promo.currentPage])!, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        roundButton.layer.cornerRadius = roundButton.layer.frame.size.width/2
        roundButton.backgroundColor = UIColor.clear
        roundButton.clipsToBounds = true
        roundButton.setImage(UIImage(named:"profile.png"), for: .normal)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roundButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            roundButton.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 125),
            roundButton.widthAnchor.constraint(equalToConstant: 65),
            roundButton.heightAnchor.constraint(equalToConstant: 65)])
    }
    
    /** Action Handler for button **/
    
    @IBAction func ButtonClick(_ sender: UIButton){
        
        /** Do whatever you wanna do on button click**/
        let profilePage = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! Profile
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.pushViewController(profilePage, animated: true)
        
    }
}
