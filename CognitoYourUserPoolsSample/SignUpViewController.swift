//
//  SignUpViewController.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var pool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    //@IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var givenName: TextFieldPaddingExtension!
    @IBOutlet weak var familyName: TextFieldPaddingExtension!
    @IBOutlet weak var email: TextFieldPaddingExtension!
    @IBOutlet weak var phone: TextFieldPaddingExtension!
    @IBOutlet weak var password: TextFieldPaddingExtension!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        dismissKeyboard()
        
        givenName.delegate = self
        familyName.delegate = self
        email.delegate = self
        phone.delegate = self
        password.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? ConfirmSignUpViewController {
            //signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser(self.email.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func dismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        givenName.resignFirstResponder()
        familyName.resignFirstResponder()
        email.resignFirstResponder()
        phone.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 240
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        guard let userNameValue = self.email.text, !userNameValue.isEmpty,
            let passwordValue = self.password.text, !passwordValue.isEmpty,
            let givenNameValue = self.givenName.text, !givenNameValue.isEmpty,
            let familyNameValue = self.familyName.text, !familyNameValue.isEmpty,
            let phoneValue = self.phone.text, !phoneValue.isEmpty else {
                let alertController = UIAlertController(title: "Missing Required Fields",
                                                        message: "Please make sure every field is filled out.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
        }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let phoneValue = self.phone.text, !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = "+1\(phoneValue)"
            attributes.append(phone!)
        }
        
        if let emailValue = self.email.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        if let givenNameValue = self.givenName.text, !givenNameValue.isEmpty {
            let givenName = AWSCognitoIdentityUserAttributeType()
            givenName?.name = "given_name"
            givenName?.value = givenNameValue
            attributes.append(givenName!)
        }
        
        if let familyNameValue = self.familyName.text, !familyNameValue.isEmpty {
            let familyName = AWSCognitoIdentityUserAttributeType()
            familyName?.name = "family_name"
            familyName?.value = familyNameValue
            attributes.append(familyName!)
        }
        
        //sign up the user
        self.pool?.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:sender)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            return nil
        }
    }
}
