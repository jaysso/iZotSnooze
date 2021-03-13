//
//  ViewController.swift
//  iZotSnoozeTM
//
//  Created by Jasmine Som on 2/5/21.
//

import UIKit
import Charts
import CoreData


class ViewController: UIViewController, ChartViewDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var lineChart = LineChartView()
    var barChart = BarChartView()
    var pieChart = PieChartView()
    var linRegChart = LineChartView()
    var hasData = false
    // dataArray -> user input [date, dayOfWeek, sleepTime, wakeTime, timeDiff in sec, mood, noise ambiance, heart rate, breath reat, user input]
    //var dataArray : [[String]] = [["YYYY MM dd", "E", "00:00", "00:00", "0", "0", "Y"/"N" for user input("N" == default data)]]
    var dataArray = [[String]]()
    var tappedCell = [Int]()
    // pull all user personal recommendations from a larger array
    var recommendationArr:[String] = RecommendationString().SleepRec() // just for viewing
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self
        pieChart.delegate = self
        lineChart.delegate = self
        linRegChart.delegate = self
        RecommendationTable.delegate = self
        RecommendationTable.dataSource = self
        updateDataArray()
        /* GENERATING CSV DATA ARRAY */
        //Consider storing sleepstudydata + relevant
        //  data in core, so we don't have to do this again
        
        // Slope + y-int to coredata under study data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let parser = csvparser()
        let testData = parser.readCSVData(name: "SleepStudyData",exten: "csv")
        let sleepData = parser.stripSleepData(dataArray: testData)
        let algo = RecommendationAlgorithm()
        let sleepRegLine = algo.linearRegression(sleepData[0], sleepData[1])
        let entity1 = NSEntityDescription.entity(forEntityName: "StudyData", in: context)
        let newSleepData1 = NSManagedObject(entity: entity1!, insertInto: context)
        newSleepData1.setValue(sleepRegLine.1, forKey: "timeSleepRegSlope")
        newSleepData1.setValue(sleepRegLine.0, forKey: "timeSleepRegY")
        /* END CSV DATA GENERATION */
        
        // SAVING CORE DATA
        do {
            try context.save()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Failed saving")
            self.dismiss(animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setting up size and fram of charts
        barChart.frame = CGRect(x:0, y:0, width: self.view.frame.size.width-20, height: 250)
        pieChart.frame = CGRect(x:0, y:0, width: 300, height: 250)
        lineChart.frame = CGRect(x:0, y:0, width: self.view.frame.size.width-20, height: 250)
        linRegChart.frame = CGRect(x:0, y:50, width: self.view.frame.size.width-20, height: 200)
        barChart.center = CGPoint(x: 207, y: 380)
        pieChart.center = CGPoint(x: 265, y: 350)
        lineChart.center = CGPoint(x: 207, y: 380)
        linRegChart.center = CGPoint(x: 207, y: 380)
        self.navigationController?.isNavigationBarHidden = true
        // load default graphs upon opening
        ChangeSegControl(MultipleCharts.selectedSegmentIndex)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChangeSegControl(MultipleCharts.selectedSegmentIndex)
        
        
    }
    
    
    //Creates dictionary of user % difference from test data in the form of [Attribute : % Diff]
    func diffDicts() -> [String:Double] {
        var results = [String:Double]()

        let weekAvgsArr = getAverages(days: 7)
        let monthAvgsArr = getAverages(days: 30)


        results["avgBreathRateMonth"] = percentDiff(diff: Double(monthAvgsArr[6])!, testVal: 16.0)
        results["avgBreathRateWeek"] = percentDiff(diff: Double(weekAvgsArr[6])!, testVal: 16.0)
        //Heart
        results["avgHeartRateMonth"] = percentDiff(diff: Double(monthAvgsArr[5])!, testVal: 70.0)
        results["avgHeartRateWeek"] = percentDiff(diff: Double(weekAvgsArr[5])!, testVal: 70.0)
        //Sleep
        
        results["avgSleepTimeMonth"] = percentDiff(diff: Double(monthAvgsArr[2])!, testVal: 28800.0)
        results["avgSleepTimeWeek"] = percentDiff(diff: Double(weekAvgsArr[2])!, testVal: 28800.0)
        //Noise
  
        results["avgNoiseMonth"] = percentDiff(diff: Double(monthAvgsArr[4])!, testVal: 4.0)
        results["avgNoiseWeek"] = percentDiff(diff: Double(monthAvgsArr[4])!, testVal: 4.0)
     
        return results
    }
    
    
    
// ******** UIKIT WIDGET OUTLETS TO MANIPULATE *******************************
    @IBOutlet weak var AnalysisData: UILabel!
    @IBOutlet weak var TableLabel: UILabel!
    @IBOutlet weak var MultipleCharts: UISegmentedControl!
    @IBOutlet weak var TodayDate: UILabel!
    @IBOutlet weak var MoonFillerForNoData: UIImageView!
    @IBOutlet weak var TipsDeleteButton: UIButton!
    @IBOutlet weak var AnalysisData2: UILabel!
    
    @IBOutlet weak var RecommendationTable: UITableView!
    
    // get the current date and time
    let currentDateTime = Date()
    // get the user's calendar
    let userCalendar = Calendar.current
    
    

// ***************** SEG CONTROL SWITCH CASES *********************************
    @IBAction func ChangeSegControl(_ sender: Any) {
        let userCurrentDate = getuserFormattedDate()
        let dateInArr = checkDateinArr(str: userCurrentDate, arr: dataArray)
        updateDataArray()

        switch MultipleCharts.selectedSegmentIndex {
            case 0: // "TODAY"
                
                // removing ad adding views
                RecommendationTable.isHidden = true
                TipsDeleteButton.isHidden = true
                dataArray.sort{($0[0] > $1[0])}
                TodayDate.isHidden = false
                updateDate(label: TodayDate, s: userCurrentDate)
                barChart.removeFromSuperview()
                lineChart.removeFromSuperview()
                linRegChart.removeFromSuperview()
                TableLabel.isHidden = false
                LabelToDailyOverview(label:TableLabel)
                MoonFillerForNoData.isHidden = true
                // ###########################
                if dataArray.count > 0{
                    let dataAvgToday:[String] = [dataArray[0][2], dataArray[0][3], dataArray[0][4], dataArray[0][5] , dataArray[0][6], dataArray[0][7], dataArray[0][8]]
                    AnalysisData.isHidden = false
                    AnalysisData2.isHidden = false
                    showAnalysisToday(avgText: "", label: AnalysisData, label2: AnalysisData2, dataAvgArr: dataAvgToday)}
                
                // creating graph
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
                promptAnalysisForNoData(str: "F O R    T O D A Y", type: "D A T A", label: AnalysisData)
                AnalysisData.isHidden = false
                AnalysisData2.isHidden = true
                MoonFillerForNoData.isHidden = false
                TableLabel.isHidden = true
                TodayDate.isHidden = true
         }
 // ---------------------------------------------------------------------------
            case 1: // "WEEK"
                // removing and adding views
                TableLabel.isHidden = false
                updateTableLabel(label: TableLabel, str: "H O U R S   S L E P T", size: 18)
                // calculate an average for last 7 days here for dataAvgArr
                let avgsArr = getAverages(days: 7)
                showAnalysisToday(avgText: " AVERAGE", label: AnalysisData, label2: AnalysisData2, dataAvgArr: avgsArr)
                AnalysisData2.isHidden = false
                TipsDeleteButton.isHidden = true
                TodayDate.isHidden = false
                pieChart.removeFromSuperview()
                lineChart.removeFromSuperview()
                linRegChart.removeFromSuperview()
                LabelToDailyOverview(label:TodayDate)
                AnalysisData.isHidden = false
                MoonFillerForNoData.isHidden = true
                RecommendationTable.isHidden = true
                //########################
                var entries = [BarChartDataEntry]()
                if dataArray.count > 0 {
                    addPastMonthDefault()
                    dataArray.sort{($0[0] > $1[0])}
                    var i = 0
                    for data in dataArray {
                        if entries.count < 7 {
                            entries.insert(BarChartDataEntry(x: Double(6-i), y: Double(data[4])!/60/60), at: 0)
                            i += 1
                        } else if entries.count == 7 {break}
                    }
                    let set = BarChartDataSet(entries: (entries as [ChartDataEntry]), label: nil)
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
                    days.reverse()
                    barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
                    barChart.xAxis.gridColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    barChart.xAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    barChart.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    barChart.rightYAxisRenderer.axis?.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    barChart.leftAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    barChart.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    barChart.rightAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    barChart.data?.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                    barChart.xAxis.granularity = 1
                    barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
                    barChart.doubleTapToZoomEnabled = false
                    barChart.rightYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                    barChart.leftYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                    view.addSubview(barChart)
                } else {
                    promptAnalysisForNoData(str: "F O R    T H I S   W E E K", type: "D A T A", label: AnalysisData)
                    AnalysisData.isHidden = false
                    MoonFillerForNoData.isHidden = false
                    TableLabel.isHidden = true
                    TodayDate.isHidden = true
                    AnalysisData2.isHidden = true
                 }
// ---------------------------------------------------------------------------------
            case 2: // "MONTH"
                // removing and adding views
                RecommendationTable.isHidden = true
                TodayDate.isHidden = false
                barChart.removeFromSuperview()
                AnalysisData.isHidden = false
                AnalysisData2.isHidden = false
                pieChart.removeFromSuperview()
                linRegChart.removeFromSuperview()
                LabelToDailyOverview(label:TodayDate)
                TableLabel.isHidden = false
                updateTableLabel(label: TableLabel, str: "H O U R S   S L E P T", size: 18)
                let avgsArr = getAverages(days: 30)
                showAnalysisToday(avgText: " AVERAGE", label: AnalysisData, label2: AnalysisData2, dataAvgArr: avgsArr)
                TipsDeleteButton.isHidden = true
                MoonFillerForNoData.isHidden = true
                //########################
                if dataArray.count > 0{
                    addPastMonthDefault()
                    var entries = [ChartDataEntry]()
                    dataArray.sort{($0[0] < $1[0])}
                    // need to set x to == day of the month
                    // use calendar to sync and show based on user month
                    var j = 0
                    var days = [String]()
                    
                    for i in 0..<dataArray.count {
                                if entries.count < 31 { //&& (String(userCalendar.component(.month, from: currentDateTime)) == getMonth(strDate: dataArray[i][0]))
                                entries.append(ChartDataEntry(x: Double(j), y: Double(dataArray[i][4])!/60/60))
                                j += 1
                                let lst = dataArray[i][0].split(separator: " ") // returns [2020, 02, 16]
                                let d = String(Int(lst[2])!), m = String(Int(lst[1])!)
                                let tempStr = m + "/" + d
                                days.append(tempStr)
                            }
                    }
                    lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
                    let set = LineChartDataSet(entries: (entries ), label: nil)
                    set.colors = ChartColorTemplates.liberty()
                    set.circleColors = [NSUIColor(cgColor: CGColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)))]
                    let data = LineChartData(dataSet: set)
                    lineChart.data = data
                    lineChart.legend.form = Legend.Form(rawValue: 0)!
                    lineChart.xAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    lineChart.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    lineChart.xAxis.gridColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    lineChart.rightYAxisRenderer.axis?.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
                    lineChart.leftAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    lineChart.rightYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                    lineChart.leftYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                    lineChart.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    lineChart.rightAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    lineChart.data?.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                    lineChart.doubleTapToZoomEnabled = false
                    view.addSubview(lineChart)
                } else {
                    TableLabel.isHidden = true
                    TodayDate.isHidden = true
                    AnalysisData.isHidden = false
                    AnalysisData2.isHidden = true
                    MoonFillerForNoData.isHidden = false
                    promptAnalysisForNoData(str: "F O R    T H I S   M O N T H", type: "D A T A", label: AnalysisData)
                 }
                                    
                
