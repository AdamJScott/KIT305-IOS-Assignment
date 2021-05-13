//
//  WeeksViewController.swift
//  assignment_two
//
//  Created by Swift Labourer on 11/5/21.
//


//TODO ADD STUDENT - IMPLEMENTED, but add an alert for failure to tell the user what happened
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
    
    @IBOutlet var searchText: UITextField!
    
    

    
    var unit: Unit?
    var unitIndex: Int?
    
    var studentsInWeek = [Student]()//Holds the list of students found within current week
    
    var oldListStudent = [Student]()//Holds a copy of studentsInWeek
    
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
        
        searchText.text = ""
        
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
                                                if var student = conversionDoc
                                                {
                                                    student.doc_id = document.documentID
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
        
        searchText.text = ""
        
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
                                                if var student = conversionDoc
                                                {
                                                    student.doc_id = document.documentID
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
                    var newStu = Student(attended: false, doc_id: "", grade: "", studentID: (textFieldID?.text)!, studentName: (textFieldName?.text)!)
                    
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
    
                                                        if (self.currentWeek == n){
                                                            studentsInWeek.append(newStu)
                                                            self.studentTable.reloadData()
                                                        }
                                                        
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
                    
                    //Delete student
                    print("delete student TODO")
                    //TODO
                    
                    for n in self.currentWeek...Int(self.unit!.numberOfWeeks)
                    {
                        print("Adding to \(n)")
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
                                                           
                                                            
                                                            
                                                            self.studentTable.reloadData()
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
        
        //TODO implement
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
    
    
    //Search function
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
        
        
        let student = studentsInWeek[indexPath.row]
        
        if let studentCell = cell as? StudentUITableViewCell
        {
            studentCell.studentNameLabel.text = student.studentName
            studentCell.studentIDLabel.text = student.studentID
            studentCell.studentGradeField.text = student.grade
            
            //Store the indexrow to know who to save
            studentCell.studentGradeField.tag = indexPath.row
            
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
