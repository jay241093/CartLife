//
//  SundayStrollsVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/19/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import GoogleMaps
class SundayStrollsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var btnstrolls: UIButton!
    @IBOutlet weak var tblview: UITableView!
    
    @IBOutlet weak var btnsave: UIButton!
    
    
    var sundaystrollsary = [Datum]()
    var mysaveary = [Datum1]()

    @IBOutlet weak var lblnoroute: UILabel!
    
    var isfrom = 0
    
    
    @IBAction func sundaystrollsaction(_ sender: Any) {
        
        isfrom = 0
        self.lblnoroute.isHidden = true
        tblview.reloadData()
        
    }
    
    @IBAction func saveactions(_ sender: Any) {
        isfrom = 1
        if(mysaveary.count == 0)
        {
        self.lblnoroute.isHidden = false
        }
        else
        {
            self.lblnoroute.isHidden = true

        }
         tblview.reloadData()
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)    }
    @IBOutlet weak var mainview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webservices.sharedInstance.setShadow(view: mainview)
        webservices.sharedInstance.setShadow(view: btnsave)
        webservices.sharedInstance.setShadow(view: btnstrolls)

      GetSundayStrolls()
         Mysaves()
        // Do any additional setup after loading the view.
    }
    
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tablview delegate and data source methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isfrom == 0)
        {
        return sundaystrollsary.count
            
        }
        else
        {
            return mysaveary.count

           
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(isfrom == 0)
        {
        let cell: ServiceProviderCell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! ServiceProviderCell
        webservices.sharedInstance.setShadow(view: cell.contentview)
            let dic = sundaystrollsary[indexPath.row]
            
            var url = "http://ignitiveit.com/cartlife/storage/app/" + dic.image
            cell.imgview.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "download-1"))
           cell.lblname.text = dic.placeName
            cell.lbladdress.text = dic.placeAddress
            cell.rating.rating = Float(dic.rating)!
        

        return cell
        }
        else
        
        {
            let cell: SaveRoutesCell = tableView.dequeueReusableCell(withIdentifier:"cell1", for: indexPath) as! SaveRoutesCell
            webservices.sharedInstance.setShadow(view: cell)
            cell.selectionStyle = .none
            let dic = mysaveary[indexPath.row]

            let geocoder = GMSGeocoder()
            var fullName: String =  dic.from

            var fullNameArr = fullName.components(separatedBy:"-")
            var firstName: NSString = ""
            var lastName: NSString = ""
            
            if(fullNameArr.count == 3)
            {
                firstName = fullNameArr[0] as NSString
                lastName =  "-" + fullNameArr[2] as NSString
            }
            else
            {
                firstName = fullNameArr[0] as NSString
                lastName =  fullNameArr[1] as NSString
                
            }
            
            var fullName1: String =  dic.to
            
            var fullNameArr1 = fullName1.components(separatedBy:"-")
            var firstName1: NSString = ""
            var lastName1: NSString = ""
            
            if(fullNameArr1.count == 3)
            {
                firstName1 = fullNameArr1[0] as NSString
                lastName1 =  "-" + fullNameArr1[2] as NSString
            }
            else
            {
                firstName1 = fullNameArr1[0] as NSString
                lastName1 =  fullNameArr1[1] as NSString
                
            }
            
            let newloc = CLLocationCoordinate2D(latitude:firstName.doubleValue, longitude:lastName.doubleValue)
            
            let newloc1 = CLLocationCoordinate2D(latitude:firstName1.doubleValue, longitude:lastName1.doubleValue)

            geocoder.reverseGeocodeCoordinate(newloc) { response , error in
                
                //Add this line
                if let address = response!.firstResult() {
                    let lines = address.lines! as [String]
                    
                 cell.lblstart.text = lines[0]
                }
            }
            
            geocoder.reverseGeocodeCoordinate(newloc1) { response , error in
               //Add this line
                if let address = response!.firstResult() {
                    let lines = address.lines! as [String]
                    
                    cell.lbldestination.text = lines[0]
                }
            }
            
            
            return cell

            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isfrom == 1)
        {
            let dic = mysaveary[indexPath.row]
            
            let geocoder = GMSGeocoder()
            var fullName: String =  dic.from
            
            var firstName: NSString = ""
            var lastName: NSString = ""
            
            var fullNameArr = fullName.components(separatedBy:"-")
            if(fullNameArr.count == 3)
            {
                firstName = fullNameArr[0] as NSString
                lastName =  "-" + fullNameArr[2] as NSString
            }
            else
            {
                firstName = fullNameArr[0] as NSString
                lastName =  fullNameArr[1] as NSString
                
            }
            
            
            var fullName1: String =  dic.to
            
            var fullNameArr1 = fullName1.components(separatedBy:"-")
            var firstName1: NSString = ""
            var lastName1: NSString = ""

            if(fullNameArr1.count == 3)
            {
             firstName1 = fullNameArr1[0] as NSString
             lastName1 =  "-" + fullNameArr1[2] as NSString
            }
            else
            {
                firstName1 = fullNameArr1[0] as NSString
                lastName1 =  fullNameArr1[1] as NSString

            }
            print(firstName1)
            print(lastName1)

            let newloc = CLLocationCoordinate2D(latitude:firstName.doubleValue, longitude:lastName.doubleValue)
            
            let newloc1 = CLLocationCoordinate2D(latitude:firstName1.doubleValue, longitude:lastName1.doubleValue)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigateVC") as! NavigateVC
        nextViewController.isfromsave = 1
            nextViewController.sourceCord = newloc
            nextViewController.destCord = newloc1
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    
    func GetSundayStrolls()
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            
       
            Alamofire.request(webservices().baseurl+"sundaystrolls", method: .post, parameters:[:], encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<Sundaystrolls>) in
                switch response.result{
                    
                case .success(let resp):
                    webservices().StopSpinner()
                    if(resp.errorCode == 0)
                    {
                        self.sundaystrollsary = resp.data
                        self.tblview.reloadData()
        
                    }
               
                    else
                    {
                        let alert = webservices.sharedInstance.AlertBuilder(title: "", message: resp.message)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                case .failure(let err):
                    webservices().StopSpinner()
                    
                    print(err.localizedDescription)
                }
            }
            
        }
        else
        {
            
            webservices.sharedInstance.nointernetconnection()
            NSLog("No Internet Connection")
        }
        
    }
    
    
    func Mysaves()
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            
            
            Alamofire.request(webservices().baseurl+"getallroute", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey:"userid") as! Int], encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<RoutesResponse>) in
                switch response.result{
                    
                case .success(let resp):
                    webservices().StopSpinner()
                    if(resp.errorCode == 0)
                    {
                        self.mysaveary = resp.data
                        self.tblview.reloadData()
                        if(resp.data.count == 0)
                        {
                            let alert = webservices.sharedInstance.AlertBuilder(title: "", message: resp.message)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                        
                    else
                    {
                        let alert = webservices.sharedInstance.AlertBuilder(title: "", message: resp.message)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                case .failure(let err):
                    webservices().StopSpinner()
                    
                    print(err.localizedDescription)
                }
            }
            
        }
        else
        {
            
            webservices.sharedInstance.nointernetconnection()
            NSLog("No Internet Connection")
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
