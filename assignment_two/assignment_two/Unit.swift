//
//  Units.swift
//  assignment_two
//
//  Created by Swift Labourer on 10/5/21.
//

import Firebase
import FirebaseFirestoreSwift

public struct Unit : Codable {
    var id:String
    var numberOfWeeks:Int32
    var unitname:String
}
