//
//  ChooseDestinatioVC.swift
//  greegotaxiapp
//
//  Created by Harshal Shah on 07/04/18.
//  Copyright © 2018 jay. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

let SELECTED_COLOR = UIColor(red:0.00, green:0.58, blue:0.59, alpha:1.0)

protocol locationDelegate:class
{
    func sendCordsBack(source:GMSPlace, destination: GMSPlace)
    func closePlacePicker()
}

class ChooseDestinatioVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate,UITextViewDelegate,MGLMapViewDelegate
{
   
    var directionsRoute: Route?
    @IBOutlet weak var btnsave: UIButton!
    
    @IBOutlet var viewrequest: UIView!
    
    @IBOutlet weak var imgpin: UIImageView!
    @IBOutlet weak var btnSet: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var parentMapView: UIView!
    @IBOutlet weak var lblstart: UILabel!
    @IBOutlet weak var lblend: UILabel!
    
    @IBOutlet weak var viewChooseLocation: UIView!
    
    @IBOutlet weak var txtStartLocation: UITextField!
    @IBOutlet weak var txtEndLocation: UITextField!
  
    @IBOutlet weak var tblAutoComplete: UITableView!
    
    @IBOutlet weak var txttitle: UITextField!
    
    @IBOutlet weak var txtmessage: UITextView!
    
    var currentTxtField = UITextField()
    
    let geocoder = GMSGeocoder()
    
    var placesClient : GMSPlacesClient?
    var resultArray  = [GMSPlace]()
    var locationManager = CLLocationManager()
    var sourceMarker = GMSMarker()
    var destMarker = GMSMarker()
    var isTxtSource = false
    var isTxtDest = false
   
    var isTxtSourceFilled = false
    var isTxtDestFilled = false
    
    weak var locDelegate:locationDelegate?
    var sourceLocation = CLLocationCoordinate2D()
    var sourcePlace = String()
    var destPlace = String()
    var userLocation = CLLocation()
     var sourceCord = CLLocationCoordinate2D()
     var destCord = CLLocationCoordinate2D()
    var newsourceCord = CLLocationCoordinate2D()
    var newdestCord = CLLocationCoordinate2D()
   
    @IBOutlet weak var btnnavigate: UIButton!
    
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
    
    
    @IBAction func closeaction(_ sender: Any) {
        viewrequest.isHidden = true
    }
    
    @IBAction func naviagateaction(_ sender: Any) {
        
        if(btnnavigate.imageView?.image == #imageLiteral(resourceName: "navigation"))
        {
       
            if let url = URL(string: "comgooglemaps://?saddr=\(newsourceCord.latitude),\(newsourceCord.longitude)&daddr=\(newdestCord.latitude),\(newdestCord.longitude)&directionsmode=bycycling") {
                UIApplication.shared.open(url, options: [:])
            }
        btnnavigate.setImage(#imageLiteral(resourceName: "plus-circle-solid.png"), for: .normal)
        
        }
        else
        {
           viewrequest.isHidden = false
        }
        
    }
    
    
    @IBAction func SaveAction(_ sender: Any) {
        
        saveroute(latitude:"\(self.newsourceCord.latitude)-\(self.newsourceCord.longitude)", longitude: "\(self.newdestCord.latitude)-\(self.newdestCord.longitude)")
    }
  
//MARK: - Delegate Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtmessage.text = "Enter Message"
        txtmessage.textColor = UIColor.lightGray

        txtmessage.delegate = self
        self.placesClient = GMSPlacesClient()

        txtStartLocation.clearButtonMode = .whileEditing
        txtEndLocation.clearButtonMode = .whileEditing

        
        self.navigationController?.isNavigationBarHidden = true
        self.txtEndLocation.text = ""
        self.txtStartLocation.text = ""

        self.placesClient = GMSPlacesClient()
  
        tblAutoComplete.delegate = self
        tblAutoComplete.dataSource = self
        self.setLabelStringAttribs()
        
        setLeftView1(textfield: txtStartLocation)
        setLeftView1(textfield: txtEndLocation)
        textfiledborder(textfield: txtStartLocation)
        textfiledborder(textfield: txtEndLocation)

        
        self.setupView()

        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 18);
     //   self.mapView.camera = camera
        //     txtEndLocation.text = ""
        //        txtStartLocation.text = ""
        sourceCord.latitude = 0.0
        sourceCord.longitude = 0.0
        destCord.latitude = 0.0
        destCord.longitude = 0.0
        
        let geocoder = GMSGeocoder()
        
        let newloc = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        
        geocoder.reverseGeocodeCoordinate(newloc) { response , error in
            
            //Add this line
            if let address = response!.firstResult() {
                let lines = address.lines! as [String]
                
                //self.txtStartLocation.text = lines[0] + "," + lines[1]
            }
        }
        self.getAddressFromGeocodeCoordinate(coordinate: newloc)
        self.currentTxtField = txtStartLocation
        isTxtSource = true
        isTxtDest = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" , Error.self)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last

        
        self.mapView.delegate = self
        let geocoder = GMSGeocoder()

    }
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }
   
    
    @IBAction func textDidChange(_ textField: UITextField)
    {
                let currentText = textField.text ?? ""
        parentMapView.isUserInteractionEnabled = false
        parentMapView.isHidden = true
        tblAutoComplete.isHidden = false
        if currentText == "" {
            
            //self.view.endEditing(true)
        
            
            resultArray.removeAll()
            self.tblAutoComplete.reloadData()
            return
        }
        placeAutocomplete(text:currentText)
    }
   
    @IBAction func destTextDidChange(_ textField: UITextField)
    {
        
        parentMapView.isUserInteractionEnabled = false
        parentMapView.isHidden = true
        tblAutoComplete.isHidden = false
        let currentText = textField.text ?? ""
        if currentText == "" {
          //  self.view.endEditing(true)
          
            resultArray.removeAll()
            self.tblAutoComplete.reloadData()
            return
        }
        placeAutocomplete(text:currentText)
    }
