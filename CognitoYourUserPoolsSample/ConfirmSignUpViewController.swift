//
//  ConfirmSignUpViewController.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class ConfirmSignUpViewController : UIViewController {
    
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.text = self.user!.username;
        self.sentToLabel.text = "We sent an access code to your email address."
    }
    
    // MARK: IBActions
    
    // handle confirm sign up
    @IBAction func confirm(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.code.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation code missing.",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        self.user?.confirmSignUp(self.code.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    let alertController = UIAlertController(title: "Account Verified",
                                                            message: "Your account has been verified.",
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Log In", style: .default, handler: {action in let _ = strongSelf.navigationController?.popToRootViewController(animated: true)} )
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                }
            })
            return nil
        }
    }
    
    // handle code resend action
    @IBAction func resend(_ sender: AnyObject) {
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Resent",
                                                            message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }
    
}
