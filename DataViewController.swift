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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        print("Date: ", dateString)
        
        // getting sleep time to a string: HH:mm (24hour format)
        let sleepFormatter = DateFormatter()
        sleepFormatter.dateFormat = "HH:mm"
        let sleepString = sleepFormatter.string(from: SleepTime.date)
        print("Sleep Time: ", sleepString)
        
        // getting wake time
        let wakeFormatter = DateFormatter()
        wakeFormatter.dateFormat = "HH:mm"
        let wakeString = wakeFormatter.string(from: WakeTime.date)
        print("Wake Up Time: ", wakeString)
        
        // geting mood scale 0-100
        var moodRate = MoodDecimal.value
        moodRate = moodRate * 10
        print("Mood: ", moodRate)
        
        let tempArray: [String] = [dateString, dayOfWeekString, sleepString, wakeString, moodRate.description]
        
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
            mainVC?.dataArray.sort{($0[0] < $1[0])}
        }
        navigationController?.popViewController(animated: true)
        
        
        
        
    }
    
}
