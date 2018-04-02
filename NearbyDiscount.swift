//
//  NearbyDiscount.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/13/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class NearbyDiscount: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    var nearbyMerchant = Array<Dictionary<String, Any>>()
    
    let heightRatio = UIScreen.main.bounds.height / 736
    let widthRatio = UIScreen.main.bounds.width / 414
    
    var cellHeight: CGFloat?
    var topLabel: CGFloat?
    var picWidth: CGFloat?
    
    var count: Int = 0
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var listNearby: UITableView!
    @IBOutlet weak var heightCons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listNearby.separatorStyle = UITableViewCellSeparatorStyle.none
        self.listNearby.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        self.listNearby.isScrollEnabled = false
        
        //        self.scroll.bounces = false
        self.scroll.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        
        let cell = listNearby.dequeueReusableCell(withIdentifier: "NearbyCell") as! NearbyCell
        self.cellHeight = cell.cellHeight.constant
        self.topLabel = cell.topLabel.constant
        self.picWidth = cell.picWidth.constant
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         self.navigationController?.navigationBar.isTranslucent = false
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            openalert()
        }else {
            count = 8
            currentLocation = locationManager.location
            self.get_nearbyMer("\(currentLocation.coordinate.latitude)", "\(currentLocation.coordinate.longitude)", count)
        }
    }
    
    func openalert(){
        let alert = UIAlertController(title: "Location Service Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Pengaturan", style: .default, handler: { _ -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyMerchant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listNearby.dequeueReusableCell(withIdentifier: "NearbyCell") as! NearbyCell
        cell.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        cell.selectionStyle = .none
        
        cell.frameList.layer.borderColor = UIColor.white.cgColor
        cell.frameList.layer.masksToBounds = false
        cell.frameList.layer.cornerRadius = cell.frameList.frame.height/10
        cell.frameList.clipsToBounds = true

        let imageString = nearbyMerchant[indexPath.row]["foto"] as! String
        let imageUrl = URL(string: imageString)
        let imageData = NSData(contentsOf: imageUrl!)
        cell.pic.image = UIImage(data: imageData! as Data)

        cell.name.text = nearbyMerchant[indexPath.row]["nama"] as? String


        heightCons.constant = CGFloat.init(integerLiteral: nearbyMerchant.count) * cell.frame.size.height + 10


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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let merchantDetail = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailMerchant
        merchantDetail.id = nearbyMerchant[indexPath.row]["id_m"] as? String
        self.navigationController?.pushViewController(merchantDetail, animated: true)
    }
    
    func get_nearbyMer(_ lat: String, _ long: String, _ jml: Int){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let jarak: String
            let latitude: String
            let longitude: String
            let start: String
            let count: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/merchant/nearby")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            jarak: "2",
            latitude: lat,
            longitude: long,
            start: "0",
            count: "\(jml)"
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
//                                            let response = temp["response"]! as! Array<Dictionary<String, Any>>
//                                            print(response)
                        self.nearbyMerchant = temp["response"]! as! Array<Dictionary<String, Any>>
                        
                        self.listNearby.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        self.nearbyMerchant = []
                        Loader.shared.stopLoader()
                        self.setupView()
//                        self.showAlert()
                    }
                }catch{
                    print(error)
                }
                
            }
        }
        task.resume()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            count += 5
            self.get_nearbyMer("\(currentLocation.coordinate.latitude)", "\(currentLocation.coordinate.longitude)", count)
        }
    }
    
    private func setupView() {
        let greenView = UIImageView(image: UIImage(named: "no_merchant.png"))
        
        greenView.contentMode = .scaleAspectFit
        greenView.translatesAutoresizingMaskIntoConstraints = false
        greenView.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        view.addSubview(greenView)
        
        greenView.heightAnchor.constraint(equalTo: greenView.superview!.heightAnchor).isActive = true
        greenView.widthAnchor.constraint(equalTo: greenView.superview!.widthAnchor).isActive = true
        greenView.centerXAnchor.constraint(equalTo: greenView.superview!.centerXAnchor).isActive = true
        greenView.centerYAnchor.constraint(equalTo: greenView.superview!.centerYAnchor).isActive = true
    }
    
}
