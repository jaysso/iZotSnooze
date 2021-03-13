//
//  signUpViewController.swift
//  iZotSnoozeTM
//
//  Created by Kayla Hoang on 3/8/21.
//

import UIKit
import Firebase
import FirebaseAuth


class signUpViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        //verify user type in email and password fields
        if email.text?.isEmpty == true{
            print("email missing")
            return
        }
        if password.text?.isEmpty == true{
            print("password missing")
            return
        }
        authenticate()
    }
    
    @IBAction func backToLoginTapped(_ sender: Any) {
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc,animated:true)
    }
    
    func authenticate(){
        //Send information and pass word to firebase
        
        //unwrapped here in case it doesn't contain any text
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (aResult, error) in
            // add completetion handler to verify success; check if user entered if not prints error to console
            guard let _ = aResult?.user,error == nil else{
                print("error \(String(describing: error?.localizedDescription))")
                return
            }
                // if successful, goes to success screen
                let storyb = UIStoryboard(name: "Main", bundle: nil)
                let viewc = storyb.instantiateViewController(withIdentifier: "success")
                viewc.modalPresentationStyle = .overFullScreen
                self.present(viewc,animated:true)// self used here cuz it's outside fcn
        }
    }
}

