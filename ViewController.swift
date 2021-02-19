//
//  ViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 2/5/21.
//

import UIKit
import Charts

class ViewController: UIViewController, ChartViewDelegate, UINavigationControllerDelegate {
    
    var lineChart = LineChartView()
    var barChart = BarChartView()
    var pieChart = PieChartView()
    // dataArray -> user input [date, dayOfWeek, sleepTime, wakeTime, timeDiff in sec, mood]
    //var dataArray : [[String]] = [["YYYY MM dd", "E", "00:00", "00:00", "0", "0"]]
    var dataArray = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self
        pieChart.delegate = self
        lineChart.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setting up size and fram of charts
        barChart.frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: 250)
        pieChart.frame = CGRect(x:0, y:0, width: 300, height: 250)
        lineChart.frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: 250)
        barChart.center = CGPoint(x: 207, y: 350)
        pieChart.center = CGPoint(x: 250, y: 350)
        lineChart.center = CGPoint(x: 207, y: 380)
        self.navigationController?.isNavigationBarHidden = true
        // load default graphs upon opening
        ChangeSegControl(MultipleCharts.selectedSegmentIndex)
    }
    
// ******** UIKIT WIDGET OUTLETS TO MANIPULATE *******************************
    @IBOutlet weak var AnalysisData: UILabel!
    @IBOutlet weak var TableLabel: UILabel!
    @IBOutlet weak var MultipleCharts: UISegmentedControl!
    @IBOutlet weak var TodayDate: UILabel!
    @IBOutlet weak var MoonFillerForNoData: UIImageView!
    
    // get the current date and time
    let currentDateTime = Date()
    // get the user's calendar
    let userCalendar = Calendar.current
    
    

