//
//  VoucherCell.swift
//  Semargres
//
//  Created by NGI-1 on 3/16/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

class VoucherCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var voucherTableHeight: NSLayoutConstraint!
    @IBOutlet weak var listVoucher: UITableView!
    var data:[Dictionary<String, Any>]!
    var row: CGFloat!
    var height: CGFloat! = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTable()
    }
    
    func setupTable(){
        listVoucher.delegate = self
        listVoucher.dataSource = self
        
        listVoucher.isScrollEnabled = false
        listVoucher.separatorStyle = .none
        listVoucher.bounces = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setHeight()
//        print("zuu \(String(describing: data?.count))")
        return (data?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListVoucherCell", for: indexPath) as! ListVoucherCell
        
        cell.selectionStyle = .none
        
        cell.teks.text = (data?[indexPath.row]["title"] as? String)?.uppercased()
        cell.dec.text = data?[indexPath.row]["keterangan"] as? String
        
        let imageString = data[indexPath.row]["gambar"] as! String
        let imageUrl = URL(string: imageString)
        let imageData = NSData(contentsOf: imageUrl!)
        cell.pics.image = UIImage(data: imageData! as Data)
        
        cell.viewCell.backgroundColor = UIColor.init(red: 200/255, green: 23/255, blue: 20/255, alpha: 1)
        cell.viewCell.layer.masksToBounds = false
        cell.viewCell.layer.cornerRadius = cell.viewCell.frame.height/10
        cell.viewCell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data[indexPath.row]["link"] as! String != "" {
            UIApplication.shared.open(URL(string: data[indexPath.row]["link"] as! String)!, options: [:], completionHandler: nil)
        }else{
            print(data?[indexPath.row]["link"] as! String)
        }
    }
    
    func setHeight(){
        self.listVoucher.rowHeight = row
        self.voucherTableHeight.constant = CGFloat.init(integerLiteral: data.count) * listVoucher.rowHeight
    }
    
}
