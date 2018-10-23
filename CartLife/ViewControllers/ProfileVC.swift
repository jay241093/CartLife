//
//  ProfileVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/23/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
class ProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate , UITextFieldDelegate {
    @IBOutlet weak var txtname: UITextField!
    @IBOutlet weak var txtmobilenumber: UITextField!
    @IBOutlet weak var imguser: UIImageView!
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var innerview: UIView!
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func UpdateAction(_ sender: Any) {
        UpdateProfile()
    }
  
    @IBAction func tapaction(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
   func UpdateProfile()
   {
    webservices().StartSpinner()
    var parameters : Parameters = [:]
    if(txtname.text != "" && txtmobilenumber.text != "")
    {
        parameters = [
            "user_id" :UserDefaults.standard.value(forKey: "userid") as! Int,
            "username":txtname.text!,
            "contact_number" : txtmobilenumber.text!
        ]
        
    }
    
    else if(txtname.text != "")
    {
       parameters = [
            "user_id" :UserDefaults.standard.value(forKey: "userid") as! Int,
            "username":txtname.text!]
        
    }
    else if(txtmobilenumber.text != "")
    {     parameters = [
        "user_id" :UserDefaults.standard.value(forKey: "userid") as! Int,
        "contact_number" : txtmobilenumber.text!]
    
    }
    
    let imgData = UIImageJPEGRepresentation(imguser.image!,1)
    
    
    
    Alamofire.upload(
        multipartFormData: { MultipartFormData in
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            MultipartFormData.append(imgData!, withName: "profile_pic", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
            
            
    }, to: webservices().baseurl+"updateprofile") { (result) in
        
        switch result {
        case .success(let upload, _, _):
            
            upload.responseJSON { response in
                print(response.result.value!)
                
                let dic : NSDictionary = response.result.value! as! NSDictionary
                
                if(dic.value(forKey:"error_code") as! Int == 0)
                    
                {
                    webservices().StopSpinner()
                    let newdic =  dic.value(forKey:"data") as! NSDictionary
                    
                    UserDefaults.standard.set(newdic.value(forKey: "profile_pic") as! String, forKey:"profilepic")
                    UserDefaults.standard.set(newdic.value(forKey: "contact_number") as! String, forKey:"contact_number")
                    UserDefaults.standard.set(newdic.value(forKey: "name") as! String, forKey: "name")
                    UserDefaults.standard.synchronize()
                    
                    let alert = webservices.sharedInstance.AlertBuilder(title:"", message:dic.value(forKey:"message") as! String)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                    
                {
                    let alert = webservices.sharedInstance.AlertBuilder(title:"", message:dic.value(forKey:"message") as! String)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
                
                
                
     webservices().StopSpinner()
                
            }
            
        case .failure(let encodingError): break
        print(encodingError)
     webservices().StopSpinner()
        let alert = webservices.sharedInstance.AlertBuilder(title:"", message:"Unble to update please try again")
        self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    }
    //MARK:- imagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imguser.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:-User define functions
    
    func camera()
    {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.allowsEditing = true
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func photoLibrary()
    {
        
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.allowsEditing = true
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        txtmobilenumber.delegate = self
        imguser.layer.borderWidth=1.0
        imguser.layer.masksToBounds = false
        imguser.layer.borderColor = UIColor.white.cgColor
        imguser.layer.cornerRadius = imguser.frame.size.height/2
        imguser.clipsToBounds = true
        imguser.addGestureRecognizer(tap)
        webservices.sharedInstance.PaddingTextfiled(textfield: txtname)
        webservices.sharedInstance.PaddingTextfiled(textfield: txtmobilenumber)
        if(UserDefaults.standard.object(forKey:"name") != nil)
        {
            txtname.text = UserDefaults.standard.value(forKey:"name") as! String
        }
        if(UserDefaults.standard.object(forKey:"contact_number") != nil)
        {
            txtmobilenumber.text = UserDefaults.standard.value(forKey:"contact_number") as! String
        }
        if(UserDefaults.standard.object(forKey:"profilepic") != nil)
        {
            var str = UserDefaults.standard.value(forKey:"profilepic") as! String
            var url = "http://ignitiveit.com/cartlife/storage/app/" + str
            imguser.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "download-1"))
            
        }
        webservices.sharedInstance.setShadow(view: innerview)

        // Do any additional setup after loading the view.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txtmobilenumber)
        {
        let maxLength = 12
            let currentString: NSString = textField.text as! NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        }
        else
        {
         return true
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