// ------------------------------------------------------------------------------
        case 3: // "TIPS"
            //###################### Start of nwe Matt code
            addPastMonthDefault()
            //storeTestAverages()
            var recDict = diffDicts()
            print("DIFFDICTS: ",recDict)
            let weights = ["avgBreathRateMonth": 0.1, // Weights should sum to 1.0
                           "avgBreathRateWeek": 0.1,
                           "avgHeartRateMonth": 0.2,
                           "avgHeartRateWeek": 0.2,
                           "avgSleepTimeMonth": 0.4,
                           "avgSleepTimeWeek": 0.4,
                           "avgNoiseMonth": 0.3,
                           "avgNoiseWeek": 0.3      ]
            let recObject = RecommendationString()
            let breathRec = recObject.OrderRecommendations(attribute: 3, difference: recDict["avgBreathRateWeek"]!)
            let heartRec = recObject.OrderRecommendations(attribute: 2, difference: recDict["avgHeartRateWeek"]!)
            let noiseRec = recObject.OrderRecommendations(attribute: 1, difference: recDict["avgNoiseWeek"]!)
            let sleepRec = recObject.OrderRecommendations(attribute: 0, difference: recDict["avgSleepTimeWeek"]!)
            
            recommendationArr = []
            recommendationArr += breathRec + heartRec + noiseRec + sleepRec
            recDict = weightedDifferences(differences: recDict, weights: weights)
            if recommendationArr == [] {
                recommendationArr = ["Your snooze is looking amazing!"]
            }
            
            tappedCell = [] // reset when switching and not deleting
            // need to reset recommmendationArr after every data input
            TableLabel.isHidden = true
            AnalysisData.isHidden = true
            AnalysisData2.isHidden = true
            TodayDate.isHidden = true
            pieChart.removeFromSuperview()
            lineChart.removeFromSuperview()
            barChart.removeFromSuperview()
            MoonFillerForNoData.isHidden = true
            
            if dataArray.count > 0{
            RecommendationTable.isHidden = false
            RecommendationTable.reloadData()
            TableLabel.isHidden = false
            updateTableLabel(label: TableLabel, str: "W E E K L Y   R E C O M M E N D A T I O N S", size: 18)
            updateTableLabel(label: TodayDate, str: "T I R E D N E S S   V S .   H O U R S   S L E P T", size: 12)
            TodayDate.frame = CGRect(x: CGFloat(0), y: CGFloat(260), width: CGFloat(414), height: CGFloat(29))
            TipsDeleteButton.isHidden = false
            TodayDate.isHidden = false
            dataArray.sort{($0[0] > $1[0])}
            // for chart
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StudyData")
                
                // requesting all data
                //request.predicate = NSPredicate(format: "timeSleepRegY != %@", "")
                request.returnsObjectsAsFaults = false
                var yintercept = Float()
                var slope = Float()
                do {
                    let result = try context.fetch(request)
                    for data in result as! [NSManagedObject] {
                        yintercept = data.value(forKey: "timeSleepRegY") as! Float
                        slope = data.value(forKey: "timeSleepRegSlope") as! Float
                    }
                }catch {
                        print("Failed.")
                    }

                var entries = [ChartDataEntry]()
                for i in 0...5 {
                    entries.append(ChartDataEntry(x: Double(i), y: Double(((Float(i)*slope) + yintercept))))
                }
                let set = LineChartDataSet(entries: (entries ), label: nil)
                set.colors = ChartColorTemplates.liberty()
                set.circleColors = [NSUIColor(cgColor: CGColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)))]
                linRegChart.legend.form = Legend.Form(rawValue: 0)!
                linRegChart.xAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                linRegChart.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                linRegChart.xAxis.gridColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                linRegChart.rightYAxisRenderer.axis?.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                linRegChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
                linRegChart.leftAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                linRegChart.rightYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                linRegChart.leftYAxisRenderer.axis?.labelFont = NSUIFont.systemFont(ofSize: 0.0)
                linRegChart.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                linRegChart.rightAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                linRegChart.doubleTapToZoomEnabled = false
                var entries1 = [ChartDataEntry]()
                let monthAvg = getAverages(days: 30)
                entries1.append(ChartDataEntry(x: Double(monthAvg[3])!, y: (Double(monthAvg[2])!/60/60)))
                let set1 = LineChartDataSet(entries: (entries1 ), label: nil)
                set1.circleColors = [NSUIColor(cgColor: CGColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)))]
                set1.circleHoleColor = NSUIColor(cgColor: CGColor(#colorLiteral(red: 0.6395524144, green: 0.9021550417, blue: 0.9264529347, alpha: 1)))
                set1.circleHoleRadius = CGFloat(5)
                let data = LineChartData(dataSets: [set, set1])
                linRegChart.data = data
                linRegChart.data?.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                view.addSubview(linRegChart)
                
            } else {
            AnalysisData.isHidden = false
            AnalysisData2.isHidden = true
            promptAnalysisForNoData(str: "", type: "\nR E C O M M E N D A T I O N S", label: AnalysisData)
            MoonFillerForNoData.isHidden = false
            }
// ------------------------------------------------------------------------------
        default:
            break
        }
    }

    // ******************************************************************************
       // tips table functions
        // MARK: - Table View delegate methods
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return self.recommendationArr.count
        }
        
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        // Set the spacing between sections
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return CGFloat(10)
        }
    // Make the background color show through
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
        
        // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tips", for: indexPath)

            // note that indexPath.section is used rather than indexPath.row
            cell.textLabel?.text = recommendationArr[indexPath.section]
            
            // add border and color
            cell.backgroundColor = #colorLiteral(red: 0.2581759989, green: 0.306661427, blue: 0.3450263143, alpha: 1)
            //cell.TipsTableLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Galvji", size: CGFloat(15))
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.layer.borderColor = UIColor.white.cgColor
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5
            cell.clipsToBounds = true
            cell.textLabel?.tag = indexPath.row
            cell.textLabel?.sizeToFit()
            return cell
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let height:CGFloat = estimatedHeightOfLabel(text: recommendationArr[indexPath.section])
        return height + 50
    }

    func estimatedHeightOfLabel(text: String) -> CGFloat {
        let size = CGSize(width: 400, height: 2000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Galvji", size: CGFloat(15))]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        return rectangleHeight
    }

     
    // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // note that indexPath.section is used rather than indexPath.row
            tappedCell.append(Int(indexPath.section))
            }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        for i in 0..<tappedCell.count{
            if (Int(indexPath.section) == tappedCell[i]){
                tappedCell.remove(at: i)
                break
            }
        }
    }
    
        
    
    @IBAction func DeleteTipTableRow(_ sender: Any) {
        if tappedCell.count > 0{
            tappedCell.sort(by: >)
            for i in 0..<tappedCell.count{
                recommendationArr.remove(at: tappedCell[i])
            }
            RecommendationTable.reloadData()
            tappedCell = []
            }
        
    }
    
