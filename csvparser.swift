/* csvparser.swift
 * Originally by Jens Meder:
 */

import Foundation

class csvparser {
    func readCSVData(name: String, exten: String) -> [[String]] {
        var dataArray : [[String]] = []
        let path = Bundle.main.path(forResource: name, ofType: exten)
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let content = String(data: data, encoding: .utf8)
            let parsedCSV = content?.components(separatedBy: "\r\n").map{ $0.components(separatedBy: ",") }
            for line in parsedCSV! {
                dataArray.append(line)
            }
        }
        catch let jsonErr {
            print("Error read CSV file: \n", jsonErr)
        }
        var sumSleep = 0
        var sumTired = 0
        var count = 0
        for value in dataArray{
            if value[0] == "Yes"{
                count = count + 1
                sumSleep += (value[1] as NSString).integerValue
                sumTired += (value[4] as NSString).integerValue
            }
        }
        let avgSleep = Double(sumSleep) / Double(count)
        let avgTired = Double(sumTired) / Double(count)
        print("From College Student Sleep Study:")
        print("\tAverage Hours Slept: ", avgSleep)
        print("\tAverage Tiredness: ", avgTired)
        print("\tNumber of Students: ", count)
        return dataArray
    }
    
    func stripSleepData(dataArray: [[String]]) -> [[Float]] {
        var newData : [[Float]] = [[],[]] //First is hours. Second is mood.
        for value in dataArray{
            if let sleepVal = Float(value[4]) {
                newData[0].append(sleepVal)
            } else {
                print("Error, not a Float")
            }
            if let moodVal = Float(value[1]) {
                newData[1].append(moodVal)
            } else {
                print("Error, not a Float")
            }
        }
        return newData
    }
}
