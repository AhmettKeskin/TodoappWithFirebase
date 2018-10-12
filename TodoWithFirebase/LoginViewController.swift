//
//  LoginViewController.swift
//  TodoWithFirebase
//
//  Created by Ahmet on 7.10.2018.
//  Copyright © 2018 Ahmet Keskin. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var currentUser: User!

class LoginViewController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Kullanıcı zaten login ise direk ana sayfayı açıyoruz
        if Auth.auth().currentUser != nil {
            currentUser = Auth.auth().currentUser
            navigateToTodolistPage()
        }
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    fileprivate func navigateToTodolistPage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
        let navCon = UINavigationController(rootViewController: vc)
        UIApplication.shared.windows.first?.rootViewController = navCon
    }
    
}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil { return }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self] (authResult, error) in
            if error != nil { return }
            currentUser = authResult?.user
            self?.navigateToTodolistPage()
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
    
}

/* Custom login/sign-in button'u yapsaydık buradan takip edebilirdik sign-in akışını  */
extension LoginViewController: GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("inWillDispatch")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("present")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismiss")
    }
    
}

