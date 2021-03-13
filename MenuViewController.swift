import Foundation
import UIKit
import HealthKit

class MenuViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func showProfile(_ sender: Any) {
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc,animated:true)
    }
    
    @IBAction func exportAsCSV(_ sender: Any) {
        let mainVC = ViewController()
        
        let fileName = getDocumentsDirectory().appendingPathComponent("SleepData.csv")
        
        var csvText = "Date,Day of the Week,Time Slept,Time Woke,Time Slept in Seconds,Mood,Noise Ambiance,Heartrate,Breath Rate\n"

        for i in 0 ..< mainVC.dataArray.count {
            if (mainVC.dataArray[i][9] == "Y"){
                let newLine = "\(mainVC.dataArray[i][0]),\(mainVC.dataArray[i][1]),\(mainVC.dataArray[i][2]),\(mainVC.dataArray[i][3]),\(mainVC.dataArray[i][4]),\(mainVC.dataArray[i][5]),\(mainVC.dataArray[i][6]),\(mainVC.dataArray[i][7]),\(mainVC.dataArray[i][8])\n"
                    csvText.append(newLine)
            }
        }
        do {
            try csvText.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        let activity = UIActivityViewController(activityItems: [fileName], applicationActivities: nil)
            present(activity, animated: true)    }
    @IBAction func LinkAppleWatch(_ sender: Any) {
        let HKAssistant = HealthKitSetupAssistant()
        HKAssistant.authorizeHealthKit { (authorized, error) in
              
          guard authorized else {
                
            let baseMessage = "HealthKit Authorization Failed"
                
            if let error = error {
              print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
              print(baseMessage)
            }
                
            return
          }
              
          print("HealthKit Successfully Authorized.")
        }

    }
    @IBAction func ViewData(_ sender: Any) {
    }
    
    @IBAction func navigateToSettingsController(_ sender: Any) {
    }
    
    @IBAction func BackToVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "menu")
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated:true)
    }
}// closing class braket

// getting path
private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

