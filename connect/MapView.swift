//
//  MapView.swift
//  connect
//
//  Created by Ryuya Tosaka on 2016/05/21.
//  Copyright © 2016年 negimiso. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapView: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate{
    
    var page_width_size:CGFloat?
    var page_height_size:CGFloat?
    var myButton: UIButton!
    var myButton2: UIButton!
    
    var items : AnyObject?
    var maps_arr : AnyObject?
    var reload_c = 0
    let condition = NSCondition()
    var json : AnyObject!
    
    var tagStore : Dictionary<NSString, NSString> = [:]
    
    var offlinePacks = [MGLOfflinePack]()
    
    var mapView:MGLMapView?
    
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page_width_size = self.view.bounds.size.width;
        _ = self.view.bounds.size.height;
        
        
        
        
        // Mapここから
        mapView = MGLMapView(frame: view.bounds)
        mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView!.showsUserLocation = true
        view.addSubview(mapView!)
        mapView!.delegate = self
        
        // フィールドの初期化
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        if #available(iOS 8.0, *) {
            lm.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        // 位置情報取得間隔を指定．指定した値（メートル）���動したら位置情報を更新する．任意．
        // lm.distanceFilter = 1000
        
        // GPSの使用を開始する
        lm.startUpdatingLocation()
        
        
        get_location_items()
        
        
        
        let myUrl = URL(string: "https://koka.tech/connect_test.php")
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
                    self.parseJSON(data!)
                    
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
                
                self.maps_arr = self.json!
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
            
    
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let header_area_height_size : CGFloat = 70.0

        //ヘッダーエリア
        let header_area = UIView(frame : CGRect(x: 0, y: 0, width: page_width_size , height: header_area_height_size))
        header_area.backgroundColor = UIColor.clear
        self.view.addSubview(header_area)
        
        // ボタンに画像を設定する
        let image1 = UIImage(named: "download_page_link")! as UIImage
        let imageButton1   = UIButton()
        imageButton1.frame = CGRect(x: self.view.frame.width/2 - 35, y: self.view.frame.size.height - 90, width: 70, height: 70)
        imageButton1.setImage(image1, for: UIControlState())
        imageButton1.addTarget(self, action: #selector(MapView.onClickMyButton(_:)), for:.touchUpInside)
        mapView!.addSubview(imageButton1)
            
        // ヘッダー左画像
        let image2 = UIImage(named: "Group_3")! as UIImage
        let imageButton2   = UIButton()
        imageButton2.frame = CGRect(x: 10, y: statusBarHeight + 10, width: 70, height: 70)
        imageButton2.setImage(image2, for: UIControlState())
        imageButton2.addTarget(self, action: #selector(MapView.onClickMyButton2(_:)), for:.touchUpInside)
        mapView!.addSubview(imageButton2)
            
            
        // ヘッダー右画像
        let image3 = UIImage(named: "Group_4")! as UIImage
        let imageButton3   = UIButton()
        imageButton3.frame = CGRect(x: self.view.frame.width - 70 - 10, y: statusBarHeight + 10, width: 70, height: 70)
        imageButton3.setImage(image3, for: UIControlState())
        imageButton3.addTarget(self, action: #selector(MapView.onClickMyButton(_:)), for:.touchUpInside)
        mapView!.addSubview(imageButton3)

            
        }else{
            
            
        }
        
        
        
    }
    
    func downloadOffline() {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView!.styleURL, bounds: mapView!.visibleCoordinateBounds, fromZoomLevel: mapView!.zoomLevel, toZoomLevel: mapView!.maximumZoomLevel)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        // Create and register an offline pack with the shared offline storage object.
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                print("The pack couldn’t be created for some reason.")
                return
            }
            //
            //            // Set the pack’s delegate (assuming self conforms to the MGLOfflinePackDelegate protocol).
            //            pack!.delegate = self
            //
            // Start downloading.
            pack!.resume()
            
            // Retain reference to pack to work around it being lost and not sending delegate messages
            self.offlinePacks.append(pack!)
        }
    }
    
    func offlinePack(_ pack: MGLOfflinePack, progressDidChange progress: MGLOfflinePackProgress) {
        let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as! [String: String]
        let completed = progress.countOfResourcesCompleted
        let expected = progress.countOfResourcesExpected
        print("Offline pack “\(userInfo["name"])” has downloaded \(completed) of \(expected) resources.")
    }
    
    func offlinePack(_ pack: MGLOfflinePack, didReceiveError error: NSError) {
        let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as! [String: String]
        print("Offline pack “\(userInfo["name"])” received error: \(error.localizedFailureReason)")
    }
    
    func offlinePack(_ pack: MGLOfflinePack, didReceiveMaximumAllowedMapboxTiles maximumCount: UInt64) {
        let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as! [String: String]
        print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
    }

    
    // Note: You can remove this method, which lets you customize low-memory behavior.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        NSLog("タップされた")
        return true
    }
