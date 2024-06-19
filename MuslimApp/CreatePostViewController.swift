import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CreatePostViewController: UIViewController {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var detailTextView: UITextView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var loadingIndicator: UIActivityIndicatorView!
    var loadingBackgroundView: UIView!
    
    private var originalBottomConstraint: CGFloat = 0
    private var originalTopConstraint: CGFloat = 0
    var restaurant : Restaurant?
    var mosque : Mosque?
    var isRestaurant = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 로딩 배경 뷰 초기화 및 설정
        loadingBackgroundView = UIView(frame: view.bounds)
        loadingBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingBackgroundView.isHidden = true
        view.addSubview(loadingBackgroundView)
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingBackgroundView.addSubview(loadingIndicator)

        originalBottomConstraint = bottomConstraint.constant
        originalTopConstraint = topConstraint.constant
        
        cameraImageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(capturePicture))
        cameraImageView.addGestureRecognizer(imageTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func capturePicture(sender: UITapGestureRecognizer){
        // 사진찍는 별도의 UIViewController가 UIImagePickerController이다.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이를 설정하면 사진을 찍은후 호출된다
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        // 카메라가 있다면 카메라로부터
        imagePickerController.sourceType = .camera
        }else{
        // 카메라가 없으면 앨범으로부터
        imagePickerController.sourceType = .savedPhotosAlbum
        }
        // 시뮬레이터는 카메라가 없으므로, 실 아이폰의 경우 이라인 삭제
        imagePickerController.sourceType = .savedPhotosAlbum
        // UIImagePickerController이 전이 된다
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardSize.cgRectValue.height
            bottomConstraint.constant = keyboardHeight
            topConstraint.constant -= keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = originalBottomConstraint
        topConstraint.constant = originalTopConstraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //등록
    @IBAction func postCreateTouch(_ sender: UIButton) {
        let userId = UserManager.shared.userId
        let userName = UserManager.shared.userName
        let placeId = isRestaurant ? restaurant?.id : mosque?.id
        let title = isRestaurant ? restaurant?.title : mosque?.title
        let detail = detailTextView.text ?? ""
        
        let db = Firestore.firestore()
        let newPostRef = db.collection("posts").document()
        
        var postData: [String: Any] = [
            "title": title,
            "detail": detail,
            "userName": userName,
            "userId": userId,
            "placeId": placeId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // 로딩 인디케이터 시작
        loadingBackgroundView.isHidden = false
        loadingIndicator.startAnimating()
        
        //이미지 있으면 이미지는 파이어스토리지, 이미지경로는 다른 정보와 함께 파이어베이스에 저장
        if let image = cameraImageView.image, let imageData = image.jpegData(compressionQuality: 0.3) {
            let imagePath = "posts/\(newPostRef.documentID).jpg"
            let storageRef = Storage.storage().reference().child(imagePath)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: metaData) { metadata, error in
                if let error = error {
                            print("Error uploading image: \(error)")
                    self.loadingBackgroundView.isHidden = true
                    self.loadingIndicator.stopAnimating()
                            return
                        }
                        
                        postData["image"] = imagePath
                        newPostRef.setData(postData) { error in
                            self.loadingBackgroundView.isHidden = true
                            self.loadingIndicator.stopAnimating()
                            if let error = error {
                                print("Error adding document: \(error)")
                                
                            } else {
                                print("Document added with ID: \(newPostRef.documentID)")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                } else {
                    newPostRef.setData(postData) { error in
                        self.loadingBackgroundView.isHidden = true
                        self.loadingIndicator.stopAnimating()
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added with ID: \(newPostRef.documentID)")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
        
    }
    
}

extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    // 반드시 UINavigationControllerDelegate도 상속받아야 한다
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey :
    Any]) {
    // UIImage를 가져온다
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    // 여기서 이미지에 대한 추가적인 작업을 한다
        cameraImageView.image = image // 화면에 보일 것이다.
    // imagePickerController을 죽인다
    picker.dismiss(animated: true, completion: nil)
    }
    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // imagePickerController을 죽인다
    picker.dismiss(animated: true, completion: nil)
    }
}

extension CreatePostViewController{
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        detailTextView.resignFirstResponder()
    }
}


