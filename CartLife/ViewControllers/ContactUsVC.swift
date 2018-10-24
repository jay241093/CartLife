//
//  ContactUsVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/21/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
class ContactUsVC: UIViewController , UITextViewDelegate{
    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var innerview: UIView!
    @IBOutlet weak var txtemail: UITextField!
    
    @IBOutlet weak var txtname: UITextField!
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func SubmitAction(_ sender: Any) {
        
        if(txtname.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your name")
            self.present(alert, animated: true, completion: nil)
            
        }
        else if(txtemail.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your email")
            self.present(alert, animated: true, completion: nil)
        }
        else if(textview.text == "")
        {
            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Please enter your message")
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            SendRequest()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().enable = false
        textview.text = "Enter Message"
        textview.textColor = UIColor.lightGray
        textview.delegate = self
        textview.becomeFirstResponder()
       textview.selectedTextRange = textview.textRange(from: textview.beginningOfDocument, to: textview.beginningOfDocument)
   webservices.sharedInstance.setShadow(view: innerview)
        webservices.sharedInstance.PaddingTextfiled(textfield: txtemail)
        webservices.sharedInstance.PaddingTextfiled(textfield: txtname)
        
        if(UserDefaults.standard.object(forKey:"name") != nil)
        {
            txtname.text = UserDefaults.standard.value(forKey:"name") as! String
        }
        if(UserDefaults.standard.object(forKey:"email") != nil)
        {
            txtemail.text = UserDefaults.standard.value(forKey:"email") as! String
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        IQKeyboardManager.sharedManager().enable = true

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

    func SendRequest()
    {
        if webservices().isConnectedToNetwork() == true
        {
            
            webservices().StartSpinner()
            
            Alamofire.request(webservices().baseurl + "contact_detail", method: .post, parameters:["name":txtname.text!,"email":txtemail.text,"message":textview.text] , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    webservices().StopSpinner()
                    
                    if let data = response.result.value{
                        
                        let dic: NSDictionary = response.result.value as! NSDictionary
                        
                        if(dic.value(forKey: "error_code") as! Int == 0)
                        {
                            self.txtemail.text = ""
                            self.txtname.text = ""
                            self.textview.text = ""


                            let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Thank you for connecting with us we will shortly get back to you.")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