// ***************** SEG CONTROL SWITCH CASES *********************************
    @IBAction func ChangeSegControl(_ sender: Any) {
        
        let userCurrentDate = getuserFormattedDate()
        let dateInArr = checkDateinArr(str: userCurrentDate, arr: dataArray)

        switch MultipleCharts.selectedSegmentIndex {
            case 0: // "TODAY"
                dataArray.sort{($0[0] > $1[0])}
                // removing ad adding views
                updateDate(label: TodayDate, s: userCurrentDate)
                barChart.removeFromSuperview()
                lineChart.removeFromSuperview()
                LabelToDailyOverview(label:TableLabel)
                //removeLabel(label: TableLabel)
                removeImageView(image: MoonFillerForNoData)
                removeLabel(label: AnalysisData)
                
                if dataArray.count > 0{
                    let dataAvgToday:[String] = [dataArray[0][4], dataArray[0][5] , dataArray[0][6], dataArray[0][7], dataArray[0][8]]
                    showAnalysisToday(label: AnalysisData, dataAvgArr: dataAvgToday)}
                
                //#########################
                var entries = [ChartDataEntry]()

                if dateInArr {
                    if dataArray[0][0] == userCurrentDate || dateInArr {
                    let arrIndex = getIndexofDate(nestedArr: dataArray, strDate: userCurrentDate)
                    entries.append(ChartDataEntry(x: Double(0), y: Double(dataArray[arrIndex][4])!/60/60))
                    entries.append(ChartDataEntry(x: Double(1), y: (Double(24) - (Double(dataArray[arrIndex][4])!/60/60))))
                    
                    let set = PieChartDataSet(entries: entries)
                    set.colors = ChartColorTemplates.liberty()
                    
                    let data = PieChartData(dataSet: set)
                    pieChart.data = data
                    pieChart.data?.setValueFont(NSUIFont.systemFont(ofSize: 0))
                    pieChart.holeRadiusPercent = CGFloat(0)
                    pieChart.centerTextRadiusPercent = CGFloat(1)
                    pieChart.legend.entries = [LegendEntry(label: "SLEPT  ", form: .default, formSize: CGFloat(20), formLineWidth: CGFloat(30), formLineDashPhase: .nan, formLineDashLengths: .none, formColor: #colorLiteral(red: 0.812982142, green: 0.9734575152, blue: 0.9664494395, alpha: 1)), LegendEntry(label: "AWAKE  ", form: .default, formSize: CGFloat(20), formLineWidth: CGFloat(30), formLineDashPhase: .nan, formLineDashLengths: .none, formColor:#colorLiteral(red: 0.5796257854, green: 0.8301811218, blue: 0.8309018612, alpha: 1))]
                    pieChart.legend.yEntrySpace = CGFloat(10)
                    pieChart.legend.xEntrySpace = CGFloat(70)
                    pieChart.legend.form = Legend.Form(rawValue: 4)!
                    pieChart.legend.horizontalAlignment = Legend.HorizontalAlignment(rawValue: 0)!
                    pieChart.legend.verticalAlignment = Legend.VerticalAlignment(rawValue: 1)!
                    pieChart.legend.orientation = Legend.Orientation(rawValue: 1)!
                    pieChart.legend.textWidthMax = CGFloat(70)
                    pieChart.legend.font = NSUIFont.systemFont(ofSize: 12.0)
                    pieChart.legend.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    pieChart.transparentCircleColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
                    view.addSubview(pieChart)
                    }
        } else {
            promptAnalysisForNoData(str: "T O D A Y", label: AnalysisData)
            showImageView(image: MoonFillerForNoData)
            removeLabel(label: TableLabel)
            removeLabel(label: TodayDate)
        }
 // ---------------------------------------------------------------------------
            case 1: // "WEEK"
                // removing and adding views
                updateTableLabel(label: TableLabel)
                removeLabel(label: TodayDate)
                pieChart.removeFromSuperview()
                lineChart.removeFromSuperview()
                removeLabel(label: AnalysisData)
                removeImageView(image: MoonFillerForNoData)
                //########################
                var entries = [BarChartDataEntry]()
                dataArray.sort{($0[0] > $1[0])}
                if dataArray.count > 0 {
                if reformatToDate(strDate: dataArray[0][0]).isInNDays(sec: 604800){
                    var i = 0
                    for data in dataArray {
                        if entries.count < 7 {
                            entries.append(BarChartDataEntry(x: Double(i), y: Double(data[4])!/60/60))
                            i += 1
                        } else if entries.count == 7 {break}
                    }
                    loadBarGraph(entries: entries)
                }} else {
                    promptAnalysisForNoData(str: "T H I S   W E E K", label: AnalysisData)
                    showImageView(image: MoonFillerForNoData)
                    removeLabel(label: TableLabel)
                }
// ---------------------------------------------------------------------------------
            case 2: // "MONTH"
                let userCurrentDate = getuserFormattedDate()

                // removing and adding views
                removeLabel(label: TableLabel)
                barChart.removeFromSuperview()
                removeLabel(label: AnalysisData)
                pieChart.removeFromSuperview()
                updateMonth(label: TodayDate, s: userCurrentDate)
                removeImageView(image: MoonFillerForNoData)
                //########################
                if dataArray.count > 0{
                if reformatToDate(strDate: dataArray[0][0]).isInNDays(sec: 2678400) {
                    var entries = [ChartDataEntry]()
                    dataArray.sort{($0[0] < $1[0])}
                    // need to set x to == day of the month
                    // use calendar to sync and show based on user month
                    //if dataArray.count >= 30 {
                    var j = 0
                    var days = [String]()
                    
                    for i in 0..<dataArray.count {
                                if entries.count < 31 && (String(userCalendar.component(.month, from: currentDateTime)) == getMonth(strDate: dataArray[i][0])) {
                                entries.append(ChartDataEntry(x: Double(j), y: Double(dataArray[i][4])!/60/60))
                                j += 1
                                let lst = dataArray[i][0].split(separator: " ") // returns [2020, 02, 16]
                                let d = String(Int(lst[2])!)
                                days.append(d)
                            }
                    }
                    lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
                    //lineChart.xAxis.avoidFirstLastClippingEnabled = true
                    //lineChart.xAxis.setLabelCount(31, force: false)
                    loadlineGraph(entries: entries)
                }} else {
                    removeLabel(label: TableLabel)
                    promptAnalysisForNoData(str: "T H I S   M O N T H", label: AnalysisData)
                    showImageView(image: MoonFillerForNoData)
                    removeLabel(label: TodayDate)
                    }
                
                
// ------------------------------------------------------------------------------
        case 3: // "TIPS"
            removeLabel(label: TableLabel)
            removeLabel(label: TodayDate)
            pieChart.removeFromSuperview()
            lineChart.removeFromSuperview()
            barChart.removeFromSuperview()
            removeLabel(label: AnalysisData)
            removeImageView(image: MoonFillerForNoData)
        default:
            break
        }
    }
// ******************************************************************************
    
    @IBAction func AddData(_ sender: Any) {
        // function for the add data Button
        // can be used for sending data to DataViewControl
        // preloading month of default data
        addPastMonthDefault()
    }
    
// ########## HELPER FUNCTIONS IN CLASS ##########################################

    // functions for reducing switch-case/seg control screen changes for graphs
    func loadlineGraph(entries: Any){
        let set = LineChartDataSet(entries: (entries as! [ChartDataEntry]), label: nil)
        set.colors = ChartColorTemplates.liberty()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
        lineChart.legend.form = Legend.Form(rawValue: 0)!
        lineChart.xAxis.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        lineChart.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lineChart.xAxis.gridColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        lineChart.rightYAxisRenderer.axis?.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.leftAxis.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        lineChart.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lineChart.rightAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lineChart.data?.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        lineChart.doubleTapToZoomEnabled = false
        //lineChart.xAxis.granularity = 1
        //lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        view.addSubview(lineChart)}
    
    func loadBarGraph(entries: Any){
        let set = BarChartDataSet(entries: (entries as! [ChartDataEntry]), label: nil)
        set.colors = ChartColorTemplates.liberty()
        let data = BarChartData(dataSet: set)
        barChart.data = data
        barChart.legend.form = Legend.Form(rawValue: 0)!
        var days = [String]()
            for i in 0..<7 {
                let lst = dataArray[i][0].split(separator: " ") // returns [2020, 02, 16]
                let d = String(Int(lst[2])!), m = String(Int(lst[1])!)
                let tempStr = dataArray[i][1].uppercased() + "\n" + m + "/" + d
                days.append(tempStr)
            }
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
        barChart.xAxis.gridColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        barChart.xAxis.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        barChart.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        barChart.rightYAxisRenderer.axis?.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        barChart.leftAxis.axisLineColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
        barChart.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        barChart.rightAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        barChart.data?.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChart.doubleTapToZoomEnabled = false
        view.addSubview(barChart)
    }
    
    // for adding default data of user for the last 7 days to show on week graph
    func addPastMonthDefault(){
        var count = 0
        let last7Days = Date.getNDates(nDays: 30)
        var lst = [[Substring]]()
        for dates in last7Days {
            lst.append(dates.split(separator: "-")) //[["Thu", "2021 02 18"]]
            let inArr = checkDateinArr(str: String(lst[count][1]), arr: dataArray)
            if inArr != true {dataArray.append([String(lst[count][1]), String(lst[count][0]), "00:00", "00:00", "0", "0", "0", "0", "0"])}
            count += 1}
    }
        
    //formatting date to compare with user data
    func getuserFormattedDate() -> String{
        var currentDate = String(userCalendar.component(.year, from: currentDateTime)) + " "
        if String(userCalendar.component(.month, from: currentDateTime)).count == 1 {
            currentDate += "0" + String(userCalendar.component(.month, from: currentDateTime)) + " "
        } else {currentDate += String(userCalendar.component(.month, from: currentDateTime)) + " "}
        currentDate += String(userCalendar.component(.day, from: currentDateTime))
        return currentDate
        }
    
    
}// class closing bracket



//******************* HELPER FUNCTIONS NOT PART OF CLASS ********************
// converting date string from user input array to readable/formated date for label
func toTodayDate(str: String) -> String {
    let lst = str.split(separator: " ") // returns [2020, 02, 16]
    switch lst[1] {
        case "01": return "\tJ A N   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "02": return "\tF E B   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "03": return "\tM A R   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "04": return "\tA P R   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "05": return "\tM A Y   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "06": return "\tJ U N   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "07": return "\tJ U L   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "08": return "\tA U G   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "09": return "\tS E P   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "10": return "\tO C T   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "11": return "\tN O V   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        case "12": return "\tD E C   \((lst[2][0])) \(lst[2][1]) ,   \(lst[0][0]) \(lst[0][1]) \(lst[0][2]) \(lst[0][3])"
        default: return ""
    }
}

func toMonth(str: String) -> String {
    let lst = str.split(separator: " ") // returns [2020, 02, 16]
    switch lst[1] {
        case "01": return "J A N U A R Y"
        case "02": return "F E B R U A R Y"
        case "03": return "M A R C H"
        case "04": return "A P R I L"
        case "05": return "M A Y"
        case "06": return "J U N E"
        case "07": return "J U L Y"
        case "08": return "A U G U S T"
        case "09": return "S E P T E M B E R"
        case "10": return "O C T O B E R"
        case "11": return "N O V E M B E R"
        case "12": return "D E C E M B E R"
        default: return ""
        }
}

// ################ UIKIT WIDGET CONTROL FUNCTIONS ############################
// for making labels appear/disappear between different seg control cases

// Meant for TodayDate Label
func updateDate(label: UILabel!, s: String) {
    label.text = toTodayDate(str: s)
    label.font = UIFont(name: "Galvji", size: CGFloat(18))
    //label.font = UIFont.boldSystemFont(ofSize: 18)
    label.textAlignment = NSTextAlignment.left
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0.3979507089, green: 0.4957387447, blue: 0.563734591, alpha: 1)
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(285), width: CGFloat(414), height: CGFloat(29))
}
// Meant for TodayDate Label
func updateMonth(label: UILabel!, s: String) {
    label.text = "H O U R S   S L E P T   I N   " + toMonth(str: s)
    label.font = UIFont(name: "Galvji", size: CGFloat(18))
    label.textAlignment = NSTextAlignment.center
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(240), width: CGFloat(414), height: CGFloat(29))
}
// Meant for TableLabel in WEEK
func updateTableLabel(label: UILabel!){
    label.text = "H O U R S   S L E P T"
    label.font = UIFont(name: "Galvji", size: CGFloat(17))
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0.3979507089, green: 0.4957387447, blue: 0.563734591, alpha: 1)
    label.textAlignment = NSTextAlignment.center
    label.numberOfLines = 1
    label.frame = CGRect(x: CGFloat(187), y: CGFloat(477), width: CGFloat(227), height: CGFloat(31))
}

