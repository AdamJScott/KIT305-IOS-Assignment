//
//  WeeksViewController.swift
//  assignment_two
//
//  Created by Adam Scott on 11/5/21.
//





import UIKit
import Firebase
import FirebaseFirestoreSwift

class WeeksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var studentTable: UITableView!
    
    @IBOutlet var weekNumberLabel: UILabel!
    
    @IBOutlet var markScheme: UILabel!
    
    @IBOutlet weak var lastButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var searchText: UITextField!
    
    var hd_Gradelist = ["UG", "NN", "PP", "CR", "DN", "HD"]
    var a_Gradelist = ["UG","F","D","C","B","A"]
    var attendance = ["Present", "Not present"]
    var chk_Gradelist = [String]()
    
    var unitSummary = [String]()
    
    var unit: Unit?
    var unitIndex: Int?
    
    var studentsInWeek = [Student]()//Holds the list of students found within current week
    
    var oldListStudent = [Student]()//Holds a copy of studentsInWeek
    
    var currentWeek = 1
    var WeekObjID: String!
    var gradeStyle: String!
    var firstCall = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lastButton.isEnabled = false
        
        self.studentTable.delegate = self
        self.studentTable.dataSource = self
        // Do any additional setup after loading the view.
        
        //Populates the view
        fetchDatabaseCall()
        
        if let displayUnit = unit{
            self.navigationItem.title = displayUnit.unitname
            
            weekNumberLabel.text = String(currentWeek)
        }

        
    }
    
    func confirmAlert(title: String, message: String) -> UIAlertController {
     
        let alert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
    
        alert.addAction(ok)
    
        return alert
    }
    
    func fetchDatabaseCall(){
        self.studentsInWeek.removeAll()
        
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
                            self.gradeStyle = week.gradeScheme
                            
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
                                            if var student = conversionDoc
                                            {
                                                student.doc_id = document.documentID
                                                //print("Student found: \(student.studentName)")
                                                self.studentsInWeek.append(student)
                                            }
                                            
                                            
                                            
                                        
                                        case .failure(let error):
                                            print("Error getting student: \(error)")
                                        }
                                    }
                                    
                                    //Sets the buttons
                                    self.studentTable.reloadData()
                                    
                                    var str = self.gradeStyle
                                    //check for chk
                                    if (self.gradeStyle.count >= 4){
                                        
                                        var strPrefix = String(self.gradeStyle!.prefix(3)).uppercased()
                                        if (strPrefix == "CHK"){
                                            str = "chk"
                                        }
                                    }
                                    switch (str){
                                        case "hd":
                                            str = "HD"
                                            break
                                        case "a":
                                            str = "A"
                                            break
                                        case "chk":
                                            str = "Checkpoints"
                                            break
                                        case "att":
                                            str = "Attendance"
                                            break
                                        case "num":
                                            str = "Numeric"
                                            break
                                        default:
                                            str = "None"
                                            break
                                    }
                                        
                                    
                                    self.markScheme.text = "Scheme: \(str ?? "none")"
                                    
                                    if (self.currentWeek == self.unit!.numberOfWeeks){
                                        self.nextButton.isEnabled = false
                                    }else{
                                        self.nextButton.isEnabled = true
                                    }
                                    
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
        
        if (firstCall == false){
        firstCall = true
        self.unitSummary.removeAll()
        
        //unitSummary.append("Unit summary all weeks for: \(unit!.unitname ?? "")")
        //unitSummary.append("Week, Grade Average Week, Grade Average Numeric, Attendence Rate")
            
        
       
            db.collection("units").document(unit!.id).collection("weeks").getDocuments(){ (result, err) in
                
                if let err = err
                {
                    print("error getting week: \(err)")
                }
                else
                {
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
                                var studentInner = [Student]()
                               
                                
                                let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").getDocuments()
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
                                                if var student = conversionDoc
                                                {
                                                    student.doc_id = document.documentID
                                                    //print("Student found: \(student.studentName)")
                                                    studentInner.append(student)
                                                    
                                                    
                                                }
                                                
                                            
                                            case .failure(let error):
                                                print("Error getting student: \(error)")
                                            }
                                        }
                                        //print("Getting info")
                                        //get information and append to the string array
                                        
                                        self.unitSummary.append("\(week.weekNumber), \(self.averageWeek(students: studentInner)), \(self.gradeToNumeric(grade: self.averageWeek(students: studentInner), gradeStyle: week.gradeScheme))/100, \(self.attendenceWeek(students: studentInner, gradeStyle: week.gradeScheme))% ")
                                        
                                       // print("\(week.weekNumber), \(self.averageWeek(students: studentInner)), \(self.attendenceWeek(students: studentInner, gradeStyle: week.gradeScheme)) ")
                                        
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
    
    func changeMarkSchemeDatabaseCall(){
        
        let db = Firestore.firestore()
        
        db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).updateData(["gradeScheme": self.gradeStyle])
        //print("GradeStyle: \(gradeStyle)")
        
        for i in 0...(self.studentsInWeek.count-1) {
            let curStu = db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).collection("students").document(self.studentsInWeek[i].doc_id!).updateData(["grade":"UG"])
            
            
            if (i == self.studentsInWeek.count-1){
                fetchDatabaseCall()
                self.studentTable.reloadData()
                self.markScheme.text = "Scheme: \(self.gradeStyle ?? "none")"
            }
        }
    }
    
    //COMPLETE
    @IBAction func nextWeekPressed(_ sender: Any) {
        
        searchText.text = ""
        
        if (currentWeek < unit!.numberOfWeeks)
        {
            lastButton.isEnabled = false
            nextButton.isEnabled = false
            
            self.currentWeek += 1
            self.weekNumberLabel.text = String(currentWeek)
            
            studentsInWeek.removeAll()
            
            //Populates the view
            fetchDatabaseCall()
        }
    }
    
    //COMPLETE
    @IBAction func lastWeekPressed(_ sender: Any) {
        
        searchText.text = ""
        
        if (currentWeek != 1 ){
            
            lastButton.isEnabled = false
            nextButton.isEnabled = false
            
            self.currentWeek -= 1
            self.weekNumberLabel.text = String(currentWeek)
            studentsInWeek.removeAll()
            
            //Populates the view
            fetchDatabaseCall()
        }
    }
    
    //COMPLETE
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

    //COMPLETE
    @IBAction func addStudentPressed(_ sender: Any) {
        // stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        let addAlert = UIAlertController(title: "Add new student", message: "Enter student name and ID", preferredStyle: .alert)
        
        var textFieldName: UITextField?
        var textFieldID: UITextField?
        
        addAlert.addTextField{ (textFieldNameIn) in textFieldNameIn.placeholder = "Enter name here"; textFieldNameIn.returnKeyType = UIReturnKeyType.continue}
        addAlert.addTextField{ (textFieldIDIn) in textFieldIDIn.placeholder = "Enter ID here"; textFieldIDIn.keyboardType = UIKeyboardType.numberPad; textFieldIDIn.returnKeyType = UIReturnKeyType.continue}
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak addAlert] (_) in
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [self, weak addAlert] (_) in
            textFieldName = (addAlert?.textFields![0])!
            textFieldID = (addAlert?.textFields![1])!
            
           
            let idNumber = Int((textFieldID?.text)!) ?? -1
            
            if (idNumber != -1)
            {
                //If exists, dont add
                if (
                    (self.studentsInWeek.contains(where: { id in id.studentID == textFieldID?.text}))
                ){
                    print("ID exists")
                    
                    self.present(confirmAlert(title: "Error", message: "ID exists in week"), animated: true, completion: nil)
                }
                
                else if (textFieldName!.text!.isEmpty){
                    self.present(confirmAlert(title: "Error", message: "Name cannot be empty"), animated: true, completion: nil)
                }
                else if (textFieldID!.text!.isEmpty){
                    self.present(confirmAlert(title: "Error", message: "ID cannot be empty"), animated: true, completion: nil)
                }
                
            
                
                //If gotten here, it should be okay to add
                else{
                    
                    //Create the student
                    var newStu = Student(attended: false, doc_id: "", grade: "UG", studentID: (textFieldID?.text)!, studentName: (textFieldName?.text)!)
                    
                    let db = Firestore.firestore()

                    for n in self.currentWeek...Int(self.unit!.numberOfWeeks)
                    {
                        //ADD EACH WEEK
                        //print("Adding to \(n)")
                        let weekCollection = db.collection("units").document(unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: n).getDocuments()
                        { (result, err) in
                            if let err = err
                            {
                                print("error getting week: \(err)")
                            }
                            else
                            {
                                for document in result!.documents
                                {
                                    let conversionResult = Result{
                                        try document.data(as: Week.self)
                                    }
                                        
                                    switch conversionResult
                                    {
                                        case .success (let convertedDoc):
                                            if var week = convertedDoc{
                                                //Found week to add to
                                                
                                                week.id = document.documentID
                                                
                                                do {
                                                    let studentCollection = try db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").addDocument(from: newStu, completion: {(err) in
                                                        
                                                    if let err = err {
                                                        print("Error adding student \(newStu)")
                                                    }
                                                    else{
                                                        //print("Added student")
                                                        
                                                    }
                                                
                                                })
                                                } catch let error {
                                                    print("Error writing student to firestore: \(error)")
                                                }
                                            }
                                    
                                            
                                        case .failure(let error):
                                            print("Error getting week: \(error)")
                                    }
                            
                                }
                        
                            }
                        }
                    }
                 
                    fetchDatabaseCall()
                }
            }
            else{
                
                print("ID NUMBER IS NOT A NUMBER")
                
                self.present(confirmAlert(title: "Error", message: "ID number: \((textFieldID?.text)!) is not a number"), animated: true, completion: nil)
            }
        }))
          
        self.present(addAlert, animated: true, completion: nil)
 
    }
        
    //COMPLETE
    @IBAction func deleteStudentPressed(_ sender: Any) {
        
     
        //As the student object knows it's own documentID, a call can be removed
        let delAlert = UIAlertController(title: "Delete student", message: "Enter student ID", preferredStyle: .alert)
        
        var textFieldName: UITextField!
        var textFieldID: UITextField!
        
        delAlert.addTextField{ (textFieldIDIn) in textFieldIDIn.placeholder = "Enter ID here"; textFieldIDIn.keyboardType = UIKeyboardType.numberPad; textFieldIDIn.returnKeyType = UIReturnKeyType.continue}
        
        delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak delAlert] (_) in
            
            }))
        
        delAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {[weak delAlert] (_) in
            
            //CONFIRMATION SCREEN
            
            
            textFieldID = (delAlert?.textFields![0])!
            
            
            //CHECK IF EXISTS
            if ((self.studentsInWeek.contains(where: { id in id.studentID == textFieldID?.text}))){
                var stu_to_del = self.studentsInWeek[self.studentsInWeek.firstIndex(where:  {id in id.studentID == textFieldID?.text})!]
                
                let delConfirm = UIAlertController(title: "Confirm deletion of \(stu_to_del.studentName)", message: "Confirm deletion of student with ID \(stu_to_del.studentID)? \nCaution there is no undo", preferredStyle: .alert )
                
                delConfirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak delAlert] (_) in
                    
                }))
                
                delConfirm.addAction(UIAlertAction(title: "Confirm deletion", style: .destructive, handler: {[weak delAlert] (_) in
                    
                    
                    for n in self.currentWeek...Int(self.unit!.numberOfWeeks)
                    {

                        let db = Firestore.firestore()
                        let weekCollection = db.collection("units").document(self.unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: n).getDocuments()
                        { (result, err) in
                            if let err = err
                            {
                                print("error getting week: \(err)")
                            }
                            else
                            {
                                for document in result!.documents
                                {
                                    let conversionResult = Result{
                                        try document.data(as: Week.self)
                                    }
                                        
                                    switch conversionResult
                                    {
                                        case .success (let convertedDoc):
                                            if var week = convertedDoc{
                                                //Found week to delete from
                                                week.id = document.documentID
                                  
                                                do {
                                                    let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").getDocuments()
                                                    { (resultStu, err) in
                                                        
                                                        if let err = err {
                                                            print("Error delete student \(stu_to_del.studentName)")
                                                        }
                                                        else{
                                                            
                                                            for document in resultStu!.documents
                                                            {
                                                                let conversionResultStu = Result{ try document.data(as: Student.self)}
                                                                
                                                                switch conversionResultStu
                                                                {
                                                                case .success(let conversionDoc):
                                                                    if var student = conversionDoc
                                                                    {
                                                                        student.doc_id = document.documentID
                                                                      
                                                                        
                                                                        db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").document(student.doc_id!).delete(){
                                                                            err in
                                                                            if let err = err {
                                                                                print("error deleteing")
                                                                            }
                                                                            else{
                                                                                print("deleted")
                                                                            }
                                                                        }
                                                                    }
                                                                
                                                                case .failure(let error):
                                                                    print("Error getting student: \(error)")
                                                                }
                                                            
                                                            
                                                            print("deleted student from week \(n)")
                                                            
                                                            
                                                        if (self.currentWeek == n){
                                                            
                                                            self.studentsInWeek.remove(at: self.studentsInWeek.firstIndex(where:  {id in id.studentID == textFieldID?.text})!)
                                                            
                                                            self.fetchDatabaseCall()
                                                            
                                                            self.present(self.confirmAlert(title:"Deletion", message:"Deletion confirmed"), animated: true, completion: nil)
                                                            }
                                                        }
                                                    }
                                                 
                                                }
                                            }
                                    }
                                    case .failure(let error):
                                        print("Error getting week: \(error)")
                        
                            }
                                }
                            }
                    
 
                        }
                    }
                
                }))
                    
                self.present(delConfirm, animated: true, completion: nil)
            }
            //If doesnt exist
            else{
                var text = textFieldID.text!
                
                var stringToShow: String!
                
                //Change the string if it's empty
                if (text.isEmpty){
                    stringToShow = "Please enter an ID"
                }
                else{
                    stringToShow = "ID of \(text) did not match any students"
                }
                
                let delConfirm = UIAlertController(title: "Student doesn't exist in class", message: stringToShow, preferredStyle: .alert )
                
                delConfirm.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: {[weak delAlert] (_) in
                    
                }))
                
                self.present(delConfirm, animated: true, completion: nil)
            }
                  
        }))
        
        self.present(delAlert, animated: true, completion: nil)
        
        
        
        
    }
    
    
    @IBAction func moveToWeekDetail(_ sender: Any) {
        //SEGUE gets activated without this, used for debug purposes
    }
    
    //COMPLETE
    @IBAction func emailReportPressed(_ sender: Any) {
        
        var string = "Unitname: \(unit!.unitname), Week: \(currentWeek), Grade scheme: \(gradeStyle ?? "none"),\n"
        
        string = string + "Student Name, Student ID, Grade\n"
        
        for student in studentsInWeek{
            string = string + "\(student.studentName), \(student.studentID), \(student.grade)\n"
        }
        
        
        
        UIPasteboard.general.string = string
            
        print("Clipboard: \(UIPasteboard.general.string ?? "No information")")
    }
    
    
    func hdToNumeric(grade: String) -> Int{
        switch (grade){
        case "HD":
            return 100
        case "DN":
            return 80
        case "CR":
            return 60
        case "PP":
            return 50
        case "NN":
            return 25
        default:
            return 0
        }
    }
    
    func aToNumeric(grade:String) -> Int{
        switch (grade){
        case "A":
            return 100
        case "B":
            return 80
        case "C":
            return 60
        case "D":
            return 50
        case "F":
            return 25
        default:
            return 0
        }
    }
    
    func numToNumeric(grade:String) -> Int{
        return Int(Float(grade) ?? 0)
    }
    
    func attToNumeric(grade:String) -> Int{
        if (grade == "Present"){
            return 100
        }
        else{
            return 0
        }
    }
    
    func chkToNumeric(grade: String, gradeStyle: String) -> String{
        //calculate percentage mark from gradeChose from GradeList
            
        if (grade.count > 5){
        //get the int number in grade scheme
        var amountOfPoints = Float(gradeStyle.suffix(from: String.Index(encodedOffset: 3)))
        
        //get the int number in grade
            var gradeFound = grade.components(separatedBy: "Check ")
            //print("Grade found: \(gradeFound[1])")
            
            var percentage = Float(gradeFound[1])! / amountOfPoints! * 100
            
        var strPer = percentage
        //var strPer = "2"
            
        return String(strPer)
        }
        
        return "0"
    }
    
    func attendenceWeek(students: [Student], gradeStyle: String) -> String{
        
        var sorted = students.sorted{$0.grade > $1.grade}
        var attendCount = 0
        
        var nonAttend: String!
        switch (gradeStyle){
        case "hd":
            nonAttend = "UG"
            break
        case "a":
            nonAttend = "F"
            break
        case "num":
            nonAttend = "0.0"
            break
        case "att":
            nonAttend = "Not present"
            break
        default:
            nonAttend = "Check 0"
            break
        }
            
        var attendence: Float!
        
        if (students.count != 0){
            for i in 0...students.count-1{
                if (students[i].grade != nonAttend){
                    attendCount += 1
                }
            }
            
            attendence = (Float(attendCount) / Float(sorted.count)) * 100
        }
        else{
            attendence = 0.0
        }
        
        return String(attendence)
        
    }
    
    func averageWeek(students: [Student]) -> String {
        
        var gradeHigh: String!
        var gradeHighCount = 0
        
        
// www.stackoverflow.com/questions/30545518/how-to-count-occurances-of-an-element-in-a-swift-array
        var counts: [String: Int] = [:]
        
        //Get the counts
        for item in students{
            counts[item.grade] = (counts[item.grade] ?? 0) + 1
        }
        
        //Find the highest, mode (not mean, could still be mean?)
        for (key, value) in counts {
            if (gradeHighCount == 0){
                gradeHigh = key
                gradeHighCount = value
            }
            
            else if (value > gradeHighCount){
                gradeHigh = key
                gradeHighCount = value
            }
        }
        
        var gradeAverage = gradeHigh
        return gradeAverage!
    }
    
    func gradeToNumeric(grade: String, gradeStyle: String) -> String{
        
        switch (gradeStyle){
        case "hd":
            return String(hdToNumeric(grade: grade))
        case "a":
            return String(aToNumeric(grade: grade))
        case "num":
            return String(numToNumeric(grade: grade))
        case "att":
            return String(attToNumeric(grade: grade))
        default:
            //Chk point
            return String(chkToNumeric(grade: grade, gradeStyle: gradeStyle))
        }
        return String("")
    }

    @IBAction func unitSummaryEmail(_ sender: Any) {
        
        print("Pressed unit email")
        
        unitSummary = unitSummary.sorted{$0 < $1}
        
        UIPasteboard.general.string = self.unitSummary.joined(separator: "\n")
        
        self.present(confirmAlert(title: "The following has been added to your clipboard", message: "Unit summary all weeks for: \(unit!.unitname ?? "")\nWeek, Grade Average, GA Numeric, Attendence %\n\(UIPasteboard.general.string ?? "No information")"), animated: true, completion: nil)
            
        print("Clipboard: \(UIPasteboard.general.string ?? "No information")")
        
    }
    
    //COMPLETE
    @IBAction func enteredSearch(_ sender: Any) {
        searchText.text = ""
        oldListStudent.removeAll()
        
        
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
                            //print("WeekID found: \(week.id)")
                            
                            let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(self.WeekObjID!).collection("students").getDocuments()
                            { [self] (resultStu, err) in
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
                                            if var student = conversionDoc
                                            {
                                                student.doc_id = document.documentID
                                                //print("Student found: \(student.studentName)")
                                                self.oldListStudent.append(student)
                                            }
                                        
                                        case .failure(let error):
                                            print("Error getting student: \(error)")
                                        }
                                    }
                                    self.studentsInWeek = self.oldListStudent
                                    self.studentTable.reloadData()
                                    //No need to reload info
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
    
    //COMPLETE
    @IBAction func searchEntered(_ sender: Any) {
        //print("searchEntered")
        
        if (searchText.text!.isEmpty){
            studentsInWeek.removeAll()
            studentsInWeek = oldListStudent
        }
        else{
            studentsInWeek = oldListStudent.filter {$0.studentName.lowercased().contains((searchText!.text?.lowercased())!)}
        }
        
        self.studentTable.reloadData()

        
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    //COMPLETE
    func tableView(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //COMPLETE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentsInWeek.count
    }

    //COMPLETE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "au.edu.utas.ios.StudentCell", for: indexPath)
        
        
        var student = studentsInWeek[indexPath.row]
        
        if let studentCell = cell as? StudentUITableViewCell
        {
            studentCell.studentNameLabel.text = student.studentName
            studentCell.studentIDLabel.text = student.studentID
            
            //var grade: String!
            
            studentCell.studentGradeField.borderStyle = .none
            studentCell.studentGradeField.isEnabled = false
            studentCell.studentGradeField.keyboardType = .asciiCapable
            
            
            var stu_grade = self.gradeStyle
            studentCell.gradeStepper.stepValue = 1;
            
            if (self.gradeStyle.count >= 4){
                
                var strPrefix = String(gradeStyle!.prefix(3)).uppercased()
                if (strPrefix == "CHK"){
                    
                    var strNumb = String(gradeStyle!).suffix(from: String.Index(encodedOffset: 3))//suffix is inclusive starting from 0
                    //print("\(strNumb)")
                    
                    var intNumb = Int(strNumb)
                    
                    
                    chk_Gradelist.removeAll()
                    for i in 0...intNumb!{
                            chk_Gradelist.append("Check \(i)")
                    }
                    
                    //print("\(strNumb)")
                    
                    stu_grade = strPrefix.lowercased()
                    //print("\(stu_grade)")
                }
            }

            
            switch (stu_grade){
            
            case "att":
                
                if (student.grade == "UG"){
                    student.grade = "Not present"
                }
                studentCell.gradeStepper.value = Double(attendance.firstIndex(of: student.grade)!)
                studentCell.gradeStepper.maximumValue = Double(attendance.count - 1)
                
                stu_grade = student.grade
                break
                
            case "hd":
                studentCell.gradeStepper.value = Double(hd_Gradelist.firstIndex(of: student.grade)!)
                studentCell.gradeStepper.maximumValue = Double(hd_Gradelist.count - 1)
                
                stu_grade = student.grade
                
                break
            case "a":
                studentCell.gradeStepper.value = Double(a_Gradelist.firstIndex(of: student.grade)!)
                studentCell.gradeStepper.maximumValue = Double(a_Gradelist.count - 1)
                
                stu_grade = student.grade
                break
            case "chk":
//                print("made it to CHK")
                var value: String!
                
                if(student.grade == "UG"){
                    value = "Check 0"
                }
                else{
                    value = student.grade
                }

                studentCell.gradeStepper.value = 0
                studentCell.gradeStepper.maximumValue = Double(chk_Gradelist.count - 1)
                
                stu_grade = String(value)
                break
            case "num":
                var value: Int!
                studentCell.studentGradeField.isEnabled = true
                studentCell.studentGradeField.returnKeyType = .done
                studentCell.studentGradeField.borderStyle = .bezel
                studentCell.studentGradeField.keyboardType = .asciiCapableNumberPad
                
                if(student.grade == "UG"){
                    value = 0
                }
                else{
                    value = Int(Float(student.grade) ?? 0)
                    
                }
                //print("Value CHOSEN CHOSEN CHOSEN is: \(Double(value ?? 0))")
                studentCell.gradeStepper.value = Double(value ?? 0)
                studentCell.gradeStepper.maximumValue = 100
                
                
                if (value < 50){
                    studentCell.gradeStepper.stepValue = 10
                }
                else if (value < 80 && value > 50){
                    studentCell.gradeStepper.stepValue = 5
                }
                else{
                    studentCell.gradeStepper.stepValue = 1
                }
    
                stu_grade = String(value)
                
                break
            default:
                studentCell.gradeStepper.value = 0
    
                stu_grade = String(0)
            }
            
            //print("student: \(student.studentName) uhh steppvalue is: \(studentCell.gradeStepper.value) Stepmax \(studentCell.gradeStepper.maximumValue)")
            studentCell.studentGradeField.text = stu_grade
            if (stu_grade == "0" || stu_grade == "UG" || stu_grade == "Not present" || stu_grade == "Check 0" || stu_grade == "F"){
                studentCell.studentGradeField.textColor = .systemRed
            }
            else {
                studentCell.studentGradeField.textColor = .label
            }
                
            //Store the indexrow to know who to save
            studentCell.gradeStepper.tag = indexPath.row
            studentCell.studentGradeField.tag = indexPath.row
            
        }
        
        
        return cell
        
    }
    
    //COMPLETE
    @IBAction func textChanged(_ sender: UITextField) {
        
        if (gradeStyle == "num"){
            
            var indexPath = IndexPath(row: sender.tag, section: 0)
            
            if let cell = self.studentTable.cellForRow(at: indexPath) as? StudentUITableViewCell {
                
                let idNumber = Int((cell.studentGradeField?.text)!) ?? -1
                
                if (idNumber == -1){
                    confirmAlert(title: "Error did not update", message: "Please enter a number for this grade scheme")
                    
                }
                else
                {
                    
                    var grade_todouble_thenFinallyString = String(Double(sender.text!)!)
                    
                    if (Double(sender.text!)! > 100){
                        grade_todouble_thenFinallyString = "100.0"
                        sender.text = "100.0"
                    }
                    
                    print("Changed :\(sender.text) with id of \(sender.tag)")
                
                    var indexPath = IndexPath(row: sender.tag, section: 0)
                    
                    if let cell = self.studentTable.cellForRow(at: indexPath) as? StudentUITableViewCell {
                    
                        print("Student name in table: \(cell.studentNameLabel.text) and list name : \(self.studentsInWeek[sender.tag].studentName) with id: \(self.studentsInWeek[sender.tag].doc_id)")
                        
                        let db = Firestore.firestore()
                        let studentToUpdate = db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).collection("students").document(self.studentsInWeek[sender.tag].doc_id!)
                        
                        studentToUpdate.updateData([
                            "grade": grade_todouble_thenFinallyString
                        ]) { err in
                            if let err = err {
                                print("Error updating")
                            }
                            else{
                                print("Updated student grade")
                            }
                        }
                    }
                }
            }
        }
        
        else{
            var indexPath = IndexPath(row: sender.tag, section: 0)
            
            if let cell = self.studentTable.cellForRow(at: indexPath) as? StudentUITableViewCell {
            
//                print("Student name in table: \(cell.studentNameLabel.text) and list name : \(self.studentsInWeek[sender.tag].studentName) with id: \(self.studentsInWeek[sender.tag].doc_id)")
                
                let db = Firestore.firestore()
                let studentToUpdate = db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).collection("students").document(self.studentsInWeek[sender.tag].doc_id!)
                
                studentToUpdate.updateData([
                    "grade": self.studentsInWeek[sender.tag].grade
                ]) { err in
                    if let err = err {
                        print("Error updating")
                    }
                    else{
                        print("Updated student grade")
                    }
                }
            }
        }
        
        firstCall = false //It's been updated
    }
    
    //COMPLETE
    @IBAction func changeSchemeClicked(_ sender: Any) {
        
        var chosenScheme : String?
        var textFieldScheme: UITextField?
        
        //Taken from stackoverflow.com/questions/
        
        let options = """
            Note: \n
            Changing schemes will reset all grades (including picking the current scheme)\n\n
            Options list:\n
            HD for HD DN CR PP NN\n
            A for A B C D E\n
            NUM for 0 to 100\n
            CHK[num] for checkpoints e.g. CHK4\n
            ATT for attendance
            """
        
        let choiceAlert = UIAlertController(title: "Choose a new scheme", message: options, preferredStyle: .alert)

        choiceAlert.addTextField{ (textFieldScheme) in textFieldScheme.placeholder = "Enter scheme here"; textFieldScheme.returnKeyType = UIReturnKeyType.continue}
        
        
        let cancelScheme = UIAlertAction(title:"Cancel", style: .cancel)
        
        choiceAlert.addAction(UIAlertAction(title:"Confirm", style: .default, handler: { [self, weak choiceAlert] (_) in
            textFieldScheme = (choiceAlert?.textFields![0])!
            
            var str = textFieldScheme?.text?.uppercased()
            
            //CHECK CHK
            if (str!.count >= 4){
                
                var strPrefix = String(str!.prefix(3))
                if (strPrefix == "CHK"){
                    
                    var strNumb = str!.suffix(from: String.Index(encodedOffset: 3))//suffix is inclusive starting from 0
                    
                    var intNumb = Int(strNumb)
                    
                    if (intNumb == nil){
                        self.present(confirmAlert(title: "Error", message: "Please enter in the number of checkpoints you wish to add in the form CHK[n] where [n] is a real number"),animated: true, completion: nil)
                        
                        str = ""
                    }
                    
                    else if (intNumb! > 1000){
                        self.present(confirmAlert(title: "Error too many checkpoints", message: "\(intNumb!) checkpoints is too much for one class, please doube check your teaching method"),animated: true, completion: nil)
                        
                        str = ""
                    }
                    
                    else if (intNumb! < 0){
                        self.present(confirmAlert(title: "Error too many checkpoints", message: "You can't have \(intNumb!) checkpoints"),animated: true, completion: nil)
                        
                        str = ""
                    }
                    
                    else {
                    chk_Gradelist.removeAll()
                    for i in 0...intNumb! + 1{
                            chk_Gradelist.append("Check \(i)")
                    }
                    
                    print("\(strNumb)")
                    
                    str = strPrefix
                    }
                }
                
            }
            
            var worked = true
            
            switch (str){
            case "HD":
                //print("HD selected")
                self.gradeStyle = "HD".lowercased()
            case "A":
                //print("A selected")
                self.gradeStyle = "A".lowercased()
            case "NUM":
                //print("NUM selected")
                self.gradeStyle = "NUM".lowercased()
            case "CHK":
                //print("CHK selected")
                self.gradeStyle = textFieldScheme?.text?.lowercased()
            case "ATT":
                //print("ATT selected")
                self.gradeStyle = "ATT".lowercased()
            default:
                self.present(confirmAlert(title: "Incorrect scheme", message: "Your input, \(str ?? "invalid input") did not match and schemes"), animated: true, completion: nil)
                worked = false
            
            }
            
            if (worked){
                changeMarkSchemeDatabaseCall()
            }
        }))
        
        choiceAlert.addAction(cancelScheme)
        
        self.present(choiceAlert, animated: true, completion: nil)
        
    }
    //COMPLETE
    @IBAction func gradeChanged(_ sender: UIStepper) {
        //print("Stepper in row: \(sender.tag) value of \(sender.value)")
        sender.stepValue = 1
        var indexPath = IndexPath(row: sender.tag, section: 0)
        
        if let cell = self.studentTable.cellForRow(at: indexPath) as? StudentUITableViewCell {
            
            
            //Check if CHK
            var str = self.gradeStyle
            var gs = self.gradeStyle
            
            if (str!.count >= 4){
                
                var strPrefix = String(str!.prefix(3)).uppercased()
                if (strPrefix == "CHK"){
                    

                    var strNumb = str!.suffix(from: String.Index(encodedOffset: 3))//suffix is inclusive starting from 0
                    
                    var intNumb = Int(strNumb)
                    
                    chk_Gradelist.removeAll()
                    for i in 0...intNumb!{
                            chk_Gradelist.append("Check \(i)")
                    }
                
                    
                    str = strPrefix.lowercased()
                }
            }
                   
            switch (str){
            case "att":
                str = attendance[Int(sender.value)]
                break;
            case "hd":
                str = hd_Gradelist[Int(sender.value)]
                break
            case "a":
                str = a_Gradelist[Int(sender.value)]
                break
            case "chk":
                str = chk_Gradelist[Int(sender.value)]
                break
            case "num":
                if (Int(sender.value) < 50){
                    sender.stepValue = 10
                }
                else if (Int(sender.value) < 80 && Int(sender.value) > 50){
                    sender.stepValue = 5
                }
                else{
                    sender.stepValue = 1
                }
                str = String(Int(sender.value))
                break
            case .none:
                break
            case .some(_):
                str = String(sender.value)
                break
            }
            
            if ((str == "UG") || (str == "Not present") || str == "0" || str == "Check 0"){
                cell.studentGradeField.textColor = .systemRed
            }
            else{
                cell.studentGradeField.textColor = .label
            }
            
            cell.studentGradeField.text = str
            self.studentsInWeek[sender.tag].grade = str!
            
            //Required to launch event as
            //if text is changed programmatically, it wont activate
            cell.studentGradeField.sendActions(for: .editingChanged)
        }
    }


    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toWeekReport"){
            
            guard let destination = segue.destination as? ReportWeekViewController else
            {
                fatalError("Incorrect destination \(segue.destination)")
            }
            
