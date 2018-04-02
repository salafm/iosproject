//
//  Profile.swift
//  Semargres
//
//  Created by NGI-1 on 3/24/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import CoreData
import GoogleSignIn
import FacebookLogin
import AAPickerView

class Profile: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scrollVIew: UIScrollView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var form: UITableView!
    
    var datePicker = UIDatePicker()
    var pickerView = UIPickerView()
    var toolbarPicker = UIToolbar()
    
    var array = ["No. KTP", "Nama Lengkap", "Tempat Lahir", "Tanggal Lahir", "Alamat", "Email", "Nomer Handphone", "Jenis Kelamin", "Agama", "Status Pernikahan", "Pekerjaan"]
    var arrField = ["no_ktp", "profile_name", "tempat_lahir", "tgl_lahir", "alamat", "email", "no_telp", "jenis_kelamin", "agama", "status_nikah", "pekerjaan"]
    let arr = ["jenis_kelamin", "agama", "marriage", "pekerjaan", "status_nikah"]
    
    var index = 0
    
    var post = Dictionary<String,String>()
    var postId = ["","","",""]
    var data = Dictionary<String, Any>()
    var master = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form.separatorStyle = .none
        form.allowsSelection = false
        form.isScrollEnabled = false
        
        self.title = "Edit Profile"
        let image = UIImage(named: "logout.png")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(signOut))
        
        self.get_profile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
