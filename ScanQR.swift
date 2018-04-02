//
//  ScanQR.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/13/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

class ScanQR: UIViewController  {
    @IBOutlet weak var qrcode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.get_QRcode()
    }
    
    func get_QRcode(){
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/qrcode"
        
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
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Dictionary<String, Any>>
                    //                self.array = temp["response"] as? Array<Dictionary<String, AnyObject>>
                    
                    let imageString = temp["response"]!["url"]! as! String
                    let imageUrl = URL(string: imageString)
                    let imageData = NSData(contentsOf: imageUrl!)
                    self.qrcode.image = UIImage(data: imageData! as Data)
                    
                    self.qrcode.layer.borderWidth = 10
                    self.qrcode.layer.borderColor = UIColor.white.cgColor
                    self.qrcode.layer.masksToBounds = false
                    self.qrcode.layer.cornerRadius = self.qrcode.frame.height/13
                    self.qrcode.clipsToBounds = true
                }catch{
                    print(error)
                }
//
            }
        }
        task.resume()
    }
}
