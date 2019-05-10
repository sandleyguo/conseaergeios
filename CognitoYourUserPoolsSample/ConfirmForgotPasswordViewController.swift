//
//  ConfirmForgotPasswordViewController.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class ConfirmForgotPasswordViewController: UIViewController {
    
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var confirmationCode: UITextField!
    @IBOutlet weak var proposedPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    
    @IBAction func updatePassword(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.confirmationCode.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Password Field Empty",
                                                    message: "Please enter a password of your choice.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue, password: self.proposedPassword.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion: nil)
                } else {
                    //TODO: CONFIRM BACK TO SIGN IN
                    let alertController = UIAlertController(title: "Password Reset",
                                                            message: "Your password has been reset.",
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Log In", style: .default, handler: {action in let _ = strongSelf.navigationController?.popToRootViewController(animated: true)}  )
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                    //let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        }
    }
    
}