//        picker
        pickerView.delegate = self
        pickerView.dataSource = self
        
        toolbarPicker.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancelDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbarPicker.setItems([doneButton,spaceButton,cancelButton], animated: false)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollVIew.contentInset = contentInsets
        scrollVIew.scrollIndicatorInsets = contentInsets
    }
    
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollVIew.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollVIew.contentInset = contentInset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return master.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return master[row][arr[index]] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = NSIndexPath(row: index+7, section: 0)
        let Cell = form.cellForRow(at: indexPath as IndexPath) as? ProfileCell
        
        Cell?.input.text = master[row][arr[index]] as? String
        Cell?.images.image = UIImage(named: "chek merah.png")
        postId[index] = (master[row]["id"] as? String)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var check: UIImage? = nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.backgroundColor = UIColor.init(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
        cell.line.backgroundColor = .red
        cell.input.borderStyle = .none
        cell.images.layer.cornerRadius = cell.images.frame.size.height/7
        
        if data[arrField[indexPath.row]] != nil{
            cell.input.text = data[arrField[indexPath.row]] as? String
            if cell.input.text != ""{
                check = UIImage(named: "chek merah.png")!
            }else{
                check = UIImage(named: "chek grey.png")!
            }
        }else{
            cell.input.placeholder = array[indexPath.row]
        }
        
        switch indexPath.row {
        case 0:
            postId[0] = data["id_gender"] as? String ?? ""
        case 1:
            postId[1] = data["id_agama"] as? String ?? ""
        case 2:
            postId[2] = data["id_marriage"] as? String ?? ""
        case 3:
            postId[3] = data["id_pekerjaan"] as? String ?? ""
        default:
            break
        }
        
        cell.images.image = check
        
        cell.input.restorationIdentifier = "\(indexPath.row)"
        cell.images.restorationIdentifier = "image\(indexPath.row)"
        
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        
        if arrField[indexPath.row] == "tgl_lahir" {
            cell.input.inputAccessoryView = toolbar
            cell.input.inputView = datePicker
        }else if arrField[indexPath.row] == "email" {
            cell.input.isUserInteractionEnabled = false
        }else if arr.contains(arrField[indexPath.row])   {
            pickerView.reloadAllComponents()
            cell.input.inputAccessoryView = toolbarPicker
            cell.input.inputView = pickerView
        }
        
        height.constant = cell.frame.size.height * CGFloat(array.count)
        
        return cell
    }
    
    @objc func donedatePicker(){
        let indexPath = NSIndexPath(row: 3, section: 0)
        let Cell = form.cellForRow(at: indexPath as IndexPath) as? ProfileCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        Cell?.input.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func signOut(){
        let loginManager = LoginManager()
        
        let alert = UIAlertController(title: "Peringatan", message: "Apakah anda yakin ingin keluar?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keluar", style: .destructive, handler: {_ -> Void in
            try! Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
            loginManager.logOut()
            
            self.showAlert()
        }))
        
        alert.addAction(UIAlertAction(title: "Batalkan", style: .cancel , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Berhasil", message: "Anda berhasil keluar dari akun anda", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ -> Void in
            self.deleteAllData(entity: "UserID")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "login") as! Login
            self.present(vc, animated: false, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAllData(entity: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func get_profile(){
        Loader.shared.startLoader()
        
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/profile/view"
        
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
//                    print(temp)
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.data = temp["response"]! as! Dictionary<String, Any>
//                        print(self.data)
                        
                        self.form.reloadData()
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
    
    func saveProfil(_ userData: Dictionary<String,String>){
        Loader.shared.startLoader()
        
        struct Send: Codable {
            let email: String
            let profile_name: String
            let tgl_lahir: String
            let tempat_lahir: String
            let no_telp: String
            let no_ktp: String
            let alamat: String
            let jenis_kelamin: String
            let agama: String
            let status_nikah: String
            let pekerjaan: String
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://semargres.gmedia.bz/profile/edit")! as URL)
        request.httpMethod = "POST"
        
        let params = Send(
            email: "\(userData["email"]!)",
            profile_name: "\(userData["profile_name"]!)",
            tgl_lahir: "\(userData["tgl_lahir"]!)",
            tempat_lahir: "\(userData["tempat_lahir"]!)",
            no_telp: "\(userData["no_telp"]!)",
            no_ktp: "\(userData["no_ktp"]!)",
            alamat: "\(userData["alamat"]!)",
            jenis_kelamin: "\(userData["jenis_kelamin"]!)",
            agama: "\(userData["agama"]!)",
            status_nikah: "\(userData["status_nikah"]!)",
            pekerjaan: "\(userData["pekerjaan"]!)"
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
                    //                    print(temp)
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.showAlertSave("Berhasil menyimpan data")
                    }else{
                        self.showAlertSave("Gagal menyimpan data")
                        print("kosong")
                    }
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func getMaster(_ master: String){
        // url get
        let scriptUrl = "http://semargres.gmedia.bz/\(master)"
        
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
//                    print(temp)
                    let metadata = temp["metadata"] as! Dictionary<String, Any>
                    if((metadata["status"] as! Int) == 200){
                        self.master = temp["response"]! as! [Dictionary<String, Any>]
                        self.pickerView.reloadAllComponents()

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
    
    @IBAction func save(_ sender: UIButton) {
        for index in 0...arrField.count-1 {
            let indexPath = NSIndexPath(row: index, section: 0)
            let Cell = form.cellForRow(at: indexPath as IndexPath) as? ProfileCell
            // we cast here so that you can access your custom property.
            if index > 6 {
                post[arrField[index]] = postId[index-7]
            }else{
                post[arrField[index]] = Cell?.input.text!
            }
        }
        
        let alert = UIAlertController(title: "Simpan Data", message: "Anda yakin ingin mengubah profil?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Simpan", style: .default, handler: {_ -> Void in
            self.saveProfil(self.post)
        }))
        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: Loader.shared.stopLoader)
    }
    
    func showAlertSave(_ message: String){
        let alert = UIAlertController(title: "Berhasil", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ -> Void in
            let tabBar = self.storyboard?.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            self.present(tabBar, animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: Loader.shared.stopLoader)
    }
    
    
    @IBAction func edited(_ sender: UITextField) {
        let indexPath = NSIndexPath(row: Int(sender.restorationIdentifier!)!, section: 0)
        let Cell = form.cellForRow(at: indexPath as IndexPath) as? ProfileCell
        if sender.text == "" {
            Cell?.images.image = UIImage(named: "chek grey.png")
        }else{
             Cell?.images.image = UIImage(named: "chek merah.png")
        }
    }
    
    @IBAction func initPicker(_ sender: UITextField) {
        switch Int(sender.restorationIdentifier!)! {
        case 7:
            self.index = 0
            getMaster("gender")
        case 8:
            self.index = 1
            getMaster("agama")
        case 9:
            self.index = 2
            getMaster("marriage")
        case 10:
            self.index = 3
            getMaster("pekerjaan")
        default:
            break
        }
    }
}
