//
//  ViewController.swift
//  iZotSnooze
//
//  Created by Gerald Post  on 2/12/21.
//

import FSCalendar
import UIKit


class CalendarDataController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {

    var dateSelected = ""
    var dayOfWeekSelected = ""

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    let titleArray = [
        "Date:\t\t\t\t\t",
        "Day of the Week:\t\t",
        "Time Slept:\t\t\t\t",
        "Time Woke:\t\t\t\t",
        "Time Slept:\t\t\t\t",
        "Mood:\t\t\t\t\t",
        "Noise Ambiance:\t\t",
        "Average Heartrate:\t\t",
        "Average Breath Rate:\t"]
    let unitsArray = ["", "", "", "", " seconds", "", "", " beats per minute", " breaths per minute"]
    var dayData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        let formatter = DateFormatter()
        let dayOfWeekFormatter = DateFormatter()
        formatter.dateFormat = "YYYY MM dd"
        dayOfWeekFormatter.dateFormat = "E"
        dayOfWeekSelected = dayOfWeekFormatter.string(from: Date())
        dateSelected = formatter.string(from: Date())
        getDateDate(date: dateSelected, day: dayOfWeekSelected)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func BackToMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "menu")
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated:true)*/
    }
    // TableView funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let string = titleArray[indexPath.row] + dayData[indexPath.row] + unitsArray[indexPath.row]
        cell.textLabel?.text = string
        cell.textLabel?.font = UIFont(name: "Galvji", size: CGFloat(14))
        return cell
    }
    
    func getDateDate(date:String, day: String){
        let mainVC = ViewController()
        mainVC.updateDataArray()
        dayData = [date, day,"--:--", "--:--", "-", "-", "-", "-", "-","N"]
        for i in 0..<mainVC.dataArray.count {
            if ((date == mainVC.dataArray[i][0]) && (mainVC.dataArray[i][9] == "Y")){
                dayData = mainVC.dataArray[i]
            }
        }
    }
    
    // calendar is not appearing :(
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        let dayOfWeekFormatter = DateFormatter()
        formatter.dateFormat = "YYYY MM dd"
        dayOfWeekFormatter.dateFormat = "E"
        let day = dayOfWeekFormatter.string(from: date)
        let string = formatter.string(from: date)
        
        // for getting the day's data from the nested array
        dateSelected = "\(string)"
        dayOfWeekSelected = "\(day)"
        print("User viewing Data from: ", dateSelected)
        getDateDate(date: dateSelected, day: dayOfWeekSelected)
        tableView.reloadData()
    }
}

