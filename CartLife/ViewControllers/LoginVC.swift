
//
//  LoginVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/18/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
class LoginVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{
   

    @IBOutlet weak var btnfblogin: FBSDKLoginButton!
    @IBOutlet weak var imguser: UIImageView!
    
    @IBOutlet weak var txtemail: UITextField!
    

    @IBOutlet weak var btnsignin: UIButton!
    
    @IBOutlet weak var txtpassword: UITextField!
    
    var reg_type = 0
    
    @IBAction func signupacction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    
    @IBAction func facebookAction(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.native
        fbLoginManager.logIn(withReadPermissions: ["email","user_photos"], from: self) { (result, error) in
            if (error == nil){
                if (result?.isCancelled)!{
                    return
                }
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    //fbLoginManager.logOut()
                    
                    
                    self.getFBUserData()
                    
                }
            }
        }
    }
    
    @IBAction func LoginAction(_ sender: Any) {
        if(txtemail.text == "")
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
            self.reg_type = 0
            apilogincall(email: txtemail.text!, password: txtpassword.text!)
            
        }
  
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if(UserDefaults.standard.object(forKey:"userid") != nil)
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }
        
        
       // webservices.sharedInstance.circularimage(imageview: imguser)
        btnsignin.layer.shadowColor = UIColor.black.cgColor
        btnsignin.layer.shadowOffset = CGSize(width: 5, height: 5)
        btnsignin.layer.shadowRadius = 5
        btnsignin.layer.shadowOpacity = 1.0
        textfiledborder(textfield: txtemail)
        textfiledborder(textfield: txtpassword)
        
        webservices.sharedInstance.PaddingTextfiled(textfield:txtemail)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtpassword)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        txtemail.attributedPlaceholder = NSAttributedString(string: "  Email Address",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        txtpassword.attributedPlaceholder = NSAttributedString(string: "  Password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])

        
        webservices.sharedInstance.PaddingTextfiled(textfield:txtemail)
        webservices.sharedInstance.PaddingTextfiled(textfield:txtpassword)
     
        // Do any additional setup after loading the view.
    }
    
    
    
  
 
    // MARK: - Facebook button delegate methods

  
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
        
                    var  dict = result as! [String : AnyObject]
                    var name  = dict["name"]
                    var email  = dict["email"]
                    
                    self.reg_type = 1
                    self.ApiRegisterCall(name: name as! String, email: email as! String)
                   
                }
            })
        }
    }
    
    
    
    // MARK: - Api call for login
    
    func apilogincall(email:String,password:String)
    {
    print(UserDefaults.standard.value(forKey:"FcmToken")!)
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            var parameters: Parameters = [:]
            
            if(reg_type == 0)
            {
            parameters = [
                "email":txtemail.text!,
                "password":txtpassword.text!,
                "device_id": UserDefaults.standard.value(forKey:"FcmToken")!,
                "reg_type":reg_type
                ]
            }
            else
            {
                parameters = [
                    "email":email,
                    "reg_type":reg_type,
                    "device_id": UserDefaults.standard.value(forKey:"FcmToken")!
                ]
                
            }
            Alamofire.request(webservices().baseurl+"login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<LoginResponse>) in
                switch response.result{
                    
                case .success(let resp):
                    webservices().StopSpinner()
                    print(resp)
                    if(resp.errorCode == 0)
                    {
                        
                        UserDefaults.standard.set(resp.data?.token, forKey:"Token")
                        UserDefaults.standard.set(resp.data?.userID, forKey:"userid")
                        UserDefaults.standard.set(resp.data?.name, forKey:"name")
                        UserDefaults.standard.set(resp.data?.email, forKey:"email")
                        UserDefaults.standard.set(self.reg_type, forKey:"reg_type")
                        UserDefaults.standard.set(self.txtpassword.text!, forKey:"password")
                        if(resp.data?.profilePic != nil)
                        {
                         UserDefaults.standard.set(resp.data?.profilePic, forKey:"profilepic")
                        }
                        if(resp.data?.contactNumber != nil)
                        {
                            UserDefaults.standard.set(resp.data?.contactNumber, forKey:"contact_number")

                        }

                        if(self.reg_type == 0)
                        {
                            UserDefaults.standard.set(self.txtpassword.text!, forKey:"password")

                        }
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
    
    
    func ApiRegisterCall(name:String,email:String)
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            var parameters: Parameters = [:]
            
            parameters = [
                    "name":name,
                    "email":email,
                    "reg_type":reg_type,
                    "device_id": UserDefaults.standard.value(forKey:"FcmToken")!

                ]
         
            Alamofire.request(webservices().baseurl+"registration", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSONDecodable{(response:DataResponse<RegisterResponse>) in
                switch response.result{
                    
                case .success(let resp):
                    print(resp)
                    webservices().StopSpinner()
                    if(resp.errorCode == 0)
                    {
                        
                        
                      //  UserDefaults.standard.set(resp.data.token, forKey:"Token")
                        UserDefaults.standard.set(resp.data?.id, forKey:"userid")
                        UserDefaults.standard.set(resp.data?.name, forKey:"name")
                        UserDefaults.standard.set(resp.data?.email, forKey:"email")
                        UserDefaults.standard.set(self.reg_type, forKey:"reg_type")

                        UserDefaults.standard.synchronize()
                         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                     
                        let alert = webservices.sharedInstance.AlertBuilder(title: "", message: resp.message)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if(resp.message.contains("The email has already been taken."))
                    {
                        
                        self.apilogincall(email:email, password:"")
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
