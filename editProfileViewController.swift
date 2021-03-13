//
//  editProfileViewController.swift
//  iZotSnoozeTM
//
//  Created by Kayla Hoang on 3/8/21.
//

import UIKit
import CoreData

class editProfileViewController: UIViewController {

    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var Age: UITextField!
    @IBOutlet weak var Weight: UITextField!
    @IBOutlet weak var HeightFeet: UITextField!
    @IBOutlet weak var HeightInches: UITextField!
    
    
    /*
    var nameText = String()
    public var completionHandler: ((String?,String?,String?,String?) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = nameText
        // Do any additional setup after loading the view.
    }
    */
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveTapped(){
        //create property that the first view controller can find; calls fcn before dismissing
       // completionHandler?(nameField.text,ageField.text,weightField.text,heightField.text)
        
        //CORE DATA SETUP
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserProfile", in: context)
        let newProfile = NSManagedObject(entity: entity!, insertInto: context)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
        // deleting previous user info
        do {
            newProfile.setValue(FirstName.text, forKey: "firstName")
            newProfile.setValue(LastName.text, forKey: "lastName")
            newProfile.setValue(Age.text, forKey: "age")
            newProfile.setValue(Weight.text, forKey: "weight")
            newProfile.setValue(HeightFeet.text, forKey: "heightFeet")
            newProfile.setValue(HeightInches.text, forKey: "heightInches")
            
            try context.save()
            self.dismiss(animated: true, completion: nil)

        } catch {
            print("Failed saving")
            self.dismiss(animated: true, completion: nil)

        }
    }
}
