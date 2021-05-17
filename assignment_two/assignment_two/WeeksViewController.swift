//
//  WeeksViewController.swift
//  assignment_two
//
//  Created by Swift Labourer on 11/5/21.
//


//TODO CHANGE GRADE SCHEMES THAT RESET GRADES - NEED TO IMPLEMENT CHECKPOINTS
//TODO GENERATE WEEK REPORT FUNCTION
//TODO ADD WEEK REPORT FUNCTION TO EMAIL REPORT
//TODO MOVEMENT TO WEEK REPORT, WITH WEEK REPORT FUNCTION AND ALL CALCULATIONS
//TODO MOVEMENT TO STUDENT DETAILS, WITH STUDENT INFORMATION FROM ALL WEEKS(?)
//TODO IN STUDENT DETAILS: PHOTO CAMERA STUFF, ADD, CHANGE, DELETE


import UIKit
import Firebase
import FirebaseFirestoreSwift

class WeeksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var studentTable: UITableView!
    
    @IBOutlet var weekNumberLabel: UILabel!
    
    @IBOutlet weak var lastButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var searchText: UITextField!
    
    var hd_Gradelist = ["UG", "NN", "PP", "CR", "DN", "HD"]
    var a_Gradelist = ["UG","F","D","C","B","A"]
    var attendance = ["Present", "Not present"]
    var chk_Gradelist = [String]()
    

    var unit: Unit?
    var unitIndex: Int?
    
    var studentsInWeek = [Student]()//Holds the list of students found within current week
    
    var oldListStudent = [Student]()//Holds a copy of studentsInWeek
    
    var currentWeek = 1
    var WeekObjID: String!
    var gradeStyle: String!
    
    
    
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
                                                print("Student found: \(student.studentName)")
                                                self.studentsInWeek.append(student)
                                            }
                                            
                                            
                                            
                                        
                                        case .failure(let error):
                                            print("Error getting student: \(error)")
                                        }
                                    }
                                    
                                    //Sets the buttons
                                    self.studentTable.reloadData()
                                    
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
    }
    
    func changeMarkSchemeDatabaseCall(){
        
        let db = Firestore.firestore()
        
        db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).updateData(["gradeScheme": self.gradeStyle])
        print("GradeStyle: \(gradeStyle)")
        
        for i in 0...(self.studentsInWeek.count-1) {
            let curStu = db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).collection("students").document(self.studentsInWeek[i].doc_id!).updateData(["grade":"UG"])
            
            
            if (i == self.studentsInWeek.count-1){
                fetchDatabaseCall()
                self.studentTable.reloadData()
            }
        }
        
