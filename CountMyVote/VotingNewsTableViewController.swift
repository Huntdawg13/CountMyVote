//
//  VotingNewsTableViewController.swift
//  CountMyVote
//
//  Created by user190086 on 5/2/21.
//

import UIKit
import SafariServices

class VotingNewsTableViewController: UITableViewController {
    
    var NewsURLString = "https://newsapi.org/v2/everything?q=voting&apiKey=86461d410bb84b2d9c6ad3c5b33e03b9"
    var NewsArticles = [NewsItem]()
    var loadedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNewsFromServer()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getNewsFromServer() {
        /*let url = URL(string: NewsURLString)
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleResponse)
        dataTask.resume()
         */
        print("working")
        if let urlStr = NewsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                let dataTask = URLSession.shared.dataTask(with: url, completionHandler: handleResponse)
                dataTask.resume()
            }
        }
    }
    
    
    @IBAction func UpdateNewsTapped(_ sender: UIBarButtonItem) {
        print("also working")
        NewsArticles = []
        loadedImages = []
        getNewsFromServer()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return NewsArticles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoterArticle", for: indexPath)
        print("made it into cell")
        // Configure the cell...
        let theArticle = NewsArticles[indexPath.row]
        cell.textLabel?.text = "\(theArticle.NewsTitle!)"
        cell.detailTextLabel?.text = "\(theArticle.NewsSource!)"
        if loadedImages.count > indexPath.row {
            cell.imageView?.image = loadedImages[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theArticle = NewsArticles[indexPath.row]
        let url = URL(string: theArticle.NewsURL!)
        let safariVC = SFSafariViewController(url: url!)
        present(safariVC, animated: true, completion: nil)

        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
              let articleArray = jsonDict1["articles"] as? [Any],
              articleArray.count > 0,
              let jsonDict2 = articleArray[0] as? [String: Any],
              let titleStr = jsonDict2["title"] as? String,
              let URLStr = jsonDict2["url"] as? String,
              let sourceStr = jsonDict2["source"] as? [String: Any],
              let sourceNameStr = sourceStr["name"] as? String,
              let urlToImage = jsonDict2["urlToImage"] as? String else {
                    print("error: invalid JSON data")
                    return
              }
            print(jsonDict1)
        
        // 6. Everything seems okay
        //self.loadNewsImage(urlToImage)
        print("\(titleStr) by \(sourceNameStr) accessed at \(URLStr) with image \(urlToImage)")
        for article in articleArray {
            let article = article as? [String: Any]
            let titleStr = article!["title"] as? String
            let URLStr = article!["url"] as? String
            let sourceStr = article!["source"] as? [String: Any]
            let sourceNameStr = sourceStr!["name"] as? String
            let urlToImage = article!["urlToImage"] as? String
            
            var NewsItems = NewsItem()
            if titleStr != nil {
                NewsItems.NewsTitle = titleStr
            } else {
                NewsItems.NewsTitle = "NO TITLE"
            }
            if URLStr != nil {
                NewsItems.NewsURL = URLStr
            } else {
                NewsItems.NewsURL = "https://google.com"
            }
            if sourceNameStr != nil {
                NewsItems.NewsSource = sourceNameStr
            } else {
                NewsItems.NewsSource = "Source Unknown"
            }
            NewsItems.imageURL = urlToImage
            NewsArticles.append(NewsItems)
        }
        
        DispatchQueue.main.async {
        //self.newsTitleLabel.text = titleStr
            self.tableView.reloadData()
        }
        
        for Article in NewsArticles {
            if Article.imageURL != nil {
                loadNewsImage(Article.imageURL!)
            } else {
                loadNewsImage("https://previews.123rf.com/images/lineartestpilot/lineartestpilot1603/lineartestpilot160329231/54021744-freehand-drawn-cartoon-newspaper.jpg")
            }
        }
    }
    
    func loadNewsImage(_ urlString: String) {
    // URL comes from API response; definitely needs some safety checks
        if let urlStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                let dataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self.loadedImages.append(image!)
                            self.tableView.reloadData()
                        }
                    }
                })
                dataTask.resume()
            }
        }
    }

}