// for any label
func removeLabel(label: UILabel!){
    label.text = "  "
    label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
}
// for TableLabel
func LabelToDailyOverview(label:UILabel!){
    label.text = "\tO V E R V I E W"
    label.font = UIFont(name: "Galvji", size: CGFloat(17))
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
    label.textAlignment = NSTextAlignment.left
    label.numberOfLines = 1
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(616), width: CGFloat(210), height: CGFloat(31))
}
// for AnalysisData Label
func promptAnalysisForNoData(str: String, label: UILabel!){
    label.text = "N O    D A T A\nA V A L I A B L E\nF O R    \(str)"
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.font = UIFont(name: "Galvji", size: CGFloat(25))
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(508), width: CGFloat(414), height: CGFloat(277))
    label.numberOfLines = 3
    label.textAlignment = NSTextAlignment.center
    label.backgroundColor = #colorLiteral(red: 0.2185979784, green: 0.2874768376, blue: 0.3298596144, alpha: 1)
    //label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
}
// for AnalysisData Label in TODAY
    // dataAvgArr -> [timeslept in seconds, mood, noise, avg heartrate]
func showAnalysisToday(label: UILabel!, dataAvgArr:[String]){
    label.text =
        """
        \t TIME SLEPT:\t\t\t\t\t\t\t\(String(format: "%.1f", Float(dataAvgArr[0])!/60/60))  HRS
        \t MOOD (Scale 1-10):\t\t\t\t\t\(dataAvgArr[1])
        \t NOISE AMBIANCE (Scale 1-10):\t\t\(dataAvgArr[2])
        \t AVERAGE HEARTRATE:\t\t\t\t\(dataAvgArr[3])  BPM
        \t AVERAGE BREATH RATE: \t\t\t\(dataAvgArr[4])  BPM
        """
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.font = UIFont(name: "Avenir Next", size: CGFloat(17))
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(647), width: CGFloat(414), height: CGFloat(140))
    label.numberOfLines = 5
    label.textAlignment = NSTextAlignment.left
    label.backgroundColor = #colorLiteral(red: 0.2185979784, green: 0.2874768376, blue: 0.3298596144, alpha: 1)
}

