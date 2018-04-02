//
//  CategoryList.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/13/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow

class CategoryList: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var iklanSlide: ImageSlideshow!
    @IBOutlet weak var list: UITableView!
    @IBOutlet weak var heightCons: NSLayoutConstraint!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var list2: UITableView!
    @IBOutlet weak var heightCons2: NSLayoutConstraint!
    
    var listMerchant: Array<Dictionary<String, Any>> = []
    
    var id:String?
    
    var cellHeight: CGFloat?
    var topLabel: CGFloat?
    var picWidth: CGFloat?
    
    var arrayIklan: Array<Dictionary<String, Any>>! = []
    var urlIklan = [String]()
    var gambarIklan = [AlamofireSource]()
    
    let heightRatio = UIScreen.main.bounds.height / 736
    let widthRatio = UIScreen.main.bounds.width / 414
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.list.separatorStyle = UITableViewCellSeparatorStyle.none
        self.list.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        self.list.isScrollEnabled = false
        
        self.list2.separatorStyle = UITableViewCellSeparatorStyle.none
        self.list2.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        self.list2.isScrollEnabled = false
        
//        self.scroll.bounces = false
        self.scroll.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        
        let cell = list.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        self.cellHeight = cell.cellHeight.constant
        self.topLabel = cell.topLabel.constant
        self.picWidth = cell.picWidth.constant
        
        self.get_iklan(id!)
        self.get_merchant(id!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
//        self.navigationController?.view.backgroundColor = UIColor.red
//        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listMerchant.count > 0 {
            if tableView == list {
                if listMerchant.count > 3 {
                    return 3
                }else{
                    return listMerchant.count
                }
            }else{
                return listMerchant.count - 3
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == list {
            let cell:TableCell = list.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
            cell.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            cell.selectionStyle = .none
            
            cell.frameList.layer.borderColor = UIColor.white.cgColor
            cell.frameList.layer.masksToBounds = false
            cell.frameList.layer.cornerRadius = cell.frameList.frame.height/10
            cell.frameList.clipsToBounds = true
            
            let imageString = listMerchant[indexPath.row]["foto"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            cell.pic.image = UIImage(data: imageData! as Data)
            
            cell.name.text = listMerchant[indexPath.row]["nama"] as? String
            
            if listMerchant.count > 3 {
                heightCons.constant = CGFloat.init(integerLiteral: 3) * cell.frame.size.height + 10
            }else{
                heightCons.constant = CGFloat.init(integerLiteral: listMerchant.count) * cell.frame.size.height + 10
            }
            
            
            if UIScreen.main.bounds.height == 812.0 {
                cell.cellHeight.constant = cellHeight!
                cell.topLabel.constant = topLabel!
                cell.picWidth.constant = picWidth!
            }else{
                cell.cellHeight.constant = cellHeight! * heightRatio
                cell.topLabel.constant = topLabel! * heightRatio
                cell.picWidth.constant = picWidth! * widthRatio
            }

            return cell
        }else{
            let cell2: TableCell2 = list2.dequeueReusableCell(withIdentifier: "TableCell2") as! TableCell2
            cell2.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            cell2.selectionStyle = .none
            
            cell2.frameList2.layer.borderColor = UIColor.white.cgColor
            cell2.frameList2.layer.masksToBounds = false
            cell2.frameList2.layer.cornerRadius = cell2.frameList2.frame.height/10
            cell2.frameList2.clipsToBounds = true
            
            let imageString = listMerchant[indexPath.row + 3]["foto"] as! String
            let imageUrl = URL(string: imageString)
            let imageData = NSData(contentsOf: imageUrl!)
            cell2.pic2.image = UIImage(data: imageData! as Data)
            
            cell2.name2.text = listMerchant[indexPath.row + 3]["nama"] as? String
            
            heightCons2.constant = CGFloat.init(integerLiteral: listMerchant.count - 3) * cell2.frame.size.height + 10
            
            if UIScreen.main.bounds.height == 812.0 {
                cell2.cellHeight2.constant = cellHeight!
                cell2.topLabel2.constant = topLabel!
                cell2.picWidth2.constant = picWidth!
            }else{
                cell2.cellHeight2.constant = cellHeight! * heightRatio
                cell2.topLabel2.constant = topLabel! * heightRatio
                cell2.picWidth2.constant = picWidth! * widthRatio
            }
            
            return cell2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let merchantDetail = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailMerchant
        
        if tableView == list {
            merchantDetail.id = listMerchant[indexPath.row]["id_m"] as? String
        }else{
            merchantDetail.id = listMerchant[indexPath.row + 3]["id_m"] as? String
        }

        self.navigationController?.pushViewController(merchantDetail, animated: true)
    }
    
    func get_merchant(_ id: String){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let id_kat: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/merchant/kategori")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            id_kat: "\(id)"
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
                        //                    let response = temp["response"]! as! Array<Dictionary<String, Any>>
                        //                    print(response)
                        self.listMerchant = (temp["response"]! as? Array<Dictionary<String, Any>>)!
                        
                        self.list.reloadData()
                        self.list2.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        self.showAlert()
                    }
                }catch{
                    print(error)
                }

            }
        }
        task.resume()
    }
    
    func get_iklan(_ id:String){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/iklan/\(id)"
        
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
//                        print("zukun \(self.arrayIklan)")
                        
                        self.initPromoCell()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        self.iklanSlide.isHidden = true
                        Loader.shared.stopLoader()
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
            if self.urlIklan[iklanSlide.currentPage] != "" {
                UIApplication.shared.open(URL(string: self.urlIklan[iklanSlide.currentPage])!, options: [:], completionHandler: nil)
            }
        }
    }
    func initPromoCell(){
        if arrayIklan.count > 0 {
            for index in 0...arrayIklan.count-1 {
                gambarIklan.insert(AlamofireSource(urlString: arrayIklan[index]["icon"] as! String)!, at: index)
                urlIklan.insert(arrayIklan[index]["link"] as! String, at: index)
                //                    print(arrayIklan[index])
            }
            
            iklanSlide.slideshowInterval = 10.0
            iklanSlide.pageControlPosition = .hidden
            iklanSlide.contentScaleMode = UIViewContentMode.scaleAspectFit
            iklanSlide.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            
            let iklanTap = UITapGestureRecognizer(target: self, action: #selector(self.tapIklan))
            iklanSlide.addGestureRecognizer(iklanTap)
            
            iklanSlide.setImageInputs(gambarIklan)
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Semargres", message: "Tidak ada merchant untuk kategori ini", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ -> Void in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: Loader.shared.stopLoader)
    }
    
}
