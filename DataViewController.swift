//
//  DataViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 2/15/21.
//

import Foundation
import UIKit

class DataViewController: UIViewController {
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var SleepTime: UIDatePicker!
    @IBOutlet weak var WakeTime: UIDatePicker!
    @IBOutlet weak var MoodDecimal: UISlider!
    @IBOutlet weak var NoiseAmbianceDecimal: UISlider!
    @IBOutlet weak var BreathRateInput: UITextField!
    @IBOutlet weak var HeartrateInput: UITextField!
    
    
    
    @IBAction func BRInputBox(_ sender: Any) {
        
    }
    @IBAction func HBInputBox(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        DateCalendarPicker(_: "")
    }
    @IBAction func DateCalendarPicker(_ sender: Any) {
        DatePicker.maximumDate = Date()
    }
    
    @IBAction func BackToGraph(_ sender: Any) {
        // SHOULD MAKE A CLASS LOL
        // getting date in a string
        let dateFormatter = DateFormatter()
        let dayOfWeek = DateFormatter()
        dateFormatter.dateFormat = "YYYY MM dd"
        dayOfWeek.dateFormat = "E"
        let dayOfWeekString = dayOfWeek.string(from: DatePicker.date)
        let dateString = dateFormatter.string(from: DatePicker.date)
        print("\n\tDate: ", dateString)
        
        // getting sleep time to a string: HH:mm (24hour format)
        let sleepFormatter = DateFormatter()
        sleepFormatter.dateFormat = "HH:mm"
        let sleepString = sleepFormatter.string(from: SleepTime.date)
        print("\tSleep Time: ", sleepString)

        // getting wake time
        let wakeFormatter = DateFormatter()
        wakeFormatter.dateFormat = "HH:mm"
        let wakeString = wakeFormatter.string(from: WakeTime.date)
        print("\tWake Up Time: ", wakeString)
        
        // func for getting time slept
        func getDateDiff(start: Date, end: Date) -> Int  {
            let diffComponents = Calendar.current.dateComponents([.second], from: start, to: end)
            let seconds = diffComponents.second
            if seconds! < 0 {
                return Int(seconds!) + 86400
            }
            return Int(seconds!)
        }
        
        // time slept
        let timeSlept = String(getDateDiff(start: SleepTime.date, end: WakeTime.date))
        print("\tTime Slept (in seconds): ",timeSlept)
        
        // geting mood scale 0-10
        var moodRate = MoodDecimal.value
        moodRate = moodRate * 10
        print("\tMood (Scale 1-10): ", String(format: "%.1f", moodRate))
        
        // getting noise ambiance
        var noiseAmbiance = NoiseAmbianceDecimal.value
        noiseAmbiance = noiseAmbiance * 10
        print("\tNoise Ambiance (Scale 1-10): ", noiseAmbiance.rounded())
        
        // getting heartrate
        let heartrate = String(HeartrateInput.text!)
        print("\tAverage Heartrate: ", heartrate, " BPM")
        
        // getting breath rate
        let breathrate = String(BreathRateInput.text!)
        print("\tAverage Breath Rate: ", breathrate, " Breaths per minute")
        
        // array to append to dataArray
        // dateString, dayOfWeekString, and timeslept must remain in same index
        // add heartBeat, Noise ambiance
        let tempArray: [String] = [dateString, dayOfWeekString, sleepString, wakeString, timeSlept, String(format: "%.1f", moodRate), String(format: "%.1f", noiseAmbiance), heartrate, breathrate]
        
        // using navigation controller to prevent data from being erased
        let mainVC = navigationController?.viewControllers.first as? ViewController
        var inArray = false
        var count = -1
        if mainVC?.dataArray != [] {
            for data in mainVC!.dataArray {
                count += 1
                    if data[0] == tempArray[0] {
                    mainVC?.dataArray.remove(at: count)
                    mainVC?.dataArray.insert(tempArray, at: count)
                    inArray = true
                    break
                
                }
            }
        }
        if inArray != true {
            mainVC?.dataArray.append(tempArray)
            mainVC?.dataArray.sort{($0[0] > $1[0])}
            print("User Data:")
            for arr in mainVC!.dataArray {
                print(arr)
            }
            print("\n")
        }
        mainVC?.ChangeSegControl(mainVC?.MultipleCharts.selectedSegmentIndex as Any)
        navigationController?.popViewController(animated: true)
        // should have function to update charts after entering data
        
        
        
    }
    
}