//    @objc func didChangeText(textField:UITextField)
//    {
//        let currentText = textField.text ?? ""
//        placeAutocomplete(text:currentText)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
     
       btnnavigate.setImage(#imageLiteral(resourceName: "navigation"), for: .normal)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let coordinate = mapView.projection.coordinate(for: mapView.center)
      //  print("latitude " + "\(coordinate.latitude)" + " longitude " + "\(coordinate.longitude)")
        
        sourceLocation = coordinate
        
       if(isTxtSource)
       {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            //Add this line
            
            if(response != nil)
            {
            if let address = response!.firstResult() {
               
                self.txtStartLocation.text = address.lines?.first
            }
            }
        
        
        }
        getAddressFromGeocodeCoordinate(coordinate: sourceLocation)

        }
       if(isTxtDest){
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            //Add this line
            if(response != nil)
            {
            if let address = response!.firstResult() {
                
                
                self.txtEndLocation.text = address.lines?.first
            }
            
            }
        }
        
        }
    }
    
//MARK: - User Define Methods
    
    func setLocation()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func placeAutocomplete(text:String) {
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        placesClient?.autocompleteQuery(text, bounds: nil, filter: filter, callback: {(results, error) -> Void in   //unable to enter in this block
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                self.resultArray = [GMSPlace]()
                for result in results {
                    
                    // A hotel in Saigon with an attribution.
                    let placeID = result.placeID;
                    self.placesClient?.lookUpPlaceID(placeID!, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let place = place else {
                            print("No place details for \(String(describing: placeID))")
                            return
                        }
                        
                        if self.resultArray.count <= 5
                        {
                            self.resultArray.append(place)
                        }
                        
                         print("Place name \(place.name)")
                        print("Place address \(String(describing: place.formattedAddress))")
                        print("Place placeID \(place.placeID)")
                        print("Place attributions \(String(describing: place.attributions))")
                         self.tblAutoComplete.reloadData()
                    })
                    
                    print("Result \(result.attributedPrimaryText) with placeID \(String(describing: result.placeID))")
                }
            }
           
        })
    }
    
    
    func setupView()
    {
        viewChooseLocation.layer.borderColor =  UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor
        viewChooseLocation.layer.borderWidth = 1.0
        
        viewChooseLocation.layer.masksToBounds = false
        viewChooseLocation.layer.shadowColor = UIColor.black.cgColor
        
        viewChooseLocation.layer.shadowOpacity = 0.5
        viewChooseLocation.layer.shadowOffset = CGSize(width: -1, height: 1)
        viewChooseLocation.layer.shadowRadius = 1
        
        parentMapView.isUserInteractionEnabled = false
        parentMapView.isHidden = true
        
    }

    func setLabelStringAttribs()
    {
        self.lblstart.layer.cornerRadius = lblstart.frame.width/2
        self.lblstart.layer.masksToBounds = true

    }
    
    func getAddressFromGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            //Add this line
            if(response != nil)
            {
            if let address = response!.firstResult() {
                if self.isTxtSource == true
                {
                    self.sourceCord = coordinate
                    self.sourcePlace = (address.lines?.first)!
                    self.isTxtSourceFilled = true
                    
                }
                else
                {
                    self.destCord = coordinate
                    self.destPlace = (address.lines?.first)!
                    self.isTxtDestFilled = true

                }
                let lines = address.lines! as [String]
                
                self.currentTxtField.text = lines.first
                self.resultArray.removeAll()
                self.view.endEditing(true)
            
        //        print(lines)
                
                if self.sourceCord.latitude != 0.0 && self.sourceCord.longitude != 0.0 && self.destCord.latitude != 0.0 && self.destCord.longitude != 0.0
                {
                    self.view.endEditing(true)
                    self.parentMapView.isUserInteractionEnabled = true
                    self.parentMapView.isHidden = false
                    self.btnSet.isHidden = true
                    self.imgpin.isHidden = true
                    self.txtStartLocation.resignFirstResponder()
                     self.txtEndLocation.resignFirstResponder()
                   
                    self.isTxtSource = false
                    self.isTxtDest = false
                    self.btnnavigate.isHidden = false
                    self.btnsave.isHidden = false

                    self.drawPath()

                }
              }
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
                            self.viewrequest.isHidden = true
                            self.txtmessage.text = ""
                            self.txttitle.text = ""
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(textView == txtmessage)
        {
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
        else
        
        {
            return true

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
            let origin = Waypoint(coordinate:self.newsourceCord, name: "")
            let destination = Waypoint(coordinate:self.newdestCord, name: "")
            
            let options =  RouteOptions(coordinates: [self.newsourceCord,self.newdestCord], profileIdentifier:  MBDirectionsProfileIdentifier.walking)
            options.routeShapeResolution = .full
            options.includesSteps = true
     
            Directions.shared.calculate(options) { (waypoints, routes, error) in
                guard let route = routes?.first else { return }
                
                let viewController = NavigationViewController(for: route)
                self.present(viewController, animated: true, completion: nil)
            }
            
            
        }
    }
    
  var routeLine = MGLPolyline()
    
    func drawPath()
    {
//        mapView.removeAnnotation(routeLine)
//
//
//           let wp1 = Waypoint(coordinate: self.sourceCord)
//            let wp2 = Waypoint(coordinate:self.destCord)
//            var options = RouteOptions(waypoints:[])
//             options = RouteOptions(waypoints: [wp1, wp2])
//            options.includesSteps = true
//
//            Directions(accessToken:"pk.eyJ1IjoicHJpeWFua2EtaW5ub3ZpdXMiLCJhIjoiY2pudmRlZWF1MGNzZTNxbzB3enNncGl2bSJ9.K-ybnKyDFRbauri5I6aosA").calculate(options) { (waypoints, routes, error) in
//                guard error == nil else {
//                    print("Error calculating directions: \(error!)")
//                    return
//                }
//
//                if let route = routes?.first, let leg = route.legs.first {
//                    print("Route via \(leg):")
//
//                    let distanceFormatter = LengthFormatter()
//                    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
//
//                    let travelTimeFormatter = DateComponentsFormatter()
//                    travelTimeFormatter.unitsStyle = .short
//                    let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
//
//                    print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
//
//                    for step in leg.steps {
//                        print("\(step.instructions)")
//                        if step.distance > 0 {
//                            let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
//                            print("— \(formattedDistance) —")
//                        }
//                    }
//                    self.newsourceCord = self.sourceCord
//                    self.newdestCord = self.destCord
//                    if route.coordinateCount > 0 {
//
//
//
//                        // Convert the route’s coordinates into a polyline.
//                        var routeCoordinates = route.coordinates!
//
//                        self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
//
//                        // Add the polyline to the map and fit the viewport to the polyline.
//                        self.mapView.addAnnotation(self.routeLine)
//                        self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero, animated: true)
//
//
//                    }
//                }
//            }
//
//
        var sourceMarker = GMSMarker()
        var destMarker = GMSMarker()

        let origin = "\(self.sourceCord.latitude),\(self.sourceCord.longitude)"
        let destination = "\(self.destCord.latitude),\(self.destCord.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&mode=bicycling&key=AIzaSyC2k9gtTgJxihdaJQ99T7tSs77b_fPA3l0"
        
        
        
        
        Alamofire.request(url).responseJSON { response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            do {
                let json = try JSON(data: response.data!)

                let routes = json["routes"].arrayValue

                self.mapView.clear()

                for route in routes
                {
                  let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 3.0
                    polyline.strokeColor = UIColor(red:0.00, green:0.69, blue:1.00, alpha:1.0)
                    polyline.map = self.mapView
                    let legs = route["legs"]

                    let firstLeg = legs[0]

                    let firstLegDurationDict = firstLeg["duration"]
                    let firstLegDuration = firstLegDurationDict["text"]

                    let firstLegDistanceDict = firstLeg["distance"]
                    let firstLegDistance = firstLegDistanceDict["text"]

                    var bounds = GMSCoordinateBounds()

                    bounds = bounds.includingCoordinate(self.sourceCord)
                    bounds = bounds.includingCoordinate(self.destCord)
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 130)
                    self.mapView.animate(with: update)

                   sourceMarker.title = self.txtStartLocation.text!
                    sourceMarker.position = CLLocationCoordinate2D(latitude: self.sourceCord.latitude, longitude: self.sourceCord.longitude)
                    sourceMarker.map = self.mapView

                   destMarker.title = self.txtEndLocation.text!
                    destMarker.position = CLLocationCoordinate2D(latitude: self.destCord.latitude, longitude: self.destCord.longitude)
                   destMarker.map = self.mapView
                    self.newsourceCord = self.sourceCord
                    self.newdestCord = self.destCord

              


                }
            }
            catch _ {
                let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"no routes founds")
                self.present(alert, animated: true, completion: nil)
            }


        }
    
    
    }
    
    func saveroute(latitude:String,longitude:String)
    {
        if webservices().isConnectedToNetwork() == true
        {
        
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "saveroute", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey: "userid") as! Int,"from":latitude,"to":longitude] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
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
    
    
//MARK : IBAction Methods
    
    @IBAction func btnSetClicked(_ sender: Any)
    {
        parentMapView.isUserInteractionEnabled = false
        parentMapView.isHidden = true
        
        
       getAddressFromGeocodeCoordinate(coordinate: sourceLocation)
        
    }
    
    func setLeftView1(textfield: UITextField)
    {
        textfield.contentMode = .scaleAspectFit
        
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "location"))
        imageView.frame = CGRect(x: 10, y: 0, width: 30, height: 30)
        
        imageView.isUserInteractionEnabled = true
    
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        view.addSubview(imageView)
        textfield.leftViewMode = UITextFieldViewMode.always
        
        textfield.leftView = view
    }
    // MARK: - User Define Functions
    
    func textfiledborder(textfield:UITextField)
    {
        textfield.layer.cornerRadius = 12.0
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.clear.cgColor
        textfield.layer.masksToBounds = false
        textfield.layer.shadowRadius = 2.0
        textfield.layer.shadowColor = UIColor.black.cgColor
        textfield.layer.shadowOffset = CGSize(width: 1.0, height:  1.0)
        textfield.layer.shadowOpacity = 1.0
      
    }
    
}
extension ChooseDestinatioVC:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        btnnavigate.setImage(#imageLiteral(resourceName: "navigation"), for:.normal)
        parentMapView.isUserInteractionEnabled = false
        
        parentMapView.isHidden = true
        self.imgpin.isHidden = false
        self.btnSet.isHidden = false
        //self.mapView.clear()
    

        self.tblAutoComplete.isHidden = false
        
        self.tblAutoComplete.reloadData()
        
        if(textField == txtStartLocation)
        {
            
            
            isTxtSource = true
            isTxtDest = false
           currentTxtField = txtStartLocation
        }
        else if(textField == txtEndLocation)
        {
            isTxtSource = false
            isTxtDest = true
            currentTxtField = txtEndLocation
        }
        else
        {
            isTxtSource = false
            isTxtDest = false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    { 
        self.tblAutoComplete.isHidden = false
        //self.resultArray.removeAll()
        
    }
    
}




extension ChooseDestinatioVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setLocationCell", for: indexPath) as! setLocationCell
        if indexPath.row < resultArray.count
        {
        let place = resultArray[indexPath.row]
        cell.lblName.text = place.name
        cell.lblAddress.text = place.formattedAddress
        }
//        else
//        ż
//            cell.lblName.text = "Set location on the map"
//            cell.lblAddress.text = ""
//            cell.imgView.image = #imageLiteral(resourceName: "location")
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //do something, unable to reach here
        self.tblAutoComplete.isHidden = true

       if(resultArray.count > 0)
       {
        let place = resultArray[indexPath.row]
        
        let cord = place.coordinate
        self.getAddressFromGeocodeCoordinate(coordinate: cord)
        self.tblAutoComplete.isHidden = true

        }
    }
//MARK : IBAction Methods
    
    @IBAction func btnBackClicked(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}
