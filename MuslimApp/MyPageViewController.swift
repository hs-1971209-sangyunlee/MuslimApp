import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class MyPageViewController: UIViewController {
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var postTableView: UITableView!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        //checkLoginStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkLoginStatus()
        nameLabel.text = UserManager.shared.userName
        emailLabel.text = UserManager.shared.userId

        loadPosts()
    }
    func checkLoginStatus() {
        if !UserManager.shared.isLoggedIn {
            moveToLogin()
        }
    }
    
    func loadPosts() {
        let db = Firestore.firestore()
        let userId = UserManager.shared.userId
        
        db.collection("posts")
            .whereField("userId", isEqualTo: userId)
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

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell", for: indexPath) as! PostTableViewCell

            let post = posts[indexPath.row]
            cell.postDetail.text = post.detail
            cell.postTitle.text = post.title

            
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
