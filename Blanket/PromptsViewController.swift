//
//  PromptsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 1/26/18.
//  Copyright © 2018 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class PromptsViewController: UIViewController {

    @IBOutlet weak var promptType: UITextField!
    
    @IBOutlet weak var prompt: UITextView!
   
    @IBOutlet weak var promptHash: UITextField!
    
    var ref:FIRDatabaseReference?
    var count = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToFB(){
        var mdata = [String:String]()
        mdata[Constants.Prompt.type] = promptType.text
        mdata[Constants.Prompt.prompt] = prompt.text
        mdata[Constants.Prompt.hash] = promptHash.text
        mdata[Constants.Prompt.number] = String(count)
        ref?.child("Prompts").childByAutoId().setValue(mdata)
    }
    
    
    @IBAction func enter(_ sender: UIButton) {
        addToFB()
        count += 1
        promptType.text = ""
        prompt.text = ""
        promptHash.text = ""
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
