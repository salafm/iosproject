//
//  AppDelegate.swift
//  Smargres 2018
//
//  Created by NGI-1 on 3/9/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import Firebase
import GoogleMaps
import GooglePlaces
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    
    var data: [UserID] = []
    var window: UIWindow?
    
    let req = NSFetchRequest<NSFetchRequestResult>(entityName: "UserID")
    let mainSB = UIStoryboard(name: "Main", bundle: nil)
    
    let locationManager = CLLocationManager()
    
    var url = ""
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("success")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "21661230507-9ona36572v3fccgg88ic19o62lo1a6kn.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()

        let context = persistentContainer.viewContext
        self.getUserID(context)
        
        if(data.count > 0){
            self.auth(data[0].id!)
        }else{
            self.loginPage()
        }
                
        let backArrowImage = UIImage(named: "back_copy")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        
        GMSServices.provideAPIKey("AIzaSyBcJvGGJMJUxR2-Gc2d-dB2co8v10drRAI")
        GMSPlacesClient.provideAPIKey("AIzaSyBcJvGGJMJUxR2-Gc2d-dB2co8v10drRAI")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UINavigationBar.appearance().barTintColor = UIColor.init(red: 200/255, green: 23/255, blue: 20/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        return true
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        let d : [String : Any] = remoteMessage.appData["notification"] as! [String : Any]
        let body : String = d["body"] as! String
        print("testing = \(body)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
//        print("Handle push from background or closed resp\(response.notification.request.content.userInfo)")
        let notif = response.notification.request.content.userInfo as! Dictionary<String, Any>
//        print("notif data = \(notif)")
        
        if Int(notif["jenis"] as! String) == 2 {
            self.detailPromo(notif["id_promo"] as! String)
            completionHandler()
        }else{
            self.VoucherPage()
            completionHandler()
        }
    }
    
    func detailPromo(_ idPromo : String){
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/promo/\(idPromo)"
        
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
//                                        print(temp)
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        let response = temp["response"]! as! [Dictionary<String, Any>]
                        
                        self.url = response[0]["link"] as! String
                        
                        let imageString = response[0]["gambar"] as! String
                        let imageUrl = URL(string: imageString)
                        let imageData = NSData(contentsOf: imageUrl!)
                        
                        let alert = CustomAlert(title: "\(String(describing: response[0]["title"]!))", image: UIImage(data: imageData! as Data)!)
                        
                        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapGambar))
                        alert.isUserInteractionEnabled = true
                        alert.addGestureRecognizer(singleTap)
                        
                        alert.show(animated: true)
                        
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
    
    @objc func tapGambar(){
//        print("gambarr buka link nyaaaaa")
        
        if self.url != "" {
            UIApplication.shared.open(URL(string: self.url)!, options: [:], completionHandler: nil)
        }
    }
    
    func VoucherPage(){
        let tabBar = self.mainSB.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        tabBar.selectedIndex = 2
        
        self.window?.rootViewController = tabBar
        self.window?.makeKeyAndVisible()
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
//        print("Handle push from background or closed userinfo \(userInfo)")
//        completionHandler(.newData)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        print("Handle push from background or closed userinfo2 \(userInfo)")
//    }
//
//    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
//        print("identifier = \(String(describing: identifier))")
//    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse{
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined{
                self.openalert()
            }
        }
        
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            print("Notification settings: \(settings)")
//
//            if settings.authorizationStatus != UNAuthorizationStatus.authorized {
//                self.openalertnotif()
//            }
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Semargres")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getUserID(_ context: NSManagedObjectContext){
        req.returnsObjectsAsFaults = false
        let sortById = NSSortDescriptor(key: "id", ascending: true)
        req.sortDescriptors = [sortById]
        do{
            let result = try context.fetch(req)
            data = result as! [UserID]
        }catch{
            print(Error.self)
        }
    }
    
    func loginPage(){
        let page = mainSB.instantiateViewController(withIdentifier: "login") as! Login
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = page
        self.window?.makeKeyAndVisible()
    }
    
    func auth(_ userData: String){
        let token1 = Messaging.messaging().fcmToken
        
        struct Send: Codable {
            let uid: String
            let fcm_id:String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/auth")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            uid: "\(userData)",
            fcm_id: "\(token1 ?? "")"
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
                    if((temp["response"]!["status"]! as! Int) == 0){
//                        print(temp)
                        self.loginPage()
                    }else{
                        print(temp)
                        
                        let tabBar = self.mainSB.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                        //                    let tabView = tabBar.viewControllers
                        //                    let navView = tabView![0] as! UINavigationController
                        //                    let home = navView.viewControllers.first as! Home
                        //                    home.uid = temp["response"]!["uid"]! as? String
                        //                    home.token = temp["response"]!["token"]! as? String
                        
                        UserDefaults.standard.set(temp["response"]!["uid"]!, forKey: "uid")
                        UserDefaults.standard.set(temp["response"]!["token"]!, forKey: "token")
                        UserDefaults.standard.synchronize()
                        
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = tabBar
                        self.window?.makeKeyAndVisible()
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func openalert(){
        let alert = UIAlertController(title: "Location Service Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { _ -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func openalertnotif(){
        let alert = UIAlertController(title: "Notification disabled", message: "To re-enable, please go to Settings and turn on Notification for this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { _ -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            openalert()
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}

