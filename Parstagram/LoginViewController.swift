//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Eugene Song on 10/14/22.
//

import UIKit
import Parse // to get ready for Parse Login



class LoginViewController: UIViewController {

    @IBOutlet weak var instaLogoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func pressedSignInButton(_ sender: UIButton) {
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { user, error in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
            // The login failed. Check error to see why.
                print("Error: \(error?.localizedDescription)")
          }
    }
    }
    
    @IBAction func pressedSignUpButton(_ sender: UIButton) {
        
        let user = PFUser()
        user.username = usernameTextField.text!
        user.password = passwordTextField.text!
        
                                // bool type , error type
        user.signUpInBackground { (success, error) in
            
            // if something went wrong
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                // prints the entire error description
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
