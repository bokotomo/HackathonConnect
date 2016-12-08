
//
//  Filter.swift
//  connect
//
//  Created by Ryuya Tosaka on 2016/05/22.
//  Copyright © 2016年 negimiso. All rights reserved.
//

import UIKit

class Filter: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var page_width_size : CGFloat!
    var page_height_size : CGFloat!
    
    // Tableで使用する配列を設定する
    fileprivate let myItems: NSArray = ["Wi-Fi Spot", "Shop", "TEST3"]
    fileprivate var myTableView: UITableView!
    
    fileprivate var myLabel: UILabel!
    
    var maps_arr : AnyObject?
    var reload_c = 0
    let condition = NSCondition()
    var json : AnyObject!
    var str_img2 : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.page_width_size = self.view.frame.size.width
        self.page_height_size = self.view.frame.size.height
        
        //ヘッダーエリア
        let header_area = UIView(frame : CGRect(x: 0, y: 0, width: page_width_size, height: 70))
        header_area.backgroundColor = UIColor(red:  1, green: 1 ,blue: 1, alpha:1)
        self.view.addSubview(header_area)
        
        //タイトル
        let header_title = UILabel(frame : CGRect( x: 50 , y: 20 , width: page_width_size-100, height: 50))
        header_title.text = "Filter"
        header_title.textAlignment = NSTextAlignment.center
        header_title.textColor = UIColor(red:  0.1, green: 0.1, blue:  0.1, alpha: 1)
        header_title.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        header_area.addSubview(header_title)
        
        
        //戻るボタン
        let myImage3 = UIImage(named: "delete")
        let back_btn_img2 = UIImageView(frame : CGRect(x: 10, y: 35 , width: 20, height: 20))
        let back_btn2 = UIButton(frame : CGRect(x: 0, y: 15 , width: 55, height: 55))
        
        back_btn_img2.image = myImage3
        //back_btn.backgroundColor = UIColor.redColor()
        
        back_btn2.addTarget(self, action: #selector(Filter.onClick_back_btn(_:)), for: .touchUpInside)
        
        header_area.addSubview(back_btn_img2)
        header_area.addSubview(back_btn2)
        
        
        let bar1 = UIView(frame : CGRect(x: 0,y: 69, width: self.view.frame.size.width, height: 1))
        bar1.backgroundColor = UIColor(red:242/255, green:242/255, blue:242/255, alpha: 1)
        header_area.addSubview(bar1)


        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // TableViewの生成する(status barの高さ分ずらして表示).
        myTableView = UITableView(frame: CGRect(x: 0, y:70 , width: self.page_width_size!, height:self.page_height_size! - 70))
        // Cell名の登録をおこなう.
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // DataSourceの設定をする.
        myTableView.dataSource = self
        // Delegateを設定する.
        myTableView.delegate = self
        // Viewに追加する.
        self.view.addSubview(myTableView)
        
        
        // Swicthを作成する.
        let mySwicth: UISwitch = UISwitch()
        mySwicth.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 200)
        // Swicthの枠線を表示する.
        mySwicth.tintColor = UIColor.black
        // SwitchをOnに設定する.
        mySwicth.isOn = true
        // SwitchのOn/Off切り替わりの際に、呼ばれるイベントを設定する.
        mySwicth.addTarget(self, action: #selector(Filter.onClickMySwicth(_:)), for: UIControlEvents.valueChanged)
        // SwitchをViewに追加する.
        myTableView.addSubview(mySwicth)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     Cellが選択された際に呼び出されるデリゲートメソッド.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myItems[indexPath.row])")
    }
    
    /*
     Cellの総数を返すデータソースメソッド.
     (実装必須)
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
     Cellに値を設定するデータソースメソッド.
     (実装必須)
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        cell.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100)
        // Cellに値を設定する.
        cell.textLabel!.text = "\(myItems[indexPath.row])"

        
        
        return cell
    }
    
    func onClick_back_btn(_ sender: UIButton){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func onClick_send_btn(_ sender: UIButton){
        
        reload_c = 0
        let myUrl = URL(string: "http://codeserver.xsrv.jp/angelhackapp/get_user_map.php")
        let request = NSMutableURLRequest(url:myUrl!);
        
        request.httpMethod = "POST"
        let postString = "user_id=tomo";
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            
            data, response, error in
            let anyObj: AnyObject!
            
            do {
                if(data != nil){
                    
                    anyObj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    
                }else{
                    
                    anyObj = nil
                }
                
            } catch _ as NSError {
                anyObj = nil
            }
            
            if(anyObj == nil){
                
                self.json = nil
                
                self.maps_arr = nil
                
            }else{
                
                self.json = anyObj!
                
                self.maps_arr = self.json[0]["users"]!
                NSLog("\(self.json!)だよ！")
                //NSLog("\(self.groups_arr!)")
                
            }
            self.condition.signal()
            self.condition.unlock()
        }) 
        
        
        
        self.condition.lock()
        task.resume()
        self.condition.wait()
        self.condition.unlock()
        
        
        if( self.maps_arr == nil){
            reload_c += 1
            NSLog("reloadreloadreloadreloadreloadreload!!!!!!!!!!!!!!!!!!\(reload_c)")
            
            if(reload_c < 10){
                loadView()
                viewDidLoad()
            }
            
        }
        
        if(reload_c < 10){
            
            self.maps_arr = ["a"]
            myTableView.reloadData()
            
            
        }else{
            
            
            
            
        }
    }
    
    
    internal func onClickMySwicth(_ sender: UISwitch){
        
        if sender.isOn {
            myLabel.text = "On"
            myLabel.backgroundColor = UIColor.orange
        }
        else {
            myLabel.text = "Off"
            myLabel.backgroundColor = UIColor.gray
        }
    }

    
}