//    func mapView(mapView: MGLMapView, didAddAnnotationViews views: [MGLAnnotation]) {
//        for mapview in views {
//            mapview.rightCalloutAccessoryViewForAnnotation = UIButton(type: UIButtonType.DetailDisclosure)
//        }
//    }
    
    
    /*
     ボタンのアクション時に設定したメソッド.
     */
    internal func onClickMyButton(_ sender: UIButton){
        
        let secondViewController = AllMapPage()
        // アニメーションを設定する.
        secondViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        // Viewの移動する.
        self.present(secondViewController, animated: true, completion: nil)
        
      
    }
    
    internal func onClickMyButton2(_ sender: UIButton){
        
        let secondViewController = Filter()
        // アニメーションを設定する.
        secondViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        // Viewの移動する.
        self.present(secondViewController, animated: true, completion: nil)
        
        
    }

    
    

    func get_location_items(){
        
        
        
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
        
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
        
        
        NSLog("latiitude: \(self.latitude) , longitude: \(self.longitude)")

        lm.stopUpdatingLocation()
        
        
        
        // 最初に表示するマップの位置とズームレベルを指定
        mapView!.setCenter(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), zoomLevel: 15, animated: false)
        self.view.addSubview(mapView!)
        
        

        
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // この例ではLogにErrorと表示するだけ．
        NSLog(" error")
    }
    
    func parseJSON(_ inputData: Data){
        let tags: NSDictionary = try! (JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary)!
//        let tags:NSDictionary = NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        for (tag, value) in tags {
            if (value is NSArray){
                let items = value as! NSArray
                for item in items {
                    let lat = item["lat"]
                    let lon = item["lon"]
                    let name = item["name"]
                    if (tag is NSString && lat is NSNumber && lon is NSNumber && name is NSString){
                        let tag0:NSString = tag as! NSString
                        let lat0:NSNumber = lat as! NSNumber
                        let lon0:NSNumber = lon as! NSNumber
                        let name0:NSString = name as! NSString
                        if (name! == nil){
                            addAnnotation(tag0, lat: lat0, lon: lon0, name: tag0)
                        }else{
                            addAnnotation(tag0, lat: lat0, lon: lon0, name: name0)
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    func addAnnotation(_ tag: NSString, lat: NSNumber, lon: NSNumber, name: NSString){
        
        self.tagStore[name as String!] = tag as String
        // Annotation：ピンやで！！
        let point = MGLPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake(lat as Double, lon as Double)
        
        point.title = name as String
        point.subtitle = ""
        mapView!.addAnnotation(point)
        // ここまで
        
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        NSLog("hogehoge!!!!")
            let an = annotation
            let title = an.title
        var tag = self.tagStore[title!! as String]
        if (tag == nil){
            tag = "hoge"
        }
            let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: tag as! String)
        if (annotationImage == nil){
            var image: UIImage?
            if (tag == "hospital"){
                image = UIImage(named: "placeholder.png")
            }else if(tag == "food"){
                image = UIImage(named: "cutlery.png")
            }else{
                image = UIImage(named: "Wi-Fi Logo-96.png")
            }
        
        image = image!.withAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image!.size.height/2, 0))
            
            return MGLAnnotationImage(image: image!, reuseIdentifier: tag as! String)
        }else{
            return annotationImage
        }
    }
    
    
//    func getJson() -> NSData{
//        let raw:NSString = ""
//    }

}
