//
//  SettingsViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 3/2/21.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func BackToMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "menu")
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated:true)*/
    }
}
