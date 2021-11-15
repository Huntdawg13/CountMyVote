//
//  ElectionsTableViewController.swift
//  CountMyVote
//
//  Created by user190086 on 5/4/21.
//

import UIKit
import CoreData

class ElectionsTableViewController: UITableViewController {

    var SavedElections: [NSManagedObject] = []
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    var ElectionURLString = "https://www.googleapis.com/civicinfo/v2/elections?key=AIzaSyCIW2BSJF_ikBIGRcDz020fxzs7Pq4EEB4"
    var UpcomingElections = [ElectionItem]()
    
    override func viewDidLoad() {
        getElectionsFromServer()
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
        SavedElections = fetchElections()
        
        for election in SavedElections {
            printElection(election)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getElectionsFromServer() {
        /*let url = URL(string: NewsURLString)
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleResponse)
        dataTask.resume()
         */
        print("working")
        if let urlStr = ElectionURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                let dataTask = URLSession.shared.dataTask(with: url, completionHandler: handleResponse)
                dataTask.resume()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UpcomingElections.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElectionCell", for: indexPath)
        print("made it into cell")
        // Configure the cell...
        let theElection = UpcomingElections[indexPath.row]
        cell.textLabel?.text = "\(theElection.ElectionTitle!)"
        cell.detailTextLabel?.text = "\(theElection.ElectionDay!)"

        return cell
    }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let theElection = UpcomingElections[indexPath.row]
        
            let alert = UIAlertController(title: "Save Election",
                                      message: theElection.ElectionTitle , preferredStyle: .alert)
        
            let SaveAction = UIAlertAction(title: "Save", style: .cancel,
                                   handler: { [self] (action) in
            //command that sends quote
            let election = NSEntityDescription.insertNewObject(forEntityName:
                                            "Election", into: self.managedObjectContext)
            election.setValue(theElection.ElectionTitle, forKey: "name")
            election.setValue(theElection.ElectionDay, forKey: "date")
            self.appDelegate.saveContext() // In AppDelegate.swift
            
            SavedElections.append(election)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive,
        handler: { (action) in
        print("Cancel.")
        })
        
        alert.addAction(SaveAction)
        alert.addAction(cancelAction)
        alert.preferredAction = SaveAction
        present(alert, animated: true, completion: nil)

    }
    
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
    
    @IBAction func unwindFromBack (segue: UIStoryboardSegue)
    {
        print("hi")
        let vc2 = segue.source as! SavedElectionsTableViewController
        SavedElections = vc2.MySavedElections
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
            if segue.identifier == "toSavedElections" {
                let SavedVC = segue.destination as! SavedElectionsTableViewController
                SavedVC.MySavedElections = SavedElections
        }
    }
    
    
    func handleResponse (data: Data?, response: URLResponse?, error: Error?) {
        print("made it into handler")
        // 1. Check for error in request (e.g., no network connection)
        if let err = error {
            print("error: \(err.localizedDescription)")
            return
        }
    // 2. Check for improperly-formatted response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("error: improperly-formatted response")
            return
        }
        let statusCode = httpResponse.statusCode
    // 3. Check for HTTP error
        guard statusCode == 200 else {
            let msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            print("HTTP \(statusCode) error: \(msg)")
            return
        }
    // 4. Check for no data
        guard let somedata = data else {
            print("error: no data")
            return
        }
    // 5. Check for improperly-formatted data
        guard let jsonObj = try? JSONSerialization.jsonObject(with: somedata),
              let jsonDict1 = jsonObj as? [String: Any],
              let electionArray = jsonDict1["elections"] as? [Any],
              electionArray.count > 0,
              let jsonDict2 = electionArray[0] as? [String: Any],
              let ElectionStr = jsonDict2["name"] as? String,
              let ElectionDayStr = jsonDict2["electionDay"] as? String else {
                    print("error: invalid JSON data")
                    return
              }
            print(jsonDict1)
        
        // 6. Everything seems okay
        //self.loadNewsImage(urlToImage)
        print("\(ElectionStr) on \(ElectionDayStr)")
        for election in electionArray {
            let election = election as? [String: Any]
            let electionStr = election!["name"] as? String
            let dayStr = election!["electionDay"] as? String
            
            var ElectionItems = ElectionItem()
            if electionStr != nil {
                ElectionItems.ElectionTitle = electionStr
            } else {
                ElectionItems.ElectionTitle = "NO TITLE"
            }
            if dayStr != nil {
                ElectionItems.ElectionDay = dayStr
            } else {
                ElectionItems.ElectionDay = "Undecided"
            }
            UpcomingElections.append(ElectionItems)
        }
        
        DispatchQueue.main.async {
        //self.newsTitleLabel.text = titleStr
            self.tableView.reloadData()
        }
    }
    
    func printElection(_ election: NSManagedObject) {
        let theElection = election.value(forKey: "name") as? String
        let theDate = election.value(forKey: "date") as? String
        print("Name: \(theElection!), date = \(theDate!)")
    }
    
    func fetchElections() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Election")
        var elections: [NSManagedObject] = []
        do {
            elections = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getElections error: \(error)")
        }
        return elections
    }

}
