//
//  ForgotPasswordViewController.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//
import Foundation
import AWSCognitoIdentityProvider

class ForgotPasswordViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? ConfirmForgotPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    
    // MARK :- IBActions
    
    // handle forgot password
    @IBAction func forgotPassword(_ sender: AnyObject) {
        guard let username = self.username.text, !username.isEmpty else {

            let alertController = UIAlertController(title: "Missing Username",
                                                    message: "Please enter a valid username.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user = self.pool?.getUser(self.username.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                        message: error.userInfo["message"] as? String,
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    strongSelf.performSegue(withIdentifier: "confirmForgotPasswordSegue", sender: sender)
                }
            })
            return nil
            } 
    }
}
