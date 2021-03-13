//
//  loginViewController.swift
//  iZotSnoozeTM
//
//  Created by Kayla Hoang on 3/8/21.
//

import UIKit
import FirebaseAuth

class loginViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginTapped(_ sender: Any) {
        validateFields()
    }
    
    func validateFields(){
        // validates if user enters both fields
        if email.text?.isEmpty == true {
            print("Email missing")
            return
        }
        if password.text?.isEmpty == true {
            print("password missing")
            return
        }
        login()
    }
    
    func login(){
        //unwrap to prevent crashing
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] aResult, err in
            //print(aResult)
            guard self != nil else{return}
            if let err = err {
                print(err.localizedDescription)
            }
            //if login successfull then checks information
            self!.checkInfo()
        }
    }
    
    func checkInfo(){
        //checks user info after logging in
        //verify if therte's a current user and print id if so
        if Auth.auth().currentUser != nil {
            //UserDefaults.standard.set(value)
            let sb = UIStoryboard(name: "Main",bundle:nil)
            let vc = sb.instantiateViewController(withIdentifier: "menu")
            vc.modalPresentationStyle = .overFullScreen
            present(vc,animated:true)
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        //create account nvigate to signup screen
        let sb = UIStoryboard(name: "Main",bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "sign")
        vc.modalPresentationStyle = .overFullScreen
        present(vc,animated:true)
    }
    
}
