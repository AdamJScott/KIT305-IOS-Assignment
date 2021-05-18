//
//  ReportWeekViewController.swift
//  assignment_two
//
//  Created by Swift Labourer on 18/5/21.
//

import UIKit

class ReportWeekViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var reportTable: UITableView!
    
    @IBOutlet var weekTitle: UILabel!
    
    @IBOutlet var gradeAveLabel: UILabel!
    
    @IBOutlet var attendedLabel: UILabel!
    
    var studentReport = [String]()
    
    var gradeAverage: String!
    var attendence: String!
    var weekNum: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reportTable.delegate = self
        self.reportTable.dataSource = self
        self.reportTable.reloadData()

        weekTitle.text = "Report for Week: \(String(weekNum))"
        gradeAveLabel.text = gradeAverage
        attendedLabel.text = attendence
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        
        var string = studentReport.joined(separator: "\n")
        
        UIPasteboard.general.string = string
            
        print("Clipboard: \(UIPasteboard.general.string ?? "No information")")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //COMPLETE
    func tableView(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //COMPLETE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentReport.count
    }

    //COMPLETE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "au.edu.utas.ios.reportCell", for: indexPath)
        
        
        var line = studentReport[indexPath.row]
        
        if let studentCell = cell as? ReportUITableCellTableViewCell
        {
            studentCell.cellText.text = line
        }
        
        
        return cell
    }
    
    
}

