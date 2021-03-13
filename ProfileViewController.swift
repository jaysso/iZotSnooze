//
//  ProfileViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 3/2/21.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController : UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var nameDisplay: UILabel!
    @IBOutlet var ageDisplay: UILabel!
    @IBOutlet var weightDisplay: UILabel!
    @IBOutlet var heightDisplay: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadLabels()
    }
    
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "menu") 
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated:true)*/
    }
    
    @IBAction func editTapped(){
        let vc = storyboard?.instantiateViewController(identifier: "edit") as! editProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated:true)
    }
    /*func takePhoto(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.camera
            var mediaTypes: Array<AnyObject> = [UIImageAsset]
            picker.mediaTypes = mediaTypes
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else{
            NSLog("No Camera.")
        }
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
    }*/


func LoadLabels(){
    //CORE DATA SETUP
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
    
    // requesting all data
    request.predicate = NSPredicate(format: "firstName != %@", "")
    request.returnsObjectsAsFaults = false
    do {
        var name = "--------------------"
        var age = "--------------------"
        var weight = "--------------------"
        var height = "--------------------"
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            if data.value(forKey: "firstName") as! String != "" {
                name = data.value(forKey: "firstName") as! String + " "
                name += data.value(forKey: "lastName") as! String
            }
            if (data.value(forKey: "heightFeet") as! String != "") {
                height = data.value(forKey: "heightFeet") as! String + "\' "
                height += data.value(forKey: "heightInches") as! String + "\""
            }
            if data.value(forKey: "weight") as! String != "" {
                weight = data.value(forKey: "weight") as! String
            }
            if data.value(forKey: "age") as! String != ""{
                age = data.value(forKey: "age") as! String
            }
        }
        nameDisplay.text = name
        ageDisplay.text = age
        weightDisplay.text = weight
        heightDisplay.text = height
        
        } catch {
            
            print("Failed")
        }
}
}
