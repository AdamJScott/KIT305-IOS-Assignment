//
//  WeeksViewController.swift
//  assignment_two
//
//  Created by Swift Labourer on 11/5/21.
//


//TODO ADD STUDENT
//TODO DELETE STUDENT
//TODO GRADE STUDENT WITH HD DN CR PP NN
//TODO CHANGE GRADE SCHEMES THAT RESET GRADES
//TODO MOVEMENT TO WEEK REPORT
//TODO MOVEMENT TO STUDENT DETAILS


import UIKit
import Firebase
import FirebaseFirestoreSwift

class WeeksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var studentTable: UITableView!
    
    @IBOutlet var weekNumberLabel: UILabel!
    
    @IBOutlet weak var lastButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    var unit: Unit?
    var unitIndex: Int?
    
    var studentsInWeek = [Student]()//Holds the list of students found within current week
    var currentWeek = 1
    var WeekObjID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lastButton.isEnabled = false
        
        self.studentTable.delegate = self
        self.studentTable.dataSource = self
        // Do any additional setup after loading the view.
        
        //Populates the view
        let db = Firestore.firestore()
        let weekCollection = db.collection("units").document(unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: currentWeek).getDocuments()
        { (result, err) in
            if let err = err
            {
                print("error getting week: \(err)")
            }
            
            else{
                for document in result!.documents
                {
                    let conversionResult = Result{
                        try document.data(as: Week.self)
                    }
                    
                    switch conversionResult
                    {
                    case .success (let convertedDoc):
                        if var week = convertedDoc
                        {
                            week.id = document.documentID
                            self.WeekObjID = document.documentID
                            print("WeekID found: \(week.id)")
                            
                            let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(self.WeekObjID!).collection("students").getDocuments()
                            { (resultStu, err) in
                                if let err = err{
                                    print("Error getting student \(err)")
                                }
                                
                                else
                                {
                                    for document in resultStu!.documents
                                    {
                                        let conversionResultStu = Result{ try document.data(as: Student.self)}
                                        
                                        switch conversionResultStu
                                        {
                                        case .success(let conversionDoc):
                                            if let student = conversionDoc
                                            {
                                                print("Student found: \(student.studentName)")
                                                self.studentsInWeek.append(student)
                                            }
                                        
                                        case .failure(let error):
                                            print("Error getting student: \(error)")
                                        }
                                    }
                                    self.studentTable.reloadData()
                                }
                                
                            }
                            
                        }
                        
                    case .failure(let error):
                        print("error decoding the week: \(error)")
                    
                    }
                }
            }
            
        }
        
        
        
        
        if let displayUnit = unit{
            self.navigationItem.title = displayUnit.unitname
            
            weekNumberLabel.text = String(currentWeek)
            
        }

        
    }
    
    @IBAction func nextWeekPressed(_ sender: Any) {
        
        if (currentWeek < unit!.numberOfWeeks)
        {
            lastButton.isEnabled = false
            nextButton.isEnabled = false
            
            self.currentWeek += 1
            self.weekNumberLabel.text = String(currentWeek)
            
            studentsInWeek.removeAll()
            
            //Populates the view
            let db = Firestore.firestore()
            let weekCollection = db.collection("units").document(unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: currentWeek).getDocuments()
            { (result, err) in
                if let err = err
                {
                    print("error getting week: \(err)")
                }
                else{
                    for document in result!.documents
                    {
                        let conversionResult = Result{
                            try document.data(as: Week.self)
                        }
                        
                        switch conversionResult
                        {
                        case .success (let convertedDoc):
                            if var week = convertedDoc
                            {
                                week.id = document.documentID
                                self.WeekObjID = document.documentID
                                print("WeekID found: \(week.id)")
                                
                                let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(self.WeekObjID!).collection("students").getDocuments()
                                { (resultStu, err) in
                                    if let err = err{
                                        print("Error getting student \(err)")
                                    }
                                    
                                    else
                                    {
                                        for document in resultStu!.documents
                                        {
                                            let conversionResultStu = Result{ try document.data(as: Student.self)}
                                            
                                            switch conversionResultStu
                                            {
                                            case .success(let conversionDoc):
                                                if let student = conversionDoc
                                                {
                                                    print("Student found: \(student.studentName)")
                                                    self.studentsInWeek.append(student)
                                                }
                                            
                                            case .failure(let error):
                                                print("Error getting student: \(error)")
                                            }
                                        }
                                        self.studentTable.reloadData()
                                        
                                        self.lastButton.isEnabled = true
                                        
                                        if (self.currentWeek == self.unit!.numberOfWeeks){
                                            self.nextButton.isEnabled = false
                                        }
                                        else{
                                            self.nextButton.isEnabled = true
                                        }
                                    }
                                    
                                }
                                
                            }
                            case .failure(let error):
                            print("error decoding the week: \(error)")
                        
                        }
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func lastWeekPressed(_ sender: Any) {
        
        if (currentWeek != 1 ){
            
            lastButton.isEnabled = false
            nextButton.isEnabled = false
            
            self.currentWeek -= 1
            self.weekNumberLabel.text = String(currentWeek)
            studentsInWeek.removeAll()
            
            //Populates the view
            let db = Firestore.firestore()
            let weekCollection = db.collection("units").document(unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: currentWeek).getDocuments()
            { (result, err) in
                if let err = err
                {
                    print("error getting week: \(err)")
                }
                else{
                    for document in result!.documents
                    {
                        let conversionResult = Result{
                            try document.data(as: Week.self)
                        }
                        
                        switch conversionResult
                        {
                        case .success (let convertedDoc):
                            if var week = convertedDoc
                            {
                                week.id = document.documentID
                                self.WeekObjID = document.documentID
                                print("WeekID found: \(week.id)")
                                
                                let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(self.WeekObjID!).collection("students").getDocuments()
                                { (resultStu, err) in
                                    if let err = err{
                                        print("Error getting student \(err)")
                                    }
                                    
                                    else
                                    {
                                        for document in resultStu!.documents
                                        {
                                            let conversionResultStu = Result{ try document.data(as: Student.self)}
                                            
                                            switch conversionResultStu
                                            {
                                            case .success(let conversionDoc):
                                                if let student = conversionDoc
                                                {
                                                    print("Student found: \(student.studentName)")
                                                    self.studentsInWeek.append(student)
                                                }
                                            
                                            case .failure(let error):
                                                print("Error getting student: \(error)")
                                            }
                                        }
                                        self.studentTable.reloadData()
                                        
                                        self.nextButton.isEnabled = true
                                        
                                        if (self.currentWeek == 1){
                                            self.lastButton.isEnabled = false
                                        }
                                        else{
                                            self.lastButton.isEnabled = true
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            case .failure(let error):
                            print("error decoding the week: \(error)")
                        
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    
    
    @IBAction func sortChange(_ sender: UISegmentedControl) {
        
                switch (sender.selectedSegmentIndex) {
                case 0: studentsInWeek = studentsInWeek.sorted {$0.studentName < $1.studentName}
                case 1:
                    studentsInWeek = studentsInWeek.sorted{$0.studentName > $1.studentName}
                case 2: studentsInWeek = studentsInWeek.sorted{$0.grade > $1.grade}
                case 3:
                    studentsInWeek = studentsInWeek.sorted{$0.grade < $1.grade}
                default:
                    break
                }
        
                studentTable.reloadData()
    }
    

    @IBAction func addStudentPressed(_ sender: Any) {
        // stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        let addAlert = UIAlertController(title: "Add new student", message: "Enter student name and ID", preferredStyle: .alert)
        
        var textFieldName: UITextField?
        var textFieldID: UITextField?
        
        addAlert.addTextField{ (textFieldNameIn) in textFieldNameIn.placeholder = "Enter name here"; textFieldNameIn.returnKeyType = UIReturnKeyType.continue}
        addAlert.addTextField{ (textFieldIDIn) in textFieldIDIn.placeholder = "Enter id here"; textFieldIDIn.keyboardType = UIKeyboardType.numberPad; textFieldIDIn.returnKeyType = UIReturnKeyType.continue}
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak addAlert] (_) in
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak addAlert] (_) in
            textFieldName = (addAlert?.textFields![0])!
            textFieldID = (addAlert?.textFields![1])!
            
            //TODO CHECK IF ID IS PURELY A NUMBER
            let idNumber = Int((textFieldID?.text)!) ?? -1
            
            if (idNumber != -1){
                //If exists, dont add
                if (
                    (self.studentsInWeek.contains(where: { id in id.studentID == textFieldID?.text}))
                ){
                    print("ID exists")
                    //TODO Error, ID already exists
                }
                
                else if (textFieldName!.text!.isEmpty){
                    print("Name cannot be empty")
                }
                else if (textFieldID!.text!.isEmpty){
                    print("ID cannot be empty")
                }
                
                //If gotten here, it should be okay to add
                else{
                    
                    
                    print(textFieldName?.text!)
                    print(textFieldID?.text!)
                }
            }
            else{
                //TODO error, ID is not a number
                print("ID NUMBER IS NOT A NUMBER")
            }
            
            
            
            
        }))
        
        self.present(addAlert, animated: true, completion: nil)
    }
    
        
    @IBAction func deleteStudentPressed(_ sender: Any) {
    }
    
    
    @IBAction func emailReportPressed(_ sender: Any) {
    }
    
    
    
    
    // MARK: - Table view data source
    
    func tableView(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentsInWeek.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "au.edu.utas.ios.StudentCell", for: indexPath)
        
        
        let student = studentsInWeek[indexPath.row]
        
        if let studentCell = cell as? StudentUITableViewCell
        {
            studentCell.studentNameLabel.text = student.studentName
            studentCell.studentGradeField.text = student.grade
        }
        
        
        return cell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
