//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameField: UIStackView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    var isSignIn:Bool = true
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    var ref:FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }
        }
        usernameField.isHidden = true
    }
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        
        isSignIn = !isSignIn
        
        if isSignIn{
            usernameField.isHidden = true
            signLabel.text = "Sign In"
            loginButton.setTitle("Sign In", for: .normal)
        }
        else{
            usernameField.isHidden = false
            signLabel.text = "Register"
            loginButton.setTitle("Register", for: .normal)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
       ref = FIRDatabase.database().reference()
        
        if let email = emailTextField.text, let pass = passwordTextView.text{
            
            if isSignIn{
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: {(user,error) in
                    //check if user exist
                    if user != nil{
                        MeasurementHelper.sendLoginEvent()
                        self.emailTextField.text = ""
                        self.passwordTextView.text=""
                        
                        self.performSegue(withIdentifier: "signedIn", sender: self)

                    }
                    else{
                        //throw error
                         print("Error is = \(error?.localizedDescription)")
                    }
                
                })
                
            }else{
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: {(user,error) in
                    //check if user exist
                if user != nil{
                    MeasurementHelper.sendLoginEvent()
                    let changeRequest = user?.profileChangeRequest()
                    changeRequest?.displayName = self.usernameTextField.text
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("Error is = \(error.localizedDescription)")
                        } else {
                            // Profile updated.
                        }
                    }
                    self.emailTextField.text = ""
                    self.passwordTextView.text=""
                    self.usernameTextField.text = ""
                    let stats: [String:Int] = [ "currentStreak": 0,
                                                      "longestStreak": 0,
                                                      "daysActive": 1,
                                                      "avgWordcount": 0,
                                                      "totalWordcount": 0,
                                                      "totalEntries": 0
                                                      ]
                    let badges: [String:Bool] = [:]
                    self.ref.child("users").child(user!.uid).setValue(["Provider": "email",
                                                                       "Email": email,
                                                                       "Date": self.dateToString(),
                                                                       "Stats": stats,
                                                                       "Badges": badges])
                    self.performSegue(withIdentifier: "signedIn", sender: self)
                    myBadges = BadgeClass()
                    
                    
                }
                else{
                    print("Error is = \(error?.localizedDescription)")
                    print("register error")
                }
                    
            })
            
        }
        
        }
    }
    
    func dateToString() -> String{
        let dateform = DateFormatter()
        dateform.dateFormat = "MMM dd, yyyy"
        
        return dateform.string(from: NSDate() as Date)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextView.resignFirstResponder()
    }
}
