

//
//  SideMenuVc.swift
//  PlanMyTrip
//
//  Created by Ravi Dubey on 8/21/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import SDWebImage
class SideMenuVc: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var profileview: UIView!
    @IBOutlet weak var imguser: UIImageView!
    
    @IBOutlet var tapview: UITapGestureRecognizer!
    var sidemenuname = ["Profile" , "My Shortlists"]
    var cells = ["cell","cell1","cell2","cell3","cell4","cell5","cell6","cell7"]

    @IBOutlet weak var txtname: UILabel!
    
    
    
    @IBAction func TapViewAction(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       profileview.addGestureRecognizer(tapview)
        imguser.layer.borderWidth=1.0
        imguser.layer.masksToBounds = false
        imguser.layer.borderColor = UIColor.white.cgColor
        imguser.layer.cornerRadius = imguser.frame.size.height/2
        imguser.clipsToBounds = true
        
       revealViewController().rearViewRevealWidth = 258.0
        

    
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey:"name") != nil)
        {
            txtname.text = UserDefaults.standard.value(forKey:"name") as! String
            
        }
        if(UserDefaults.standard.object(forKey:"profilepic") != nil)
        {
            var str = UserDefaults.standard.value(forKey:"profilepic") as! String
            var url = "http://ignitiveit.com/cartlife/storage/app/" + str
            imguser.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "download-1"))

        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseidentifier =  cells[indexPath.row]
     tableView.tableFooterView = UIView()
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:reuseidentifier, for: indexPath)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        if(indexPath.row == 1)
        {
            // text to share
            let text = "See me on google maps :- https://www.google.com/maps?q=\(CurrentLoction.coordinate.latitude),\(CurrentLoction.coordinate.longitude)"
            
            // set up activity view controller
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        if(indexPath.row == 3)
        {
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            var navController = storyboard.instantiateViewController(withIdentifier: "ServiceProviderVC") as? ServiceProviderVC
            navController?.isfromsidemenu = 1
            revealViewController().pushFrontViewController(navController, animated: true)
            revealViewController().frontViewController = navController
            
        }
        if(indexPath.row == 7)
        {
        var refreshAlert = UIAlertController(title: "Logout", message: "Are you sure want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(nextViewController, animated: true)
         
            UserDefaults.standard.removeObject(forKey:"password")
            UserDefaults.standard.removeObject(forKey:"Token")
            UserDefaults.standard.removeObject(forKey:"userid")
            UserDefaults.standard.removeObject(forKey:"name")
            UserDefaults.standard.removeObject(forKey:"email")
            UserDefaults.standard.removeObject(forKey:"reg_type")
            UserDefaults.standard.removeObject(forKey:"profilepic")
            UserDefaults.standard.removeObject(forKey:"contact_number")


            UserDefaults.standard.synchronize()

        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
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

//
// MARK: - Section Header Delegate
//
