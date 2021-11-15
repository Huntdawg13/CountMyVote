//
//  CandidateTableViewController.swift
//  CountMyVote
//
//  Created by user190086 on 5/1/21.
//

import UIKit
import CoreData

class CandidateTableViewController: UITableViewController {
    
    var Candidates: [NSManagedObject] = []
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
        Candidates = fetchCandidates()
        
        for candidate in Candidates {
            printCandidate(candidate)
        }
        
        self.tableView.rowHeight = 44
        self.tableView.tableFooterView = UIView()

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
        return Candidates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateCell", for: indexPath)

        // Configure the cell...
        let theCandidate = Candidates[indexPath.row]
        let Name = theCandidate.value(forKey: "name") as? String
        let Position = theCandidate.value(forKey: "position") as? String
        cell.textLabel?.text = "\(Name!)"
        cell.detailTextLabel?.text = "\(Position!)"

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func deleteCandidate(_ candidate: NSManagedObject) {
        managedObjectContext.delete(candidate)
        appDelegate.saveContext()
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let candidate = Candidates[indexPath.row]
            Candidates.remove(at: indexPath.row)
            deleteCandidate(candidate)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
       // }
    }
    
    @IBAction func unwindFromCancel (segue: UIStoryboardSegue)
    {
        print("hi")
    }
    
    @IBAction func unwindFromSubmit (segue: UIStoryboardSegue)
    {
        print("world")
        
        let vc2 = segue.source as! AddCandidateViewController
        
        if let newCandidate = vc2.nameFromAddVC, !newCandidate.isEmpty
        {
            if let newPosition = vc2.positionFromAddVC, !newPosition.isEmpty
            {
                let candidate = NSEntityDescription.insertNewObject(forEntityName:
                                                "Candidate", into: self.managedObjectContext)
                candidate.setValue(newCandidate, forKey: "name")
                candidate.setValue(newPosition, forKey: "position")
                appDelegate.saveContext() // In AppDelegate.swift
                
                Candidates.append(candidate)
            }
        
            else
            {
                let candidate = NSEntityDescription.insertNewObject(forEntityName:
                                                "Candidate", into: self.managedObjectContext)
                candidate.setValue(newCandidate, forKey: "name")
                candidate.setValue("unknown", forKey: "position")
                appDelegate.saveContext() // In AppDelegate.swift
                
                Candidates.append(candidate)
            }
        
        self.view.endEditing(true)
        }
        
        self.tableView.reloadData()
    }
    
    func printCandidate(_ candidate: NSManagedObject) {
        let theCandidate = candidate.value(forKey: "name") as? String
        let thePosition = candidate.value(forKey: "position") as? String
        print("Name: \(theCandidate!), position = \(thePosition!)")
    }
    

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

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    } */
    
    
    func fetchCandidates() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Candidate")
        var candidates: [NSManagedObject] = []
        do {
            candidates = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getCandidates error: \(error)")
        }
        return candidates
    }

}
