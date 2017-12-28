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


class SignInViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var choiceStack: UIView!
    @IBOutlet weak var formStack: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerChoice: UIButton!
    @IBOutlet weak var signInChoice: UIButton!
    @IBOutlet weak var switchControl: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var isSignIn:Bool = true
    var isRegister:Bool = false
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true

        passwordTextView.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        setupView()
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                if self.isRegister { return }
                MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }else{
                self.view.isHidden = false
            }
        }
        usernameTextField.isHidden = false
        isSignIn = false
        //keyboardSafety()
    }
    
    //TODO
    func keyboardSafety(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        loginButton.isHidden = true
        loginButton.isUserInteractionEnabled = false
        switchControl.isHidden = true
        switchControl.isUserInteractionEnabled = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
        loginButton.isHidden = false
        loginButton.isUserInteractionEnabled = true
        switchControl.isHidden = false
        switchControl.isUserInteractionEnabled = true
    }
    
    func setupView(){
        view.backgroundColor = UIColor(hex: 0xF3F3F3)
        formStack.isHidden = true
        formStack.isUserInteractionEnabled = false
        loginButton.isHidden = true
        loginButton.layer.cornerRadius = 10
        loginButton.isUserInteractionEnabled = false
        switchControl.isHidden = true
        switchControl.isUserInteractionEnabled = false
        registerChoice.layer.cornerRadius = 10
        signInChoice.layer.cornerRadius = 10
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
        
        errorLabel.text = ""
        isSignIn = !isSignIn
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextView.text = ""
        
        if isSignIn{
            usernameTextField.isHidden = true
            usernameTextField.isUserInteractionEnabled = false
            loginButton.setTitle("A U T H E N T I C A T E", for: .normal)
            switchControl.setTitle("Don't have an account? Sign up now.", for: .normal)
        }
        else{
            usernameTextField.isHidden = false
            usernameTextField.isUserInteractionEnabled = true
            loginButton.setTitle("R E G I S T E R", for: .normal)
            switchControl.setTitle("Already have an account? Log in.", for: .normal)
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
                print("signed in")
                isRegister = false
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: {(user,error) in
                    //check if user exist
                    if user != nil{
                        MeasurementHelper.sendLoginEvent()
                        self.emailTextField.text = ""
                        self.passwordTextView.text=""
                        
                        self.performSegue(withIdentifier: "segueToIntro", sender: self)

                    }
                    else{
                        self.errorLabel.text = "Invalid username or password"
                    }
                
                })
                
            }else{
                print("not signed in")

                isRegister = true
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: {(user,error) in
                    //check if user exist
                if user != nil{
                    MeasurementHelper.sendLoginEvent()
                    let changeRequest = user?.profileChangeRequest()
                    changeRequest?.displayName = self.usernameTextField.text
                    changeRequest?.commitChanges { error in
                        if error != nil {
                            print("success")
                        } else {
                            print("no success")
                            print(error?.localizedDescription)
                        }
                    }
                    user?.sendEmailVerification { (error) in
                        print("could not send email")
                    }
                    self.emailTextField.text = ""
                    self.passwordTextView.text=""
                    self.usernameTextField.text = ""
                    let stats: [String:Int] = [ "currentStreak": Int(UInt32(0)),
                                                      "longestStreak": Int(UInt32(0)),
                                                      "avgWordcount": Int(UInt32(0)),
                                                      "totalWordcount": Int(UInt32(0)),
                                                      "totalEntries": Int(UInt32(0)),
                                                      "totalTime":Int(UInt32(0)),
                                                      ]
                    let badges: [String:Bool] = [:]
                    let lastAccess:String = "Apr 1, 2017 11:00 AM"
                    self.ref.child("users").child(user!.uid).setValue(["Provider": "email",
                                                                       "Email": email,
                                                                       "Date": self.dateToString(),
                                                                       "Stats": stats,
                                                                       "Badges": badges,
                                                                       "LastAccess": lastAccess])
                    
                    
                    self.ref.child("Settings").child("userCount").observe(FIRDataEventType.value, with: {
                        (snapshot) in
                        
                        var value = snapshot.value as! Int
                        value = value + 1
                        self.ref.child("Settings").child("userCount").setValue(value)
                        
                    })
                    myBadges = BadgeClass()
                    self.performSegue(withIdentifier: "segueToIntro", sender: self)

                    
                }
                else{
                    if let error = error {
                        self.errorLabel.text = String(describing: error.localizedDescription)
                    }
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
        usernameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
}
