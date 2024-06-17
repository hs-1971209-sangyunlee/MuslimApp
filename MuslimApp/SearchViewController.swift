//
//  SearchViewController.swift
//  MuslimApp
//
//  Created by Sangyun on 2024/06/14.
//

import UIKit

class SearchViewController: UIViewController {


    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var restaurants: [Restaurant] = []
    var searchingRestaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate 및 DataSource 설정
        tableView.delegate = self
        tableView.dataSource = self
  
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        loadRestaurantData()
        
    }
    
    // JSON 파일 읽기 및 마커 생성
    func loadRestaurantData() {
        if let url = Bundle.main.url(forResource: "restaurantData", withExtension: "json") {
            print("Found restaurantData.json at path: \(url.path)")
            do {
                let data = try Data(contentsOf: url)
                print("Data loaded from file: \(data)")
                let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                self.restaurants = restaurants
                self.searchingRestaurants = restaurants
                tableView.reloadData() //테이블뷰 갱신
                print("Successfully loaded and parsed restaurantData.json")
            } catch {
                print("Failed to load or parse restaurantData.json: \(error.localizedDescription)")
            }
        } else {
            print("Could not find restaurantData.json")
        }
    }
    
    @IBAction func searchEdtingChanged(_ sender: UITextField) {
        if let searchText = sender.text, !searchText.isEmpty {
            searchingRestaurants = restaurants.filter { restaurant in
                return restaurant.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            searchingRestaurants = restaurants
        }
        tableView.reloadData()
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchingRestaurants.count // Restaurant 배열의 개수만큼 행을 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewCell", for: indexPath) as! SearchTableViewCell
        let restaurant = searchingRestaurants[indexPath.row]
        cell.title.text = restaurant.title
        cell.type.text = restaurant.type
        cell.address.text = restaurant.address
        cell.menu.text = restaurant.menu
//        cell.textLabel?.text = restaurant.title // Restaurant의 title을 셀에 설정
        return cell
    }
    
    //테이블 뷰 셀 선택시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = searchingRestaurants[indexPath.row]
        guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else { return }
        restaurantDetailViewController.restaurant = restaurant
        // UINavigationController를 사용하여 push 방식으로 화면 전환
        self.navigationController?.pushViewController(restaurantDetailViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
}

extension SearchViewController {
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
}
