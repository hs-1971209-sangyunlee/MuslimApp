//
//  MyPageViewController.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/17.
//

import UIKit

class MyPageViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLoginStatus()

    }
    func checkLoginStatus() {
        if !UserManager.shared.isLoggedIn {
            moveToLogin()
        }
    }
    
    @IBAction func logoutTouch(_ sender: UIButton) {
        moveToLogin()
        UserManager.shared.isLoggedIn = false
    }
    
    func moveToLogin(){
        guard let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                // UINavigationController를 사용하여 push 방식으로 화면 전환
                self.navigationController?.pushViewController(loginViewController, animated: true)
    }
}
