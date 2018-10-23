//
//  NotifcationVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire
class NotifcationVC: UIViewController ,UITableViewDelegate , UITableViewDataSource{
    @IBOutlet weak var tblview: UITableView!
    
    @IBOutlet weak var innerview: UIView!
    var notificationary = NSMutableArray()
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
getallnotifcations()
        webservices.sharedInstance.setShadow(view: innerview)

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationary.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! NotificationCell
        let dic = notificationary.object(at: indexPath.row) as! NSDictionary
        
        cell.lblname.text = dic.value(forKey:"title") as! String
        cell.lbladdress.text = dic.value(forKey:"message") as! String
       cell.lblcreatedat.text = dic.value(forKey:"created_at") as! String
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let dic =  notificationary.object(at: indexPath.row) as! NSDictionary

            Deletenotification(id:dic.value(forKey:"id") as! Int)
        }
    }
    func getallnotifcations()
    {
        if webservices().isConnectedToNetwork() == true
        {
            
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "getnotification", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey: "userid") as! Int] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    webservices().StopSpinner()
                    
                    if let data = response.result.value{
                        
                        let dic: NSDictionary = response.result.value as! NSDictionary
                  

                        if(dic.value(forKey: "error_code") as! Int == 0)
                        {
                            self.notificationary = ((response.result.value as! NSDictionary).value(forKey:"data") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblview.reloadData()
                            if(self.notificationary.count == 0)
                            {
                                let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"No notifications available")
                                self.present(alert, animated: true, completion: nil)
                            }else
                            {
                                
                            }

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
    func Deletenotification(id:Int)
    {
        if webservices().isConnectedToNetwork() == true
        {
            
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "deletenotification", method: .post, parameters:["id":id] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    webservices().StopSpinner()
                    
                    if let data = response.result.value{
                        
                        let dic: NSDictionary = response.result.value as! NSDictionary
                        
                        if(dic.value(forKey: "error_code") as! Int == 0)
                        {
                         
                            self.getallnotifcations()
                            
                         
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
