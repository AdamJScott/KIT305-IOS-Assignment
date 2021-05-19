//
//  StudentDetailViewController.swift
//  assignment_two
//
//  Created by Swift Labourer on 19/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

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
    
    //Internal Variables
    var imageRef: String!//Reference to the Document ID
    
    //Main functions
    override func viewDidLoad() {
        super.viewDidLoad()

        //Populate fields
        studentNameField.text = studentName
        studentIDlabel.text = studentID
        gradeAverageLabel.text = gradeAverage
        attendanceLabel.text = attendance
        lastGradeLabel.text = lastGrade
        
        //Get photo
        
            
    }
    
    func confirmAlert(title: String, message: String) -> UIAlertController {
     
        let alert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
    
        alert.addAction(ok)
    
        return alert
    }
    
    //Button functions
    @IBAction func takePhoto(_ sender: Any) {
        present(confirmAlert(title: "Error", message: "Can't open camera on a simulator"), animated: true, completion: nil)
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
        
        //TODO set photo in database
    }
    
    @IBAction func removePhoto(_ sender: Any) {
        
        studentPhoto.image = .remove
        
        //TODO REMOVE THE IMAGE DOCUMENT IN DB
    }
    
    @IBAction func emailSummary(_ sender: Any) {
        //TODO generate all weeks information
        var string = ""
        
        
        
        
        UIPasteboard.general.string = string
            
        print("Clipboard: \(UIPasteboard.general.string ?? "No information")")
        
    }
    
    //Student Name Func
    @IBAction func saveChangedName(_ sender: Any) {
        //TODO Change the student's name in database
        
        view.endEditing(true)
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
