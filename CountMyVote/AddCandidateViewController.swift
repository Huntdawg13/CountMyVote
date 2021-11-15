//
//  AddCandidateViewController.swift
//  CountMyVote
//
//  Created by user190086 on 5/1/21.
//

import UIKit
import CoreData

class AddCandidateViewController: UIViewController, UITextFieldDelegate {

    var nameFromAddVC: String?
    var positionFromAddVC: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NameTF.delegate = self
        PositionTF.delegate = self
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var NameTF: UITextField!
    
    @IBOutlet weak var PositionTF: UITextField!
    
    @IBAction func SubmitTapped(_ sender: UIButton) {
        NameTF.endEditing(true)
        nameFromAddVC = NameTF.text
        
        PositionTF.endEditing(true)
        positionFromAddVC = PositionTF.text
        
        performSegue(withIdentifier: "unwind1Submit", sender: nil)
    }
    
    
    @IBAction func CancelTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwind1Cancel", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