//            destination.weekTitle.text = String(self.currentWeek)
            destination.title = "Report week: \(String(self.currentWeek))"
            destination.weekNum = self.currentWeek
            
            
            destination.gradeAverage = averageWeek(students: studentsInWeek)
            
            destination.attendence = attendenceWeek(students: studentsInWeek, gradeStyle: self.gradeStyle)
            
            
            //Create the report array
            var strRep = [String]()
            strRep.append("Unitname: \(unit!.unitname), Week: \(currentWeek), Grade scheme: \(gradeStyle ?? "none")")
            
            strRep.append("Student Name, Student ID, Grade")
           
            for student in studentsInWeek{
                strRep.append("\(student.studentName), \(student.studentID), \(student.grade)")
            }
            
            
            destination.studentReport = strRep
        }
  
        if (segue.identifier == "toStudentView"){
            
            
            
            //We have the destination
            guard let destination = segue.destination as? StudentDetailViewController else
            {
                fatalError("Incorrect destination \(segue.destination)")
            }
            
            //Get the student
            
            guard let selectedStudentCell = sender as? StudentUITableViewCell else
            {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            let indexPath = selectedStudentCell.studentGradeField.tag
            
            let selectedStudent = studentsInWeek[indexPath]
            
            destination.title = selectedStudent.studentName
            
            destination.studentName = selectedStudent.studentName
            destination.studentID = selectedStudent.studentID
            destination.unit = self.unit
        
            
            
            //Grade average
            /*
                Cycle through DB
                Add to string list getting grade and gradestyle
                determine average grade
                use this to determine attendence
             */
            
        
           
            destination.gradeAverage = "Uncalculated"
            
            
            //Attendence percent
            
            
            destination.attendance = "Uncalculated"
            
            
            
            //Last grade (latest week that isn't a UG / 0 / etc)
            
            
            destination.lastGrade = selectedStudent.grade
            
            
        }
    }
    
    
    @IBAction func unwindToWeekList(sender: UIStoryboardSegue){
        print("Unwinded")
        
        fetchDatabaseCall()
    }
    
    
}





