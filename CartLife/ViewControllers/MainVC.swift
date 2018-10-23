//
//  MainVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/18/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

var CurrentLoction = CLLocation()
class MainVC: UIViewController, CLLocationManagerDelegate ,UITextFieldDelegate , SWRevealViewControllerDelegate{

    @IBOutlet var mapview: GMSMapView!
    @IBOutlet weak var txtsearch: UITextField!
    var locationManager = CLLocationManager()
    var location = CLLocation()
    override func viewDidLoad() {
        super.viewDidLoad()

        revealViewController().delegate = self
        setLeftView1(textfield: txtsearch)
        textfiledborder(textfield: txtsearch)
        setLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        txtsearch.resignFirstResponder()
    }
    
    func setLeftView1(textfield: UITextField)
    {
        textfield.contentMode = .scaleAspectFit
        
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "bars-solid (1)"))
        imageView.frame = CGRect(x: 10, y: 0, width: 30, height: 30)
        
        imageView.isUserInteractionEnabled = true
        
        let T1 = UITapGestureRecognizer()
        
        T1.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        imageView.addGestureRecognizer(T1)

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        view.addSubview(imageView)
        textfield.leftViewMode = UITextFieldViewMode.always
        
        textfield.leftView = view
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseDestinatioVC") as! ChooseDestinatioVC
        nextViewController.userLocation = location
        txtsearch.resignFirstResponder()

        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
    
  
    // MARK: - User Define Functions
    
    func textfiledborder(textfield:UITextField)
    {
        textfield.layer.cornerRadius = 12.0
        textfield.layer.borderWidth = 2.0
        textfield.layer.borderColor = UIColor.white.cgColor
        
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
    
    var isupdated = 0
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        location = locations.last!

        let userLocation = locations.last
        CurrentLoction = locations.last!
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 18);
        
        self.mapview.camera = camera
        locationManager.stopUpdatingLocation()
         self.mapview.clear()
        self.mapview.isMyLocationEnabled = true
        self.mapview.settings.myLocationButton = true
        let marker = GMSMarker(position: center)
        
                marker.map = self.mapview
                marker.title = "Current Location"

        
    }
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        let tagId = 112151
        print("revealController delegate called")
        if revealController.frontViewPosition == FrontViewPosition.right {
            let lock = self.view.viewWithTag(tagId)
            UIView.animate(withDuration: 0.25, animations: {
                lock?.alpha = 0
            }, completion: {(finished: Bool) in
                lock?.removeFromSuperview()
            }
            )
            lock?.removeFromSuperview()
        } else if revealController.frontViewPosition == FrontViewPosition.left {
            let lock = UIView(frame: self.view.bounds)
            lock.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            lock.tag = tagId
            lock.alpha = 0
            lock.backgroundColor = UIColor.black
            lock.addGestureRecognizer(UITapGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:))))
            self.view.addSubview(lock)
            UIView.animate(withDuration: 0.75, animations: {
                lock.alpha = 0.333
            }
            )
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
