//
//  UnitUITableViewController.swift
//  assignment_two
//
//  Created by Adam Scott on 10/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class UnitUITableViewController: UITableViewController {

    var units = [Unit]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

            
        let db = Firestore.firestore()
        let unitCollection = db.collection("units")
        
        unitCollection.getDocuments(){
            (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            
            else
            {
                for document in result!.documents
                {
                    let conversionResult = Result
                    {
                        try document.data(as: Unit.self)
                    }
                    switch conversionResult
                    {
                        case .success(let convertedDoc):
                            if var unit = convertedDoc
                            {
                                unit.id = document.documentID
                                print("Unit: \(unit)")
                                self.units.append(unit)//Add the unit to the list
                            }
                            else {
                                print("Unit doesn't exist")
                            }
                        case .failure(let error):
                            print("Error getting unit: \(error)")
                    }
                }
                self.tableView.reloadData()
            }
            
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return units.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitUITableViewCell", for: indexPath)
        
            //Get the unit for this row
        let unit = units[indexPath.row]
        
        if let unitCell = cell as? UnitUITableViewCell
        {
            unitCell.unitNameLabel.text = unit.unitname
            unitCell.enterUnitButton.tag = indexPath.row
        }

        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToClass"
        {
          
            guard let weeksViewController = segue.destination as? WeeksViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedUnitCellButton = sender as? UIButton else
            {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
//            guard let indexPath = tableView[selectedUnitCellButton.tag] else
//            {
//                fatalError("The selected cell is not being displayed by the table")
//            }
            
            let indexPath = selectedUnitCellButton.tag
            
            let selectedUnit = units[indexPath]
            
            weeksViewController.unit = selectedUnit
            weeksViewController.unitIndex = indexPath
            
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
