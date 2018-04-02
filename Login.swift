//
//  ViewController.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/9/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import CoreData
import FacebookLogin
import FacebookCore

class Login: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    var isReg = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let spinningActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         GIDSignIn.sharedInstance().uiDelegate = self
         GIDSignIn.sharedInstance().delegate = self
        
        if Reachability.isConnectedToNetwork(){
            
        }else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Peringatan", message: "Tidak dapat terhubung ke internet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginFb(_ sender: UIButton) {
        let loginManager =  LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: {LoginResult -> Void in
            switch LoginResult{
            case .success( _, _, _):
            
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.authenticationToken)
                Auth.auth().signIn(with: credential) { (data, error2) in
                    if error2 != nil {
                        let alert = UIAlertController(title: "Kesalahan", message: "Email anda sudah digunakan. Gunakan email yang lain", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in
                            loginManager.logOut()
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.getFBUserData(data!.uid)
                    }
                }
            case .cancelled:
                loginManager.logOut()
            case .failed(let error):
                print(error)
            }
        })
    }
    
    func getFBUserData(_ uid:String){
        if(AccessToken.current != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large), email"]).start({(response, result) -> Void in
                switch result{
                case .failed(let error):
                    print(error)
                case .success(let rs):
                    if let resultDict = rs.dictionaryValue{
                        let pic = resultDict["picture"] as! Dictionary<String,Any>
                        let picData = pic["data"] as! Dictionary<String,Any>
                        let picUrl = picData["url"] as! String
                        
                        DispatchQueue.main.async {
                            let userData = ["profile_name" : resultDict["name"] as! String, "email" : resultDict["email"] as! String, "foto" : picUrl, "uid": uid] as [String : Any]
                            self.auth(userData, "FACEBOOK")
                        }
                    }
                }
            })
        }else{
            
        }
    }
    
    @IBAction func LoginGoogle(_ sender: UIButton) {
       GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (data, error2) in
                if error2 != nil {
                    print("telek = \(String(describing: error2))")
                    
                    let alert = UIAlertController(title: "Kesalahan", message: "Email anda sudah digunakan. Gunakan email yang lain", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in
                        GIDSignIn.sharedInstance().signOut()
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let userData = ["profile_name" : data!.displayName!, "email" : data!.email!, "foto" : data!.photoURL!, "uid": data!.uid] as [String : Any]
                    self.auth(userData, "GOOGLE")
                }
            }
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func register(_ userData: Dictionary<String,Any>,_ type:String){
        
        struct Send: Codable {
            let uid: String
            let email: String
            let profile_name: String
            let foto: String
            let type: String
            let fcm_id: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/register")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            uid: "\(userData["uid"]!)",
            email: "\(userData["email"]!)",
            profile_name: "\(userData["profile_name"]!)",
            foto: "\(userData["foto"]!)",
            type: type,
            fcm_id: ""
        )
        
        do{
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(params)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
            request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
        }catch{
            print(error)
        }
        
        Loader.shared.startLoader()
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
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Dictionary<String, Any>>
                    
                    print("telek = \(temp)")
                    if((temp["response"]!["status"]! as! Int) == 1){
                        let context = self.appDelegate.persistentContainer.viewContext
                        let db = NSEntityDescription.entity(forEntityName: "UserID", in: context)
                        let newData = NSManagedObject.init(entity: db!, insertInto: context)
                        
                        newData.setValue(userData["uid"], forKey: "id")
                        try! context.save()
                        
                        Loader.shared.stopLoader()
                        
                        self.isReg = true
                        self.auth(userData, type)
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func auth(_ userData: Dictionary<String,Any>,_ type:String){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let uid: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/auth")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            uid: "\(userData["uid"]!)"
        )
        
        do{
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(params)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("gmedia_semargress", forHTTPHeaderField: "Auth-Key")
            request.addValue("frontend-client", forHTTPHeaderField: "Client-Service")
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
                    let temp = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Dictionary<String, Any>>
                    print(temp)
                    
                    if((temp["response"]!["status"]! as! Int) == 0){
                        Loader.shared.stopLoader()
                        if type == "GOOGLE" {
                            GIDSignIn.sharedInstance().signOut()
                        }else{
                            let loginManager = LoginManager()
                                loginManager.logOut()
                        }
                        
                        let alert = UIAlertController(title: "Daftar Semargres", message: "Akun anda belum terdaftar. Daftarkan akun anda?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Daftar", style: .default, handler: {_ -> Void in
                                self.register(userData, type)
                        }))
                        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: {_ -> Void in
                            self.isReg = false
                        }))
                        
                        self.present(alert, animated: true, completion: nil)

                    }else{
                        //                    print(temp)
                        let alert = UIAlertController.init(title: "", message: temp["response"]!["message"]! as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: {action -> Void in
                            
                            
                            UserDefaults.standard.set("\(temp["response"]!["uid"]!)", forKey: "uid")
                            UserDefaults.standard.set("\(temp["response"]!["token"]!)", forKey: "token")
                            UserDefaults.standard.synchronize()
                            
                            if self.isReg {
                                let profilePage = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! Profile
                                self.present(profilePage, animated: true, completion: nil)
                            }else{
                                let tabBar = self.storyboard?.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                                self.present(tabBar, animated: true, completion: nil)
                            }
                        }))
                        
                        self.present(alert, animated: true, completion: Loader.shared.stopLoader)
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
}
    


