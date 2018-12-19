//
//  ServiceProviderVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/19/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import  Alamofire
class ServiceProviderVC: UIViewController ,UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tblview: UITableView!
    
    @IBAction func back(_ sender: Any) {
    
        if(isfromsidemenu == 1)
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
            }
    }
    
    var serviceary = [Datum2]()
    var isfromsidemenu = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
GetServiceproviders()
        // Do any additional setup after loading the view.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return serviceary.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ServiceProviderCell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! ServiceProviderCell
        webservices.sharedInstance.setShadow(view: cell.contentview)
        let dic = serviceary[indexPath.row]

        cell.lblname.text = dic.name
        cell.lbladdress.text = dic.address
        
        var url = "http://ignitiveit.com/cartlife/storage/app/" + dic.image
        cell.imgview.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "download-1"))
        cell.rating.rating =  Float(dic.rating)!
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic1 = serviceary[indexPath.row]

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BreakdownVC") as! BreakdownVC
        
        nextViewController.dic = dic1
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
    
    
    func GetServiceproviders()
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            
            
            Alamofire.request(webservices().baseurl+"service_provider", method: .post, parameters:[:], encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<ServiceProviderRes>) in
                switch response.result{
                    
                case .success(let resp):
                    print(resp)
                    webservices().StopSpinner()
                    if(resp.errorCode == 0)
                    {
                        self.serviceary = resp.data
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
