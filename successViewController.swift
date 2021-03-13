//
//  successViewController.swift
//  iZotSnoozeTM
//
//  Created by Kayla Hoang on 3/8/21.
//

import UIKit

class successViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backToLogintapped(_ sender: Any) {
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc,animated:true)
    }
    
}
