import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AllMapPage: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    fileprivate var myTableView: UITableView!
    
    var page_width_size : CGFloat!
    var page_height_size : CGFloat!
    
    var maps_arr : AnyObject?
    var reload_c = 0
    let condition = NSCondition()
    var json : AnyObject!
    var str_img2 : UIImageView?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.page_width_size = self.view.frame.size.width
        self.page_height_size = self.view.frame.size.height
        
        
        maps_arr = nil
        
        
        
        //ヘッダーエリア
        let header_area = UIView(frame : CGRect(x: 0, y: 0, width: page_width_size, height: 70))
        header_area.backgroundColor = UIColor(red:  1, green: 1 ,blue: 1, alpha:1)
        self.view.addSubview(header_area)
        
        
        //タイトル
        let header_title = UILabel(frame : CGRect( x: 50 , y: 20 , width: page_width_size-100, height: 50))
        header_title.text = "Travel List"
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
        
        back_btn2.addTarget(self, action: #selector(AllMapPage.onClick_back_btn(_:)), for: .touchUpInside)
        
        header_area.addSubview(back_btn_img2)
        header_area.addSubview(back_btn2)
        
        
        
        //戻るボタン
        let myImage2 = UIImage(named: "close-button")
        let back_btn_img = UIImageView(frame : CGRect(x: (self.page_width_size! - 30), y: 35 , width: 20, height: 20))
        let back_btn = UIButton(frame : CGRect(x: self.page_width_size! - 55, y: 15 , width: 55, height: 55))
        
        back_btn_img.image = myImage2
        //back_btn.backgroundColor = UIColor.redColor()
        
        back_btn.addTarget(self, action: #selector(AllMapPage.onClick_send_btn(_:)), for: .touchUpInside)
        
        header_area.addSubview(back_btn_img)
        header_area.addSubview(back_btn)
        
        
        
        
        
        let bar1 = UIView(frame : CGRect(x: 0,y: 69, width: self.view.frame.size.width, height: 1))
        
        bar1.backgroundColor = UIColor(red:242/255, green:242/255, blue:242/255, alpha: 1)
        
        header_area.addSubview(bar1)
        
        
        // TableViewの生成する(status barの高さ分ずらして表示).
        myTableView = UITableView(frame: CGRect(x: 0, y:70 , width: self.page_width_size!, height:self.page_height_size! - 70))
        // Cell名の登録をおこなう.
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // DataSourceの設定をする.
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorColor = UIColor.clear
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(maps_arr != nil){
            
            return maps_arr!.count
        }else{
            
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    
    /*
     Cellに値を設定するデータソースメソッド.
     (実装必須)
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyCell")
        
        cell.backgroundColor = UIColor.black
        
        
        let ansimg_area = UIView(frame: CGRect(x: 0,y: 0,width: self.page_width_size!,height: 120))
        ansimg_area.layer.opacity = 0.7
        
        let ansimg = UIImageView(frame: CGRect(x: 0,y: 0,width: self.page_width_size!,height: 120))
        
        var url2:URL?
        let tmp_user_str_img:String = "http://join.tokyo/join_app/user_img/miss_img.png"
        
        if( tmp_user_str_img.range(of: "Error") == nil){
            
            url2 = URL(string:"http://join.tokyo/join_app/user_img/miss_img.png")
            
        }else{
            url2 = URL(string:"http://join.tokyo/join_app/user_img/miss_img.png")
        }
        
        let req2 = URLRequest(url:url2!)
        
        var image : UIImage?
        NSURLConnection.sendAsynchronousRequest(req2, queue:OperationQueue.main){(res, data, err) in
            
            if data != nil {
                image = UIImage(data:data!)
            }else{
                image = UIImage(named: "a5")
            }
            
            image = UIImage(named: "a5")
            
            
            let img_ratio = image!.size.height/image!.size.width
            
            
            if(image?.size.width > image?.size.height){
                //横長
                NSLog("よこなが")
                ansimg.frame = CGRect(x: 0 , y: 60 - self.page_width_size/2 ,width: self.page_width_size/img_ratio,height: self.page_width_size)
            }else{
                //縦長
                NSLog("たてなが")
                ansimg.frame = CGRect(x: 0 , y: 0, width: self.page_width_size,height: self.page_width_size*img_ratio )
                
            }
            
            
            ansimg.image = image
            ansimg_area.layer.masksToBounds = true
            ansimg_area.addSubview(ansimg)
            cell.contentView.addSubview(ansimg_area)
        }
        
        
        let proposal_title = UILabel(frame: CGRect(x: 0,y: 0 ,width: self.view.frame.size.width,height: 120))
        proposal_title.text =  "San Francisco, California"
        proposal_title.font = UIFont.boldSystemFont(ofSize: 24)
        proposal_title.textAlignment = NSTextAlignment.center
        proposal_title.textColor = UIColor.white
        proposal_title.numberOfLines = 1
        proposal_title.layer.zPosition = 4
        ansimg_area.addSubview(proposal_title)
        
        
        
        let str_img = UIImageView(frame: CGRect(x: 17,y: 120 - 30,width: self.page_width_size! - 34 ,height: 20))
        str_img.image = UIImage(named :"download_g")
        str_img.layer.zPosition = 4
        str_img.layer.masksToBounds = true
        cell.contentView.addSubview(str_img)
        
        
        self.str_img2 = UIImageView(frame: CGRect(x: 0,y: 0,width: 0,height: 20))
        self.str_img2!.image = UIImage(named :"downloaded_g")
        self.str_img2!.layer.zPosition = 5
        str_img.addSubview(self.str_img2!)
        
        
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.str_img2!.frame.size.width = self.page_width_size! - 34
            
            }, completion: {(Bool) -> Void in
                
        })
        
        
        
        
        let bar1 = UIView(frame : CGRect(x: 0,y: 119, width: self.view.frame.size.width, height: 1))
        
        bar1.backgroundColor = UIColor(red:242/255, green:242/255, blue:242/255, alpha: 1)
        
        cell.contentView.addSubview(bar1)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            NSLog("ok")
            
            self.maps_arr = nil
            myTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
}
