//
//  BreakdownVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/19/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire
class BreakdownVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapview: GMSMapView!
    
    @IBOutlet weak var lblrequest: UILabel!
    @IBOutlet weak var btnclose: UIButton!
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var locationview: UIView!
    @IBOutlet weak var requestpopup: UIView!
    
    @IBOutlet weak var txtfullname: UITextField!
    
    @IBOutlet weak var txtcontact: UITextField!
    
    @IBOutlet weak var txtlocation: UITextField!
    
    @IBOutlet weak var lblname: UILabel!
    
    @IBOutlet weak var lbladdress: UILabel!
    var dic : Datum2?
    
    
    @IBAction func submitaction(_ sender: Any) {
        if(txtfullname.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your name")
            self.present(alert, animated: true, completion: nil)
            
        }
        else if(txtcontact.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your contact")
            self.present(alert, animated: true, completion: nil)
        }
        else if(txtlocation.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your location")
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            SendRequest()
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func RequestAction(_ sender: Any) {
        requestpopup.isHidden = false
        lblrequest.isHidden = false
        btnclose.isHidden = false
    }
    
    @IBAction func cancelaction(_ sender: Any) {
        requestpopup.isHidden = true
        lblrequest.isHidden = true
        btnclose.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     
      
        webservices.sharedInstance.PaddingTextfiled(textfield:txtfullname)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtlocation)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtcontact)
        
     if(UserDefaults.standard.object(forKey:"name") != nil)
     {
     txtfullname.text = UserDefaults.standard.value(forKey:"name") as! String
     }
     if(UserDefaults.standard.object(forKey:"contact_number") != nil)
        {
            txtcontact.text = UserDefaults.standard.value(forKey:"contact_number") as! String
        }
        
        let geocoder = GMSGeocoder()
        
        let newloc = CLLocationCoordinate2D(latitude: CurrentLoction.coordinate.latitude, longitude: CurrentLoction.coordinate.longitude)
        
        
        geocoder.reverseGeocodeCoordinate(newloc) { response , error in
            
            //Add this line
            if let address = response!.firstResult() {
                let lines = address.lines! as [String]
                
              self.txtlocation.text = lines[0]
            }
        }
        
        lblname.text = dic?.name
        lbladdress.text = dic?.address
          setLocation()
        btnclose.layer.cornerRadius = btnclose.frame.width/2
        
        webservices.sharedInstance.setShadow(view: locationview)
        // Do any additional setup after loading the view.
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
        let alertController = UIAlertController(title: "Background Location Access  Disabled", message: "We need your location", preferredStyle: .alert)
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
        
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 18);
        
        self.mapview.camera = camera
        locationManager.stopUpdatingLocation()
        self.mapview.isMyLocationEnabled = true
        self.mapview.settings.myLocationButton = true
        let marker = GMSMarker(position: center)
        
        
        print("Latitude :- \(userLocation!.coordinate.latitude)")
        print("Longitude :-\(userLocation!.coordinate.longitude)")
        
        marker.map = self.mapview
        marker.title = "Current Location"
        
    }
    func SendRequest()
    {
        if webservices().isConnectedToNetwork() == true
        {
            
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "breackdown", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey: "userid") as! Int,"contact_number":txtcontact.text,"name":txtfullname.text,"location":"\(CurrentLoction.coordinate.latitude)-\(CurrentLoction.coordinate.longitude)"] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
