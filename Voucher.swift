//
//  Voucher.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/13/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

class Voucher: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var Kupon: UICollectionView!
    var voucher = [Dictionary<String,Any>]()
//    private let greenView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Kupon.isScrollEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         self.navigationController?.navigationBar.isTranslucent = false
        
        get_kupon()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voucher.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KuponCell", for: indexPath) as! KuponCell
        
        cell.nomor.text = "No. \(voucher[indexPath.row]["nomor"] as! String)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! KuponHeader
        
        view.line.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        view.totalTIket.text = "Total kuponku : \(voucher.count)"
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 50
        let collectionViewSize = collectionView.frame.size.width - padding
        
        
        return CGSize(width: collectionViewSize/2, height: 11*collectionViewSize/20)
    }
    
    func get_kupon(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/kupon/history"
        
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
                        self.voucher = temp["response"]! as! Array<Dictionary<String, Any>>
//                        print("zukun \(self.voucher)")
                        
                        self.Kupon.isHidden = false
                        self.Kupon.reloadData()
                        
                        Loader.shared.stopLoader()
                    }else{
                        print("kosong")
                        
                        self.Kupon.isHidden = true
                        self.setupView()
                        Loader.shared.stopLoader()
                    }
                    
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    private func setupView() {
        let greenView = UIImageView(image: UIImage(named: "no_kupon.png"))
        
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
