//
//  DetailMerchant.swift
//  Semargres
//
//  Created by NGI-1 on 3/16/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class DetailMerchant: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var detailMerchant: UITableView!
    @IBOutlet weak var HeightCons: NSLayoutConstraint!
    @IBOutlet weak var pic: UIImageView!
    var id:String?
    var arrayDetail: Array<Dictionary<String, Any>> = []
    var arrayPromo = Array<Dictionary<String, Any>>()
    var row = 200
    
    let heightRatio = UIScreen.main.bounds.height / 736
    let widthRatio = UIScreen.main.bounds.width / 414
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailMerchant.isScrollEnabled = false
        self.detailMerchant.bounces = false
        self.detailMerchant.allowsSelection = false
        
        self.get_mdetail(id!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDetail.count*3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Loader.shared.startLoader()
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as! NameCell
            cell.name.text = "\(self.arrayDetail[0]["nama"]!)"
            
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescCell", for: indexPath) as! DescCell
            cell.Desc.text = "\(self.arrayDetail[0]["deskripsi"]!)"
            cell.location.text = "\(self.arrayDetail[0]["alamat"]!)"
            cell.telp.text = "\(self.arrayDetail[0]["notelp"]!)"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath) as! VoucherCell
    
            cell.data = arrayPromo
            if UIScreen.main.bounds.height == 812.0 {
                cell.row = CGFloat(row)
                HeightCons.constant = CGFloat(arrayPromo.count * row) + 240
            }else{
                cell.row = CGFloat(row) * heightRatio
                HeightCons.constant = (CGFloat(arrayPromo.count * row) * heightRatio) + 240
            }
//            print("zuuuuu \(arrayPromo)")
            
            Loader.shared.stopLoader()
            return cell
        }
    }
    
    func get_mdetail(_ id:String){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/merchant/all/\(id)"
        
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
                        let response = temp["response"]! as! Array<Dictionary<String, Any>>
                        self.arrayDetail = temp["response"]! as! Array<Dictionary<String, Any>>
                        self.arrayPromo = self.arrayDetail[0]["promo"] as! Array<Dictionary<String, Any>>
                        print(self.arrayDetail)
                        
                        let imageString = response[0]["foto"] as! String
                        let imageUrl = URL(string: imageString)
                        let imageData = NSData(contentsOf: imageUrl!)
                        self.pic.image = UIImage(data: imageData! as Data)
                        
                        self.detailMerchant.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        Loader.shared.stopLoader()
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }

    @IBAction func getMap(_ sender: UIButton) {
        let page = self.storyboard?.instantiateViewController(withIdentifier: "Maps") as! Maps
        page.lat = (arrayDetail[0]["latitude"] as! NSString).doubleValue
        page.long = (arrayDetail[0]["longitude"] as! NSString).doubleValue
        page.nama = arrayDetail[0]["nama"] as! String
        page.alamat = arrayDetail[0]["alamat"] as! String
        
        self.navigationController?.pushViewController(page, animated: true)
        
    }
    
    @IBAction func doShare(_ sender: UIButton) {
        // text to share
        let text = "http://semaranggreatsale.com/"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
