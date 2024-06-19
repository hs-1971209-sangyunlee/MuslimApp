//
//  HomeViewController.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/14.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var ramadanDayLabel: UILabel!
    @IBOutlet weak var postTableView: UITableView!
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backButtonTitle = "뒤로가기"
        postTableView.delegate = self
        postTableView.dataSource = self
        
        updateRamadanDayLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }

    func loadPosts() {
        let db = Firestore.firestore()
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: 5)
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
    
    func updateRamadanDayLabel() {
        // 라마단 시작일과 종료일 설정
        let ramadanStartDateComponents = DateComponents(year: 2025, month: 2, day: 28)
        let ramadanEndDateComponents = DateComponents(year: 2025, month: 3, day: 29)
        let calendar = Calendar.current
        
        guard let ramadanStartDate = calendar.date(from: ramadanStartDateComponents),
              let ramadanEndDate = calendar.date(from: ramadanEndDateComponents) else {
            ramadanDayLabel.text = "라마단 날짜 설정 오류"
            return
        }
        
        // 현재 날짜와 라마단 시작일 및 종료일의 차이 계산
        let currentDate = Date()
        let daysToStart = calendar.dateComponents([.day], from: currentDate, to: ramadanStartDate).day ?? 0
        let daysToEnd = calendar.dateComponents([.day], from: currentDate, to: ramadanEndDate).day ?? 0
        
        // D-day 형식으로 라벨 업데이트
        if daysToStart > 0 {
            ramadanDayLabel.text = "라마단 D-\(daysToStart)"
        } else if daysToStart == 0 {
            ramadanDayLabel.text = "라마단 D-day"
        } else if daysToEnd >= 0 {
            ramadanDayLabel.text = "라마단 진행 중"
        } else {
            ramadanDayLabel.text = "라마단이 종료되었습니다."
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
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
