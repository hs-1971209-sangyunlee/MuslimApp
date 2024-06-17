
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func loginTouch(_ sender: UIButton) {
        let email: String = emailTextField.text!
        let pw: String = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: pw) {authResult, error in
                if authResult != nil {
                    UserManager.shared.isLoggedIn = true
                    self.errorMessage.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.errorMessage.isHidden = false
                }
            }

    }
    
    @IBAction func logoutTouch(_ sender: UIButton) {
        guard let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return }
                // UINavigationController를 사용하여 push 방식으로 화면 전환
                self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
}

extension LoginViewController{
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
