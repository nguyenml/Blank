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
import TextFieldEffects
import ChameleonFramework


class SignInViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var choiceStack: UIStackView!
    @IBOutlet weak var registerChoice: UIButton!
    @IBOutlet weak var signInChoice: UIButton!
    @IBOutlet weak var formStack: UIStackView!
    @IBOutlet weak var switchControl: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var isSignIn:Bool = true
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextView.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        setupView()
        
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }
        }
        usernameTextField.isHidden = false
        isSignIn = false
    }
    
    //TODO
    func keyboardSafety(){
        //TODO
    }
    
    func setupView(){
        view.backgroundColor = UIColor.flatSkyBlue
        formStack.isHidden = true
        formStack.isUserInteractionEnabled = false
        loginButton.isHidden = true
        loginButton.isUserInteractionEnabled = false
        switchControl.isHidden = true
        switchControl.isUserInteractionEnabled = false
    }
    
    func goToForms(){
        formStack.isHidden = false
        formStack.isUserInteractionEnabled = true
        loginButton.isHidden = false
        loginButton.isUserInteractionEnabled = true
        switchControl.isHidden = false
        switchControl.isUserInteractionEnabled = true
    }
    
    //changes the form from signin to signup
    @IBAction func signInSelectorChanged(_ sender: UIButton) {
        
        isSignIn = !isSignIn
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextView.text = ""
        
        if isSignIn{
            usernameTextField.isHidden = true
            loginButton.setTitle("Authenticate", for: .normal)
            switchControl.setTitle("Don't have an account? Sign up now.", for: .normal)
        }
        else{
            usernameTextField.isHidden = false
            loginButton.setTitle("Register", for: .normal)
            switchControl.setTitle("Already have an account?", for: .normal)
            usernameTextField.isHidden = false
        }
    }
    
    @IBAction func registerChoice(_ sender: UIButton) {
        choiceStack.isUserInteractionEnabled = false;
        choiceStack.isHidden = true
        goToForms()
        isSignIn = false
        resetChoiceForm()
    }
    
    func resetChoiceForm(){
        
        if isSignIn{
            usernameTextField.isHidden = true
            loginButton.setTitle("Authenticate", for: .normal)
            switchControl.setTitle("Don't have an account? Sign up now.", for: .normal)
        }
        else{
            usernameTextField.isHidden = false
            loginButton.setTitle("Register", for: .normal)
            switchControl.setTitle("Already have an account?", for: .normal)
            usernameTextField.isHidden = false
        }
        
    }
    
    @IBAction func signInChoice(_ sender: UIButton) {
        choiceStack.isUserInteractionEnabled = false;
        choiceStack.isHidden = true
        goToForms()
        isSignIn = true
        resetChoiceForm()
    }
    
    //function to signin/create user
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
                         print("Error is = \(String(describing: error?.localizedDescription))")
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
                                                      "avgWordcount": 0,
                                                      "totalWordcount": 0,
                                                      "totalEntries": 0,
                                                      ]
                    let badges: [String:Bool] = [:]
                    let lastAccess:String = "Apr 1, 2017 11:00 AM"
                    self.ref.child("users").child(user!.uid).setValue(["Provider": "email",
                                                                       "Email": email,
                                                                       "Date": self.dateToString(),
                                                                       "Stats": stats,
                                                                       "Badges": badges,
                                                                       "LastAccess": lastAccess])
                    self.performSegue(withIdentifier: "signedIn", sender: self)
                    myBadges = BadgeClass()
                    
                    
                }
                else{
                    print("Error is = \(String(describing: error?.localizedDescription))")
                    print("register error")
                }
                    
            })
            
        }
        
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}