// ******************************************************************************

    @IBAction func AddData(_ sender: Any) {}
    
    
    
    // ########## HELPER FUNCTIONS IN CLASS ##########################################
    // can make into a class
    
    // for adding default data of user for the last 7 days to show on week graph
    func addPastMonthDefault(){
        var count = 0
        let lastNDays = Date.getNDates(nDays: 30)
        var lst = [[Substring]]()
        for dates in lastNDays {
            lst.append(dates.split(separator: "-")) //[["Thu", "2021 02 18"]]
            let inArr = checkDateinArr(str: String(lst[count][1]), arr: dataArray)
            if !inArr {dataArray.append([String(lst[count][1]), String(lst[count][0]), "00:00", "00:00", "0", "0", "0", "0", "0","N"])}
            count += 1}
    }
        
    //formatting date to compare with user data
    func getuserFormattedDate() -> String{
        var currentDate = String(userCalendar.component(.year, from: currentDateTime)) + " "
        if String(userCalendar.component(.month, from: currentDateTime)).count == 1 {
            currentDate += "0" + String(userCalendar.component(.month, from: currentDateTime)) + " "
        } else {currentDate += String(userCalendar.component(.month, from: currentDateTime)) + " "}
        if String(userCalendar.component(.day, from: currentDateTime)).count == 1 {
            currentDate += "0" + String(userCalendar.component(.day, from: currentDateTime))
        } else {currentDate += String(userCalendar.component(.day, from: currentDateTime))}
        return currentDate
        }
    
    func updateDataArray(){
        // getting core data into data array - each function will sort depending on needs of graph
        //CORE DATA SETUP
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SleepData")
        
        // requesting all data
        request.predicate = NSPredicate(format: "timeSlept > %@", "-1")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                dataArray.sort{($0[0] > $1[0])}
                if dataArray.count <= 31{
                if !checkDateinArr(str: (data.value(forKey: "date") as! String), arr: dataArray){
                    dataArray.append([data.value(forKey: "date") as! String, data.value(forKey: "dayOfWeek") as! String, data.value(forKey: "sleep") as! String, data.value(forKey: "wake") as! String, data.value(forKey: "timeSlept") as! String, data.value(forKey: "mood") as! String, data.value(forKey: "noise") as! String, data.value(forKey: "heartRate") as! String, data.value(forKey: "breathRate") as! String, "Y"])
                    hasData = true
                } else {
                        dataArray.remove(at: getIndexofDate(nestedArr: dataArray, strDate: (data.value(forKey: "date") as! String)))
                        dataArray.append([data.value(forKey: "date") as! String, data.value(forKey: "dayOfWeek") as! String, data.value(forKey: "sleep") as! String, data.value(forKey: "wake") as! String, data.value(forKey: "timeSlept") as! String, data.value(forKey: "mood") as! String, data.value(forKey: "noise") as! String, data.value(forKey: "heartRate") as! String, data.value(forKey: "breathRate") as! String, "Y"])
                        hasData = true
                    }
            } else {
                dataArray.remove(at: getIndexofDate(nestedArr: dataArray, strDate: (data.value(forKey: "date") as! String)))
                dataArray.append([data.value(forKey: "date") as! String, data.value(forKey: "dayOfWeek") as! String, data.value(forKey: "sleep") as! String, data.value(forKey: "wake") as! String, data.value(forKey: "timeSlept") as! String, data.value(forKey: "mood") as! String, data.value(forKey: "noise") as! String, data.value(forKey: "heartRate") as! String, data.value(forKey: "breathRate") as! String, "Y"])
                hasData = true
                }
            }
            
        } catch {
            
            print("Failed")
        }
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
// Meant for TableLabel Label
func updateTableLabel(label: UILabel!, str: String, size: Int) {
    label.text = str
    label.font = UIFont(name: "Galvji", size: CGFloat(size))
    label.textAlignment = NSTextAlignment.center
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(240), width: CGFloat(414), height: CGFloat(29))
}
// for TableLabel
func LabelToDailyOverview(label:UILabel!){
    label.text = "\tO V E R V I E W"
    label.font = UIFont(name: "Galvji", size: CGFloat(25))
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 1)
    label.textAlignment = NSTextAlignment.left
    label.numberOfLines = 1
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(510), width: CGFloat(210), height: CGFloat(31))
}
// for AnalysisData Label
func promptAnalysisForNoData(str: String, type: String, label: UILabel!){
    label.text = "N O    \(type)\nA V A L I A B L E\n\(str)"
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.font = UIFont(name: "Galvji", size: CGFloat(25))
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(508), width: CGFloat(414), height: CGFloat(277))
    label.numberOfLines = 3
    label.textAlignment = NSTextAlignment.center
    label.backgroundColor = #colorLiteral(red: 0.2729828358, green: 0.3263296783, blue: 0.3689593077, alpha: 0)
    
}
// for AnalysisData Label in TODAY
    // dataAvgArr -> [timeslept in seconds, mood, noise, avg heartrate]
