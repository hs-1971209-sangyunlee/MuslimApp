
import UIKit
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    var hideBackButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = hideBackButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserManager.shared.isLoggedIn {
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    @IBAction func loginTouch(_ sender: UIButton) {
        let email: String = emailTextField.text!
        let pw: String = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: pw) {authResult, error in
                if authResult != nil {
                    UserManager.shared.isLoggedIn = true
                    UserManager.shared.userId = email
                    
                    let db = Firestore.firestore()
                    let userRef = db.collection("users")
                    
                    userRef.whereField("email", isEqualTo: email).getDocuments{(querySnapshot, error) in if let error = error {
                        print("문서를 가져오지 못함\(error)")
                    } else {
                        if let document = querySnapshot?.documents.first {
                            let data = document.data()
                            UserManager.shared.userName = data["name"] as! String
                            self.errorMessage.isHidden = true
                            self.navigationController?.popViewController(animated: true)
                        } else{
                            print("이메일이 없음")
                        }
                    }}
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
