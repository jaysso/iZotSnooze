//
//  ViewController.swift
//  iZotSnooze
//
//  Created by Gerald Post  on 2/12/21.
//

import FSCalendar
import UIKit


class ViewController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var tableView: UITableView!
    let data = ["Hours Slept", "Mood"]
    let data2 = ["6.25", "8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    // TableView funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let string = data[indexPath.row] + ": " + data2[indexPath.row]
        cell.textLabel?.text = string
        
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-dd-MM"
        let string = formatter.string(from: date)
        print("\(string)")
    }

}