func showAnalysisToday(avgText: String, label: UILabel!,label2: UILabel!, dataAvgArr:[String]){
    // should have data in another label align left, fix later
    label.text =
        """
        \t \(avgText) TIME SLEPT:

        \t \(avgText) TIME WOKE:

        \t \(avgText) HOURS SLEPT:

        \t \(avgText) TIREDNESS (Scale 1-5):

        \t \(avgText) NOISE AMBIANCE (Scale 1-10):

        \t  AVERAGE HEARTRATE:

        \t  AVERAGE BREATH RATE:
        """
    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label.font = UIFont(name: "Galvji", size: CGFloat(15))
    label.frame = CGRect(x: CGFloat(0), y: CGFloat(515), width: CGFloat(414), height: CGFloat(300))
    label.numberOfLines = 0
    label.textAlignment = NSTextAlignment.left
    label.backgroundColor = #colorLiteral(red: 0.2185979784, green: 0.2874768376, blue: 0.3298596144, alpha: 0)
    label2.text =
        """
        \(dataAvgArr[0])

        \(dataAvgArr[1])

        \(String(format: "%.1f", Float(dataAvgArr[2])!/60/60)) HRS

        \(dataAvgArr[3])

        \(dataAvgArr[4])

        \(dataAvgArr[5]) BPM

        \(dataAvgArr[6]) BPM
        """
    label2.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    label2.font = UIFont(name: "Galvji", size: CGFloat(15))
    label2.frame = CGRect(x: CGFloat(0), y: CGFloat(515), width: CGFloat(380), height: CGFloat(300))
    label2.numberOfLines = 0
    label2.textAlignment = NSTextAlignment.right
    label2.backgroundColor = #colorLiteral(red: 0.2185979784, green: 0.2874768376, blue: 0.3298596144, alpha: 0)
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
        

// getting the index of the current date in data array
func getIndexofDate(nestedArr: [[String]], strDate: String) -> Int {
    var count = 0
    for list in nestedArr {
        if list[0] == strDate {return count}
        count += 1
    }
    return 0
}

func getAverages(days: Int) -> [String]{
    // declaring vars for calculating avgs
    var avgArray = [String]()
    var hoursSlept = 0.0
    var mood = 0.0
    var noise = 0.0
    var hr = 0.0
    var br = 0.0
    var counter : Int = 0
    var wokeHr = 0.0
    var wokeMin = 0.0
    var sleepHr = 0.0
    var sleepMin = 0.0
    
    // set up for getting CoreData entitites
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SleepData")
    
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
    var count: Int = 0
    do{
        count = try context.count(for: request)
    }
    catch{
        print("Failed")
    }
    
    if (count < days)
    {
        request.fetchLimit = count
    }
    else
    {
        request.fetchLimit = days
    }
    
    request.returnsObjectsAsFaults = false
    
    do {
        let lastNDays = Date.getNDates(nDays: days)
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            
            if data.value(forKey: "date") != nil
            {
                let date = reformatToDate(strDate: data.value(forKey: "date") as! String)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E-yyyy MM dd"
                let dateString = dateFormatter.string(from: date)
                let currdate = dateFormatter.string(from:Date())
                
                if ((lastNDays.contains(dateString)) || dateString == currdate)
                {
                    counter += 1
                    let timeWoke = (data.value(forKey: "wake") as! String).split(separator: ":")
                    let Sleeptime = (data.value(forKey: "sleep") as! String).split(separator: ":")
                    sleepHr += Double(Sleeptime[0])!
                    sleepMin += Double(Sleeptime[1])!
                    wokeHr += Double(timeWoke[0])!
                    wokeMin += Double(timeWoke[1])!
                    hoursSlept += Double(data.value(forKey: "timeSlept") as! String) ?? 0.0
                    mood += Double(data.value(forKey: "mood") as! String) ?? 0.0
                    noise += Double(data.value(forKey: "noise") as! String) ?? 0.0
                    hr += Double(data.value(forKey: "heartRate") as! String) ?? 0.0
                    br += Double(data.value(forKey: "breathRate") as! String) ?? 0.0
                }
            }
    }
        
    }catch {
            print("Failed.")
        }
    
    if (count > days)
    {
        counter = days
    }
    sleepHr /= Double(counter)
    sleepMin /= Double(counter)
    wokeHr /= Double(counter)
    wokeMin /= Double(counter)
    hoursSlept /= Double(counter)
    mood /= Double(counter)
    noise /= Double(counter)
    hr /= Double(counter)
    br /= Double(counter)
    
    let sleeptime = formatStrDate(dble: sleepHr) + ":" + formatStrDate(dble: sleepMin)
    let waketime = formatStrDate(dble: wokeHr) + ":" + formatStrDate(dble: wokeMin)
    avgArray.append(sleeptime)
    avgArray.append(waketime)
    avgArray.append(String(hoursSlept))
    avgArray.append(String(format: "%.1f", mood))
    avgArray.append(String(format: "%.1f", noise))
    avgArray.append(String(format: "%.1f", hr))
    avgArray.append(String(format: "%.1f", br))
    
    return avgArray
}


func formatStrDate(dble: Double) -> String{
    if dble < 10{
        return "0" + String(Int(dble.rounded()))
    }
    return String(Int(dble.rounded()))
}
//###################### BUILTIN CLASS EXTENSIONS #########################

// for indexing String
extension StringProtocol {
    subscript(offset: Int) -> String {
        String(self[index(startIndex, offsetBy: offset)])
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
