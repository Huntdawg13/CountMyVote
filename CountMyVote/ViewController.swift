//
//  ViewController.swift
//  CountMyVote
//
//  Created by user190086 on 4/30/21.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var MainImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MainImage.image = UIImage(named: "Vote2021.jpeg")
    }
    
    @IBAction func BallotMapTapped(_ sender: UIButton) {
    }

    @IBAction func WebpageTapped(_ sender: UIButton) {
        
        let url = URL(string: "https://www.vote411.org/washington")
        let safariVC = SFSafariViewController(url: url!)
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func LatestNewsTapped(_ sender: UIButton) {
    }
    
    @IBAction func LatestElectionsTapped(_ sender: UIButton) {
    }
    
    @IBAction func YourCandidatesTapped(_ sender: UIBarButtonItem) {
    }
}

