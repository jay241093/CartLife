//
//  ChangePasswordVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/19/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var txtoldpwd: UITextField!
    @IBOutlet weak var txtnewpwd: UITextField!
    @IBOutlet weak var txtretypenew: UITextField!
    
    
    @IBAction func submitaction(_ sender: Any) {
        
       if(UserDefaults.standard.object(forKey:"reg_type") != nil)
       {
        if(UserDefaults.standard.value(forKey:"reg_type") as! Int == 1)
        {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"you cannot update your password while you are login with facebook")
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
           if(txtoldpwd.text == "")
           {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"Please Enter Old Password")
            self.present(alert, animated: true, completion: nil)
            
            }
            else if(txtoldpwd.text != UserDefaults.standard.value(forKey:"password") as! String)
           {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"Please Enter Correct Old Password")
            self.present(alert, animated: true, completion: nil)
            }
           else if(txtnewpwd.text == "")
           {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"Please Enter New Password")
            self.present(alert, animated: true, completion: nil)
            }
           else if(txtretypenew.text == "")
           {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"Please Enter Retype New Password")
            self.present(alert, animated: true, completion: nil)
            }
           else if(txtnewpwd.text != txtretypenew.text)
           {
            let alert = webservices.sharedInstance.AlertBuilder(title: "", message:"Please  Retype New Password")
            self.present(alert, animated: true, completion: nil)
            }
            else
           {
            
             ChangePassword()
            }
            
            
        }
        

        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)    }
    @IBOutlet weak var mainview: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webservices.sharedInstance.setShadow(view: mainview)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtoldpwd)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtnewpwd)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtretypenew)
        // Do any additional setup after loading the view.
    }

    func ChangePassword()
    {
        if webservices().isConnectedToNetwork() == true
        {
            
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "changepassword", method: .post, parameters:["user_id":UserDefaults.standard.value(forKey: "userid") as! Int,"old_password":txtoldpwd.text,"new_password":txtnewpwd.text] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    webservices().StopSpinner()
                    
                    if let data = response.result.value{
                        
                        let dic: NSDictionary = response.result.value as! NSDictionary
                        
                        if(dic.value(forKey: "error_code") as! Int == 0)
                        {
                            self.txtoldpwd.text = ""
                            self.txtnewpwd.text = ""
                            self.txtretypenew.text = ""
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
