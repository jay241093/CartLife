//
//  SignUpVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/18/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire

class SignUpVC: UIViewController {
    @IBOutlet weak var txtfullname: UITextField!
    
    @IBOutlet weak var txtemail: UITextField!
    
    @IBOutlet weak var txtpassword: UITextField!
    @IBOutlet weak var btncreate: UIButton!
    
    @IBOutlet weak var btnlogin: UIButton!
    @IBAction func loginaction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func backaction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func CreateAction(_ sender: Any) {
        if(txtfullname.text == "")
            
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please Enter Your Name")
            self.present(alert, animated: true, completion: nil)
            
        }
         else if(txtemail.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please Enter Your Email-Address")
            self.present(alert, animated: true, completion: nil)
            
        }
        else if(!isValidEmail(testStr:txtemail.text!))
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please Enter Correct Email-Address")
            self.present(alert, animated: true, completion: nil)
            
        }
        else if(txtpassword.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please Enter Your Password")
            self.present(alert, animated: true, completion: nil)
           
        }
        else
            
        {
          ApiRegisterCall()
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnlogin.layer.shadowColor = UIColor.black.cgColor
        btnlogin.layer.shadowOffset = CGSize(width: 5, height: 5)
        btnlogin.layer.shadowRadius = 5
        btnlogin.layer.shadowOpacity = 1.0
        
        btncreate.layer.shadowColor = UIColor.black.cgColor
        btncreate.layer.shadowOffset = CGSize(width: 5, height: 5)
        btncreate.layer.shadowRadius = 5
        btncreate.layer.shadowOpacity = 1.0
        
        
        textfiledborder(textfield: txtfullname)
        textfiledborder(textfield: txtemail)
        textfiledborder(textfield: txtpassword)

        webservices.sharedInstance.PaddingTextfiled(textfield:txtemail)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtpassword)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtfullname)


        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        txtemail.attributedPlaceholder = NSAttributedString(string: "  Email Address",
                                                            attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        txtpassword.attributedPlaceholder = NSAttributedString(string: "  Password",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        txtfullname.attributedPlaceholder = NSAttributedString(string: "  Full Name",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])

        // Do any additional setup after loading the view.
    }

    
    
    
    
    
    // MARK: - Api register Call

    func ApiRegisterCall()
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            var parameters: Parameters = [:]
            
            parameters = [
                "name":txtfullname.text!,
                "email":txtemail.text!,
                "password":txtpassword.text!,
                "reg_type":0,
                "device_id": UserDefaults.standard.value(forKey:"FcmToken")!
                
            ]
            
            Alamofire.request(webservices().baseurl+"registration", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<RegisterResponse>) in
                switch response.result{
                    
                case .success(let resp):
                    print(resp)
                    webservices().StopSpinner()
                    if(resp.errorCode == 0)
                    {
                        UserDefaults.standard.set(resp.data?.id, forKey:"userid")
                        UserDefaults.standard.set(resp.data?.name, forKey:"name")
                        UserDefaults.standard.set(resp.data?.email, forKey:"email")
                        UserDefaults.standard.set(self.txtpassword.text!, forKey:"password")
                        
                        UserDefaults.standard.set(0, forKey:"reg_type")


                        UserDefaults.standard.synchronize()
                      
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                        
                        let alert = webservices.sharedInstance.AlertBuilder(title: "", message: resp.message)
                        self.present(alert, animated: true, completion: nil)
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
    
    
    
    // MARK: - User Define Functions
    
    func textfiledborder(textfield:UITextField)
    {
        textfield.layer.cornerRadius = 12.0
        textfield.layer.borderWidth = 2.0
        textfield.layer.borderColor = UIColor.white.cgColor
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