// ********* FOR IMAGES ************
func showImageView(image: UIImageView!){
    image.isHidden = false
}

func removeImageView(image: UIImageView!){
    image.isHidden = true
}
// *********************************
// checking if string date is in arr
func checkDateinArr(str: String,arr:[[String]])->Bool{
    var dateInArr = false
    for entry in arr{
        if str == entry[0]{
            dateInArr = true
        }
    }
    return dateInArr
}
//################## DATE FORMATTING HELPERS ##################################
// changing string date back to date class object
func reformatToDate(strDate: String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy MM dd"
    let date = dateFormatter.date(from: strDate)!
    return date
}

// for comparing with user calendar month
func getMonth(strDate: String) -> String{
    let lst = strDate.split(separator: " ")
    return String(Int(lst[1])!)
}

        
        
// getting string of day of the week -> "Mon"
func getDayOfWeek(date:Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

// getting the index of the current date in data array
func getIndexofDate(nestedArr: [[String]], strDate: String) -> Int {
    var count = 0
    for list in nestedArr {
        if list[0] == strDate {return count}
        count += 1
    }
    return 0
}

//###################### BUILTIN CLASS EXTENSIONS #########################

// for indexing String
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

// for determining if date is within the past or future 7 days
extension Date {
    func isInNDays(sec: TimeInterval) -> Bool {
        let now = Date()
        let nextweek = Date().addingTimeInterval(sec)
        let lastweek = Date().addingTimeInterval(-sec)
        let futureRange = now...nextweek
        let pastRange = lastweek...now
        if futureRange.contains(self) || pastRange.contains(self){
            return true
        }
        return false
    }
}
// getting the past dates in string format to add to array for default values -> "Thu-2021 02 18"
extension Date {
    static func getNDates(nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())

        var arrDates = [String]()

        for _ in 1 ... nDays {
            // move back in time by one day:
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E-yyyy MM dd"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
        }
        return arrDates
    }
}

    
