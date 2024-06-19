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
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var mosqueButton: UIButton!
    
    
    var restaurants: [Restaurant] = []
    var searchingRestaurants: [Restaurant] = []
    var mosques: [Mosque] = []
    var searchingMosques: [Mosque] = []
    var isRestaurant = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate 및 DataSource 설정
        tableView.delegate = self
        tableView.dataSource = self
  
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        loadRestaurantData()
        loadMosqueData()
        
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
    
    func loadMosqueData() {
        if let url = Bundle.main.url(forResource: "mosqueData", withExtension: "json") {
            print("Found restaurantData.json at path: \(url.path)")
            do {
                let data = try Data(contentsOf: url)
                print("Data loaded from file: \(data)")
                let mosques = try JSONDecoder().decode([Mosque].self, from: data)
                self.mosques = mosques
                self.searchingMosques = mosques
                tableView.reloadData() //테이블뷰 갱신
                print("Successfully loaded and parsed restaurantData.json")
            } catch {
                print("Failed to load or parse restaurantData.json: \(error.localizedDescription)")
            }
        } else {
            print("Could not find restaurantData.json")
        }
    }
    
    @IBAction func restaurantTouch(_ sender: UIButton) {
        if (!isRestaurant){
            restaurantButton.setTitleColor(.link, for: .normal)
            mosqueButton.setTitleColor(.lightGray, for: .normal)
            isRestaurant = true
            tableView.reloadData()
        }
        
    }
    
    @IBAction func mosqueTouch(_ sender: UIButton) {
        if (isRestaurant){
            restaurantButton.setTitleColor(.lightGray, for: .normal)
            mosqueButton.setTitleColor(.link, for: .normal)
            isRestaurant = false
            tableView.reloadData()
        }
    }
    
    @IBAction func searchEdtingChanged(_ sender: UITextField) {
        if let searchText = sender.text, !searchText.isEmpty {
                if isRestaurant {
                    searchingRestaurants = restaurants.filter { restaurant in
                        return restaurant.title.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchingMosques = mosques.filter { mosque in
                        return mosque.title.lowercased().contains(searchText.lowercased())
                    }
                }
            } else {
                searchingRestaurants = restaurants
                searchingMosques = mosques
            }
            tableView.reloadData()
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isRestaurant {
                return searchingRestaurants.count
            } else {
                return searchingMosques.count
            }
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewCell", for: indexPath) as! SearchTableViewCell

            if isRestaurant {
                let restaurant = searchingRestaurants[indexPath.row]
                cell.title.text = restaurant.title
                cell.type.text = restaurant.type
                cell.address.text = restaurant.address
                cell.menu.text = restaurant.menu
            } else {
                let mosque = searchingMosques[indexPath.row]
                cell.title.text = mosque.title
                cell.type.text = mosque.type
                cell.address.text = mosque.address
                cell.menu.text = ""
            }

            return cell
        }
    
    //테이블 뷰 셀 선택시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let placeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlaceDetailViewController") as? PlaceDetailViewController else { return }
        if(isRestaurant){
            placeDetailViewController.restaurant = searchingRestaurants[indexPath.row]
        }else{
            placeDetailViewController.mosque = searchingMosques[indexPath.row]
        }
        placeDetailViewController.isRestaurant = isRestaurant
        // UINavigationController를 사용하여 push 방식으로 화면 전환
        self.navigationController?.pushViewController(placeDetailViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isRestaurant {
            return 80.0 // 레스토랑 셀의 높이
        } else {
            return 60.0 // 모스크 셀의 높이
        }
    }
}

extension SearchViewController {
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
}
