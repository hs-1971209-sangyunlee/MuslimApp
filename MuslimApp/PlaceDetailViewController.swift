import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class PlaceDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var noteStackView: UIStackView!
    @IBOutlet weak var postTableView: UITableView!
    
    var restaurant : Restaurant?
    var mosque : Mosque?
    var isRestaurant = true
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        
        titleLabel.text = isRestaurant ? restaurant?.title : mosque?.title
        typeLabel.text = isRestaurant ? restaurant?.type : mosque?.type
        addressLabel.text = isRestaurant ? restaurant?.address : mosque?.address
        phoneLabel.text = isRestaurant ? restaurant?.phone_number : mosque?.phone_number
        if(isRestaurant){
            menuLabel.text = restaurant?.menu
            priceLabel.text = restaurant?.price
            noteLabel.text = restaurant?.note
            menuStackView.isHidden = false
            priceStackView.isHidden = false
            noteStackView.isHidden = false
        }else{
            menuStackView.isHidden = true
            priceStackView.isHidden = true
            noteStackView.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
        print("new loads")
    }
    
    func loadPosts() {
        guard let placeId = isRestaurant ? restaurant?.id : mosque?.id else {
            print("placeId is nil")
            return
        }
        let db = Firestore.firestore()
        db.collection("posts")
            .whereField("placeId", isEqualTo: placeId)
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.posts = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        
                        guard let title = data["title"] as? String,
                              let detail = data["detail"] as? String,
                              let userName = data["userName"] as? String,
                              let userId = data["userId"] as? String,
                              let placeId = data["placeId"] as? String,
                              let timestamp = data["timestamp"] as? Timestamp else {
                            print("Error decoding post data")
                            return nil
                        }
                        
                        let image = data["image"] as? String
                        let post = Post(title: title, detail: detail, userName: userName, userId: userId, image: image, placeId: placeId, timestamp: timestamp.dateValue())
                        
                        return post
                    } ?? []
                    self.postTableView.reloadData()
                }
            }
    }
    
    @IBAction func createPostTouch(_ sender: UIButton) {
        if(UserManager.shared.isLoggedIn){
            guard let createPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController") as? CreatePostViewController else { return }
            if(isRestaurant){
                createPostViewController.restaurant = restaurant
            }else{
                createPostViewController.mosque = mosque
            }
            createPostViewController.isRestaurant = isRestaurant
            // UINavigationController를 사용하여 push 방식으로 화면 전환
            self.navigationController?.pushViewController(createPostViewController, animated: true)
        }else{
            //팝업창 표시
            let alert = UIAlertController(title: "로그인 필요", message: "로그인을 해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                // 확인 버튼을 눌렀을 때 로그인 페이지로 이동
                guard let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                loginViewController.hideBackButton = false
                        self.navigationController?.pushViewController(loginViewController, animated: true)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension PlaceDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell", for: indexPath) as! PostTableViewCell

            let post = posts[indexPath.row]
            cell.postDetail.text = post.detail
            cell.user.text = post.userName
            
            if let imagePath = post.image {
                        let storageRef = Storage.storage().reference().child(imagePath)
                        
                        // 다운로드할 이미지의 최대 크기 10MB
                        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error downloading image: \(error)")
                                return
                            }
                            
                            if let data = data {
                                DispatchQueue.main.async {
                                    cell.postImage.image = UIImage(data: data)
                                }
                            }
                        }
                    }
            
            return cell
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480.0
    }
}
