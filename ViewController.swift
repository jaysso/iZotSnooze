//
//  ViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 2/5/21.
//

import UIKit

class ViewController: UIViewController {
    
    var dataArray = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func AddData(_ sender: Any) {
        print("\nUser Data:")
        for arr in dataArray {
            print(arr)
        }
        print("\n")
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC : SecondViewController = segue.destination as! SecondViewController
           destVC.dataFromFirst = "Hello there!"
    }*/
}

