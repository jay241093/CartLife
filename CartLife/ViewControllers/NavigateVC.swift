//
//  NavigateVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class NavigateVC: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {

    @IBOutlet weak var mapview: GMSMapView!
    
    @IBOutlet weak var lbltime: UILabel!
    var locationManager = CLLocationManager()

    var sourceCord = CLLocationCoordinate2D()
    var destCord = CLLocationCoordinate2D()
    
    @IBOutlet weak var btnadd: UIButton!
    @IBOutlet weak var innerview: UIView!
    @IBOutlet weak var txttitle: UITextField!
    @IBOutlet weak var btnnavigate: UIButton!

    @IBOutlet weak var txtmessage: UITextView!
    var isfromsave = 0
    var directionsRoute: Route?
   
 
    @IBAction func closeaction(_ sender: Any) {
        innerview.isHidden = true
    }
    
    
    var timer = Timer()

    @IBAction func SubmitAction(_ sender: Any) {
        
        if(txttitle.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter title")
            self.present(alert, animated: true, completion: nil)
            
        }
        else if(txttitle.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter message")
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            SendRequest()
        }
    
    }
    
    @IBAction func Addaction(_ sender: Any) {
        innerview.isHidden = false
    }
    
    
    @IBAction func backaction(_ sender: Any) {
        
       if(isfromsave == 1)
       {
        self.navigationController?.popViewController(animated: true)
       }
       else
       {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    }
    
    //MARK: - Delegate Methods\
    func scheduledTimerWithTimeInterval(){
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector:#selector(UpdateLocation), userInfo: nil, repeats: true)
    }
    
 @objc func UpdateLocation()
 {
    drawPath()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        txtmessage.text = "Enter Message"

        txtmessage.delegate = self
        if(isfromsave == 1)
        {
      
lbltime.isHidden = true
        }
        else
        {
            setLocation()
            lbltime.isHidden = false
            scheduledTimerWithTimeInterval()
        }
        
        
        webservices.sharedInstance.PaddingTextfiled(textfield:txttitle)
        drawPath()
        // Do any additional setup after loading the view.
  
    }
    
    @IBAction func navigateaction(_ sender: Any) {
        
        if(btnnavigate.imageView?.image == #imageLiteral(resourceName: "navigation"))
        {
            calculateRoute(from: sourceCord, to: destCord) { (route, error) in
            }
            btnnavigate.setImage(#imageLiteral(resourceName: "plus-circle-solid.png"), for: .normal)
            //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //
            //        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigateVC") as! NavigateVC
            //        nextViewController.sourceCord = self.newsourceCord
            //        nextViewController.destCord = self.newdestCord
            //        self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        else
        {
            innerview.isHidden = false
        }
     
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Enter Message"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    //MARK: - user define Methods
    func setLocation()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    func showLocationDisabledpopUp() {
        let alertController = UIAlertController(title: "Location Access  Disabled", message: "We need your location", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open Setting", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Location manager delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied){
            showLocationDisabledpopUp()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" , Error.self)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
//        self.sourceCord = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude:  (locations.last?.coordinate.longitude)!)
    }
    
    
    
    func drawPath()
    {
        var sourceMarker = GMSMarker()
        var destMarker = GMSMarker()
        
        let origin = "\(self.sourceCord.latitude),\(self.sourceCord.longitude)"
        let destination = "\(self.destCord.latitude),\(self.destCord.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&units=imperial&key=AIzaSyC2k9gtTgJxihdaJQ99T7tSs77b_fPA3l0"
        
        Alamofire.request(url).responseJSON { response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            do {
                let json = try JSON(data: response.data!)
                
                let routes = json["routes"].arrayValue
                
                self.mapview.clear()
                
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 3.0
                    polyline.strokeColor = UIColor(red:0.00, green:0.69, blue:1.00, alpha:1.0)
                    polyline.map = self.mapview
                    
                    
                    let legs = route["legs"]
                    
                    let firstLeg = legs[0]
                    
                    let firstLegDurationDict = firstLeg["duration"]
                    let firstLegDuration = firstLegDurationDict["text"]
                    
                    let firstLegDistanceDict = firstLeg["distance"]
                    let firstLegDistance = firstLegDistanceDict["text"]
                    
                    self.lbltime.text = String(describing: firstLegDuration)

                    var bounds = GMSCoordinateBounds()
                    
                    bounds = bounds.includingCoordinate(self.sourceCord)
                    bounds = bounds.includingCoordinate(self.destCord)
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                    self.mapview.animate(with: update)
                    
                    sourceMarker.position = CLLocationCoordinate2D(latitude: self.sourceCord.latitude, longitude: self.sourceCord.longitude)
                    sourceMarker.map = self.mapview
                    
                    destMarker.position = CLLocationCoordinate2D(latitude: self.destCord.latitude, longitude: self.destCord.longitude)
                    destMarker.map = self.mapview
                  
                    
                    
                }
            }
            catch _ {
                let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"no routes founds")
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
    }
    
    func SendRequest()
    {
        if webservices().isConnectedToNetwork() == true
        {
           webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "sendnotification", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey: "userid") as! Int,"title":txttitle.text,"message":txtmessage.text] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    webservices().StopSpinner()
                    
                    if let data = response.result.value{
                        
                        let dic: NSDictionary = response.result.value as! NSDictionary
                        
                        if(dic.value(forKey: "error_code") as! Int == 0)
                        {
                            let alert = webservices.sharedInstance.AlertBuilder(title:"", message: dic.value(forKey:"message") as! String)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            let alert = webservices.sharedInstance.AlertBuilder(title:"", message: dic.value(forKey:"message") as! String)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    break
                    
                case .failure(_):
                    webservices().StopSpinner()
                    
                    print(response.result.error)
                    break
                    
                }
            }
            
        }
        else
        {
            webservices.sharedInstance.nointernetconnection()
        }
        
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        // Specify that the route is intended for automobiles avoiding traffic
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
           // self.drawRoute(route: self.directionsRoute!)
            let navigationViewController = NavigationViewController(for: self.directionsRoute!)
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
