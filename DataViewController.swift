//
//  DataViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 2/15/21.
//

import Foundation
import UIKit
import CoreData

class DataViewController: UIViewController {
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var SleepTime: UIDatePicker!
    @IBOutlet weak var WakeTime: UIDatePicker!
    @IBOutlet weak var MoodDecimal: UISlider!
    @IBOutlet weak var NoiseAmbianceDecimal: UISlider!
    @IBOutlet weak var BreathRateInput: UITextField!
    @IBOutlet weak var HeartrateInput: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        DateCalendarPicker(_: "")

    }
    @IBAction func DateCalendarPicker(_ sender: Any) {
        DatePicker.maximumDate = Date()
        }
    
    @IBAction func BackToVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BackToGraph(_ sender: Any) {
        //CORE DATA SETUP
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SleepData", in: context)
        let newSleepData = NSManagedObject(entity: entity!, insertInto: context) 
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SleepData")

        // DATE + DAY OF WEEK
        let dateFormatter = DateFormatter()
        let dayOfWeek = DateFormatter()
        dateFormatter.dateFormat = "YYYY MM dd"
        dayOfWeek.dateFormat = "E"
        let dayOfWeekString = dayOfWeek.string(from: DatePicker.date)
        let dateString = dateFormatter.string(from: DatePicker.date)
        
        // DELETING ANY DUPLICATE DAYS
        request.predicate = NSPredicate(format: "date = %@", dateString)
        do {
            let objects = try context.fetch(request)
                for object in objects {
                    context.delete(object as! NSManagedObject)
                }
            
            try context.save()
        } catch {
           print("Failed saving")
        }
        
        print("\n\tDate: ", dateString)
        newSleepData.setValue(dateString, forKey: "date")
        newSleepData.setValue(dayOfWeekString, forKey: "dayOfWeek")
        
        
        // SLEEP TIME string: HH:mm (24hour format)
        let sleepFormatter = DateFormatter()
        sleepFormatter.dateFormat = "HH:mm"
        let sleepString = sleepFormatter.string(from: SleepTime.date)
        print("\tSleep Time: ", sleepString)
        newSleepData.setValue(sleepString, forKey: "sleep")
        
        // WAKE TIME
        let wakeFormatter = DateFormatter()
        wakeFormatter.dateFormat = "HH:mm"
        let wakeString = wakeFormatter.string(from: WakeTime.date)
        print("\tWake Up Time: ", wakeString)
        newSleepData.setValue(wakeString, forKey: "wake")
        
        // TIME SLEPT IN SECONDS
        func getDateDiff(start: Date, end: Date) -> Int  {
            let diffComponents = Calendar.current.dateComponents([.second], from: start, to: end)
            let seconds = diffComponents.second
            if seconds! < 0 {
                return Int(seconds!) + 86400
            }
            return Int(seconds!)
        }
        let timeSlept = String(getDateDiff(start: SleepTime.date, end: WakeTime.date))
        print("\tTime Slept (in seconds): ",timeSlept)
        newSleepData.setValue(timeSlept, forKey: "timeSlept")
        
        // MOOD scale 0-10
        var moodRate = MoodDecimal.value
        moodRate = moodRate * 5
        print("\tMood (Scale 1-10): ", String(format: "%.1f", moodRate))
        newSleepData.setValue(String(format: "%.1f", moodRate), forKey: "mood")
        
        // NOISE AMBIANCE
        var noiseAmbiance = NoiseAmbianceDecimal.value
        noiseAmbiance = noiseAmbiance * 10
        print("\tNoise Ambiance (Scale 1-10): ", noiseAmbiance.rounded())
        newSleepData.setValue(String(noiseAmbiance.rounded()), forKey: "noise")
        
        
        // HEARTRATE
        let heartrate = String(HeartrateInput.text!)
        print("\tAverage Heartrate: ", heartrate, " BPM")
        if heartrate != "" {
            newSleepData.setValue(heartrate, forKey: "heartRate")
        } else {newSleepData.setValue("0", forKey: "heartRate")}
        
        // BREATHRATE
        let breathrate = String(BreathRateInput.text!)
        print("\tAverage Breath Rate: ", breathrate, " Breaths per minute")
        if breathrate != "" {
        newSleepData.setValue(breathrate, forKey: "breathRate") // getting breath rate
        } else {newSleepData.setValue("0", forKey: "breathRate")}
        
        // SAVING CORE DATA
        do {
            try context.save()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Failed saving")
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
}
