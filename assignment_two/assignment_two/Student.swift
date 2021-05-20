//
//  Student.swift
//  assignment_two
//
//  Created by Adam Scott on 11/5/21.
//


import Firebase
import FirebaseFirestoreSwift

public struct Student : Codable{
    var attended: Bool
    var doc_id: String?
    var grade: String
    var studentID: String
    var studentName: String
}
