//
//  TipsVC.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import Alamofire
class TipsVC: UIViewController {
    @IBAction func back(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetTips()
        webservices.sharedInstance.setShadow(view: mainview)

        // Do any additional setup after loading the view.
    }
    
    func GetTips()
    {
        if webservices().isConnectedToNetwork() == true
        {
            webservices().StartSpinner()
            Alamofire.request(webservices().baseurl + "privacypolicy", method: .post, parameters:nil , encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    let dic : NSDictionary = response.result.value! as! NSDictionary
                    
                    let Description = (dic.value(forKey:"data") as! NSDictionary).value(forKey:"description") as! String
                    let htmlCode = Description
                    self.webview.loadHTMLString(htmlCode, baseURL: nil)

                    webservices().StopSpinner()
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
