//
//  StudentDetailViewController.swift
//  assignment_two
//
//  Created by Adam Scott on 19/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage


class StudentDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    //Fields
    @IBOutlet var studentNameField: UITextField!
    
    
    //Labels
    @IBOutlet var studentIDlabel: UILabel!
    @IBOutlet var gradeAverageLabel: UILabel!
    @IBOutlet var attendanceLabel: UILabel!
    @IBOutlet var lastGradeLabel: UILabel!
    
    //Image
    @IBOutlet var studentPhoto: UIImageView!
    
    //Variables from segue
    var studentName: String!
    var studentID: String!
    var gradeAverage: String!
    var attendance: String!
    var lastGrade: String!
    var unit: Unit!
    
    
    
    //Internal Variables
    var gotData = false
    var calculated = false
    var studentInformation = [Student]()
    var imageRef: String!//Reference to the Document ID
    
    func getData(){
        studentInformation.removeAll()
        
        let db = Firestore.firestore()
        db.collection("units").document(self.unit!.id).collection("weeks").getDocuments(){
            (result, err) in
            
            if let err = err {
                print("error getting weeks")
            }
            
            for docs in result!.documents{
                
                db.collection("units").document(self.unit!.id).collection("weeks").document(docs.documentID).collection("students").getDocuments(){ (res, err) in
                    
                    if let err = err {
                        print("Error getting students")
                    }
                    
                    let convertWeek = Result { try docs.data(as: Week.self)}
                    switch convertWeek{
                    case .success( let convertedWeek):
                        if var weekConvered = convertedWeek {
                            for students in res!.documents{
                                let conversionResultStu = Result{ try students.data(as: Student.self)}
                                switch conversionResultStu
                                {
                                case .success(let conversionDoc):
                                    if var student = conversionDoc
                                    {
                                        if (student.studentID == self.studentID)
                                        {
                                            student.doc_id = weekConvered.gradeScheme
//                                            print("Student in StudentDetail: \(student.studentName)")
                                            self.studentInformation.append(student)
                                        }
                                    }
                                
                                case .failure(let error):
                                    print("Error getting student: \(error)")
                                }
                                
                            }
                        }
                        
                        self.gotData = true
                        
                        
                    case .failure(let error):
                        print("error")
                    }
                    //print(self.studentInformation)
                }
            }
        }
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
    
    
    
    func calculateGrade(){
        var grades = [String]()
        
        for student in self.studentInformation{
            grades.append(gradeToNumeric(grade: student.grade, gradeStyle: student.doc_id!))
        }
        
        var gradeTotal = Float(0)
        for grade in grades{
            gradeTotal += Float(grade)!
        }
        
        gradeAverage = String( (Int(gradeTotal) / grades.count)) + "%"
        self.gradeAverageLabel.text = gradeAverage
        
        
    }
    
    func calculateAttendence(){
        
        var attended = 0
        
        for student in self.studentInformation{
            if (student.grade != "UG" || student.grade != "Check 0" || student.grade != "Not present")
            {
                attended += 1
            }
        }
        
        attendance = String(Float(attended / self.studentInformation.count) * 100)
        
        self.attendanceLabel.text = attendance
        
    }
    
    @IBAction func calcPressed(_ sender: Any) {
       
        if (self.studentInformation.count > 0){
            calculateAttendence()
            calculateGrade()
        }
        
    }
    
    //Main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
       
        

        //Populate fields
        studentNameField.text = studentName
        studentIDlabel.text = studentID
        gradeAverageLabel.text = gradeAverage
        attendanceLabel.text = attendance
        lastGradeLabel.text = lastGrade
        
        //Get photo
        let db = Firestore.firestore()
        let store = Storage.storage()
        
        self.present(confirmAlert(title: "Downloading photo", message: "Please wait", exit: false),animated: true,completion: nil)
        
        
        db.collection("pictures").getDocuments(){ [self]
            (result, err) in
            
            if let err = err
            {
                print("error getting week: \(err)")
            }
            
            else{
                for document in result!.documents
                {
                    if document.get("studentReference") != nil {
                        
                        if document.get("studentReference") as! String == self.studentID  && document.get("unitReference") as! String == self.unit.unitname{
                            self.imageRef = document.get("filePath") as! String
                            //print(self.imageRef)
                        }
                        
                        
                    }
                }
                if (self.imageRef == nil){
                    self.imageRef = "default.jpg"
                    //print(self.imageRef)
                }
                
                let imageToDownload = store.reference(withPath: self.imageRef)
                imageToDownload.getData(maxSize: 10000 * 1250 * 1250) { data, error in
                    
                    if let error = error {
                        fatalError("something happened \(error)")
                    }
                    else {
                        self.studentPhoto.image = UIImage(data: data!)
                        self.dismiss(animated:true, completion: nil)
                    }
                }
            }
        }
    }
    
    func confirmAlert(title: String, message: String, exit: Bool) -> UIAlertController {
     
        let alert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        if exit {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        return alert
    }
    
    //Button functions
    @IBAction func takePhoto(_ sender: Any) {
        present(confirmAlert(title: "Error", message: "Can't open camera on a simulator, please use choose photo", exit: true), animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        //hackingwithswift.com/example-code-media/how-to-choose-a-photo-from-the-camera-roll-using-uiimagepickercontroller
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        
        present(vc,animated: true)
    }
    
    //Listens for the picked image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        studentPhoto.image = image
        
        //Taken from firebase.google.com/docs/storage/ios/upload-files
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let storeref = storage.reference()
        let addedImage = storeref.child("\(studentName ?? "a")")
        
        
        let storRef = storage.reference()
        let imageDel = storRef.child(imageRef)
        //DELETE CURRENT IMAGE
        if (self.imageRef == "default.jpg"){
            print("Cannot delete default image from database")
        }
        else {
        imageDel.delete(){ error in
            if let error = error {
                print("error deleting")
            } else {
                print("Deleted file")
            }
            }
        }
        
        
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpeg"
        
        
        guard let data: Data = image.jpegData(compressionQuality: 0.5) else {return}
        
        
        let uploadTask = addedImage.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadeta = metadata else {
                print("error metadata")
                return
            }
            
            let size = metadata!.size
        }
        
        db.collection("pictures").document("\(studentName ?? studentID)").setData([
            "filePath": "\(studentName ?? "a")",
            "studentReference" :"\(studentID ?? "0")",
            "unitReference": self.unit.unitname
        ]) { err in
            if let err = err {
                print("Error writing image reference")
            }
            else {
                print("Image reference added")
            }
            
        }
        
        
        
        
    }
    
    @IBAction func removePhoto(_ sender: Any) {
        
        studentPhoto.image = .remove
        
        let db = Firestore.firestore()
        
        db.collection("pictures").getDocuments()
        {
            (result, err) in
            
            if let err = err
            {
                print("error getting week: \(err)")
            }
            
            else{
                for document in result!.documents
                {
                    if (document.get("studentReference") != nil) && (document.get("studentReference") as! String == self.studentID) {
                        db.collection("pictures").document(document.documentID).delete() { err in
                            if let err = err {
                                print("Error updating")
                            }
                            else{
                                print("Deleted \(self.studentID)")
                                print("Deleted student image")
                            }
                        }
                    }
                }
            }
        }
        
        //TODO REMOVE THE IMAGE DOCUMENT IN DB
        let storage = Storage.storage()
        let storRef = storage.reference()
        let imageDel = storRef.child(imageRef)
        
        if (self.imageRef == "default.jpg"){
            print("Cannot delete default image from database")
        }
        else {
        imageDel.delete(){ error in
            if let error = error {
                print("error deleting")
            } else {
                print("Deleted file")
            }
            }
        }
    }
    
    @IBAction func emailSummary(_ sender: Any) {
        //TODO generate all weeks information
        var string = ""
        
        string += "Student: \(studentName ?? "")\nWith ID: \(studentID ?? "")\n"
        string += "Grade Average: \(gradeAverage ?? "")\n"
        string += "Attendance percent: \(attendance ?? "")\n"
        
        UIPasteboard.general.string = string
            
        print("Clipboard: \(UIPasteboard.general.string ?? "No information")")
        
    }
    
    //Student Name Func
    @IBAction func saveChangedName(_ sender: Any) {
        //TODO Change the student's name in database
        
        

        for n in 1...Int(self.unit!.numberOfWeeks)
        {

 
            let db = Firestore.firestore()
            let weekCollection = db.collection("units").document(self.unit!.id).collection("weeks").whereField("weekNumber", isEqualTo: n).getDocuments()
            { (result, err) in
                if let err = err {
                    print("error \(err)")
                }
                
                else {
                    for document in result!.documents{
                        let conversion = Result{
                            try document.data (as: Week.self)
                        }
                        
                        switch (conversion){
                        case .success(let convertedDoc):
                            if var week = convertedDoc{
                                week.id = document.documentID
                                
                                do{
                                    let studentCollection = db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").getDocuments() { [self] (resultStu, err) in
                                        
                                        if let err = err {
                                            print("Error getting student")
                                        }
                                        else{
                                            for doc in resultStu!.documents{
                                                if doc.get("studentID") as! String == studentID{
                                                    let studentToUpdate = db.collection("units").document(unit!.id).collection("weeks").document(week.id).collection("students").document(doc.documentID)
                                                    
                                                    studentToUpdate.updateData(["studentName": studentNameField!.text]){ err in
                                                        if let err = err {
                                                            print("Error updating")
                                                        }
                                                        else{
                                                            print("Updated student name")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                        case .failure(let convertErr):
                            print("Error getting doc \(convertErr)")
                        }
                        
                    }
                }
                
                
            }
            
        }
        
        /*
         
                                     let studentCollection = try db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").getDocuments() { (resStu, error) in
                                         if let error = error {
                                             print("error getting students")
                                         }
                                         else{
                                             for stud in resStu!.documents{
                                                 if (stud.get("studentID") == studentID ?? "0"){
                                                     db.collection("units").document(self.unit!.id).collection("weeks").document(week.id).collection("students").document(stud.documentID).updateData(["studentName": studentNameField!.text]){
                                                         err in
                                                         if let err = err {
                                                             print("error updating")
                                                         }
                                                         else{
                                                             print("updated")
                                                         }
                                                     }
                                                 }
                                             }
                                         }
                                                                                     
                                     
                                     }
                                 }
                             }
                     case .failure(let err):
                         print("error")
                     }
                 }
             }
         }
         
         */
        
        
        view.endEditing(true)
    }
    @IBAction func backClicked(_ sender: Any) {
        print("Back pressed")
        self.studentInformation.removeAll()
        self.performSegue(withIdentifier: "returnSegue", sender: sender)
    }
    
    @IBAction func WeeksBack(_ sender: Any) {
        print("Back pressed")
        self.studentInformation.removeAll()
        self.performSegue(withIdentifier: "returnSegue", sender: sender)
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