//        let currentWeekOfStudents = db.collection("units").document(unit!.id).collection("weeks").document(WeekObjID).collection("students").getDocuments(){ (result, err) in
//
//            if let err = err {
//                print("Couldn't get students")
//            }
//
//            else {
//                for document in result!.documents{
//                    document.updateData([
//                        "grade": "UG"
//                    ])
//                }
//
//            }
//
//        }
        
        
        
    }
    
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
        addAlert.addTextField{ (textFieldIDIn) in textFieldIDIn.placeholder = "Enter ID here"; textFieldIDIn.keyboardType = UIKeyboardType.numberPad; textFieldIDIn.returnKeyType = UIReturnKeyType.continue}
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak addAlert] (_) in
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [self, weak addAlert] (_) in
            textFieldName = (addAlert?.textFields![0])!
            textFieldID = (addAlert?.textFields![1])!
            
            //TODO CHECK IF ID IS PURELY A NUMBER
            let idNumber = Int((textFieldID?.text)!) ?? -1
            
            if (idNumber != -1)
            {
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
                    
                    //Create the student
                    var newStu = Student(attended: false, doc_id: "", grade: "UG", studentID: (textFieldID?.text)!, studentName: (textFieldName?.text)!)
                    
                    let db = Firestore.firestore()

                    for n in self.currentWeek...Int(self.unit!.numberOfWeeks)
                    {
                        //ADD EACH WEEK
                        print("Adding to \(n)")
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
                                                        print("Added student")
                                            
                                                        self.present(confirmAlert(title: "Added", message: "Confirmed addition"), animated: true, completion: nil)
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
                //TODO error, ID is not a number
                print("ID NUMBER IS NOT A NUMBER")
            }
        }))
          
        self.present(addAlert, animated: true, completion: nil)
 
    }
        
    @IBAction func deleteStudentPressed(_ sender: Any) {
        
        //TODO implement
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
                                                    let studentCollection = try db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").document(stu_to_del.doc_id!).delete()
                                                    {err in
                                                        
                                                        if let err = err {
                                                            print("Error delete student \(stu_to_del.studentName)")
                                                        }
                                                        else{
                                                            print("deleted student")
    
                                                        if (self.currentWeek == n){
                                                            
                                                            self.studentsInWeek.remove(at: self.studentsInWeek.firstIndex(where:  {id in id.studentID == textFieldID?.text})!)
                                                            
                                                            self.fetchDatabaseCall()
                                                            
                                                            self.present(self.confirmAlert(title:"Deletion", message:"Deletion confirmed"), animated: true, completion: nil)
                                                            }
                                                        }
                                                    }
                                                 
                                                }
                                                catch let error {
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
    
    @IBAction func emailReportPressed(_ sender: Any) {
        
        //TODO GENERATE THE REPORT
        UIPasteboard.general.string = "TODO AHAHAHHAHAHAHAHAH"
            
        print("Clipboard: \(UIPasteboard.general.string)")
        
    }
    
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
                            print("WeekID found: \(week.id)")
                            
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
                                                print("Student found: \(student.studentName)")
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
    
    @IBAction func searchEntered(_ sender: Any) {
        print("searchEntered")
        
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
        
        
        var student = studentsInWeek[indexPath.row]
        
        if let studentCell = cell as? StudentUITableViewCell
        {
            studentCell.studentNameLabel.text = student.studentName
            studentCell.studentIDLabel.text = student.studentID
            
            //var grade: String!
            
            studentCell.studentGradeField.borderStyle = .none
            studentCell.studentGradeField.isEnabled = false
            
            var stu_grade: String!
            studentCell.gradeStepper.stepValue = 1;
            
            
            switch (self.gradeStyle){
            
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
                
                var value: Int!
                
                if(student.grade == "UG"){
                    value = 0
                }
                else{
                    value = Int(student.grade)
                }
                
                studentCell.gradeStepper.value = Double(value)
                studentCell.gradeStepper.maximumValue = Double(chk_Gradelist.count - 1)
                
                stu_grade = String(value)
                break
            case "num":
                var value: Int!
                
                if(student.grade == "UG"){
                    value = 0
                }
                else{
                    value = (student.grade as NSString).integerValue
                }
                
                studentCell.gradeStepper.value = Double(value)
                studentCell.gradeStepper.maximumValue = 100
                if (value < 70){
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
            if (stu_grade == "0" || stu_grade == "UG" || stu_grade == "Not present"){
                studentCell.studentGradeField.textColor = .systemRed
            }
                
            //Store the indexrow to know who to save
            studentCell.gradeStepper.tag = indexPath.row
            studentCell.studentGradeField.tag = indexPath.row
            
        }
        
        
        return cell
        
    }

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
                    var grade_todouble_thenFinallyString = String(Double(studentsInWeek[sender.tag].grade)!)
                    
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
            
                print("Student name in table: \(cell.studentNameLabel.text) and list name : \(self.studentsInWeek[sender.tag].studentName) with id: \(self.studentsInWeek[sender.tag].doc_id)")
                
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
        
    }
    
    @IBAction func changeSchemeClicked(_ sender: Any) {
        
        
        var chosenScheme : String?
        var textFieldScheme: UITextField?
        
        //Taken from stackoverflow.com/questions/
        
        let options = """
            Note: \n
            Choosing the current scheme will reset all grades\n\n
            Options list:\n
            HD for HD DN CR PP NN\n
            A for A B C D E\n
            NUM for 0 to 100\n
            CHK for checkpoints\n
            ATT for attendance
            """
        
        let choiceAlert = UIAlertController(title: "Choose a new scheme", message: options, preferredStyle: .alert)

        choiceAlert.addTextField{ (textFieldScheme) in textFieldScheme.placeholder = "Enter scheme here"; textFieldScheme.returnKeyType = UIReturnKeyType.continue}
        
        
        let cancelScheme = UIAlertAction(title:"Cancel", style: .cancel)
        
        choiceAlert.addAction(UIAlertAction(title:"Confirm", style: .default, handler: { [self, weak choiceAlert] (_) in
            textFieldScheme = (choiceAlert?.textFields![0])!
            
            var str = textFieldScheme?.text?.uppercased()
            
            switch (str){
            case "HD":
                print("HD selected")
                self.gradeStyle = "HD".lowercased()
            case "A":
                print("A selected")
                self.gradeStyle = "A".lowercased()
            case "NUM":
                print("NUM selected")
                self.gradeStyle = "NUM".lowercased()
            case "CHK":
                print("CHK selected")
                self.gradeStyle = "CHK".lowercased()
                
                print("TODO ADD NEXT ALERT FOR AMOUNT OF CHECKPOINTS")
            case "ATT":
                print("ATT selected")
                self.gradeStyle = "ATT".lowercased()
            default:
                confirmAlert(title: "Incorrect scheme", message: "Your input, \(str) did not match and schemes")
            }
            
            changeMarkSchemeDatabaseCall()
        }))
        
        
        
        choiceAlert.addAction(cancelScheme)
        
        self.present(choiceAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func gradeChanged(_ sender: UIStepper) {
        //print("Stepper in row: \(sender.tag) value of \(sender.value)")
        
        var indexPath = IndexPath(row: sender.tag, section: 0)
        
        if let cell = self.studentTable.cellForRow(at: indexPath) as? StudentUITableViewCell {
            
            var str: String!
            
            switch (gradeStyle){
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
                if (sender.value > 60){
                    sender.stepValue = 1
                }
                else {
                    sender.stepValue = 5
                }
                str = String(Int(sender.value))
                break
            case .none:
                break
            case .some(_):
                str = String(sender.value)
                break
            }
            
            if ((str == "UG") || (str == "Not present") || str == "0"){
                cell.studentGradeField.textColor = .systemRed
            }
            else{
                cell.studentGradeField.textColor = .label
            }
            
            cell.studentGradeField.text = str
            self.studentsInWeek[sender.tag].grade = str
            
            //Required to launch event as
            //if text is changed programmatically, it wont activate
            cell.studentGradeField.sendActions(for: .editingChanged)
        }
    }
}



