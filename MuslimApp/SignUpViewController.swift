
import UIKit
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func startPasswordEditing(_ sender: UITextField) {
        stackViewTopConstraint.constant -= 100
    }
    
    @IBAction func endPasswordEditing(_ sender: UITextField) {
        stackViewTopConstraint.constant += 100
    }
    @IBAction func startPasswordCheckEditing(_ sender: UITextField) {
        stackViewTopConstraint.constant -= 150
    }
    
    @IBAction func endPasswordCheckEditing(_ sender: UITextField) {
        stackViewTopConstraint.constant += 150
    }
    
    @IBAction func signUpTouch(_ sender: UIButton) {
        // 필드 검증 로직 추가
        guard let name = nameTextField.text, !name.isEmpty else {
            showErrorMessage("이름을 입력해주세요")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showErrorMessage("이메일을 입력해주세요")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorMessage("이메일 형식에 맞지 않습니다.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showErrorMessage("비밀번호를 입력해주세요")
            return
        }
        
        guard let passwordCheck = passwordCheckTextField.text, !passwordCheck.isEmpty else {
            showErrorMessage("비밀번호 확인을 입력해주세요")
            return
        }
        
        guard password == passwordCheck else {
            showErrorMessage("비밀번호가 다릅니다.")
            return
        }
        
        
        errorMessage.isHidden = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showErrorMessage(error.localizedDescription)
                        return
                    }
                    
                    guard let user = authResult?.user else { return }
                    
                    // Firestore에 사용자 정보 저장
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "name": name,
                        "email": email
                    ]) { error in
                        if let error = error {
                            self.showErrorMessage("회원가입에 실패했습니다: \(error.localizedDescription)")
                        } else {
                            self.showErrorMessage("회원가입에 성공했습니다!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
    }
    func showErrorMessage(_ message: String) {
        errorMessage.text = message
        errorMessage.isHidden = false
    }
    // 이메일 형식 검증 함수
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPred = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}

extension SignUpViewController{
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordCheckTextField.resignFirstResponder()
    }
}
