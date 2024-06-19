
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    var mosques: [Mosque] = []
    var infoView: UIView!
    var infoScrollView: UIScrollView!
    var infoTitle: UILabel!
    var infoDetail: UILabel!
    var actionButton: UIButton!
    var clickedRestaurant: Restaurant?
    var clickedMosque: Mosque?
    var isSwitchOn = true

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true // 줌 가능
        mapView.showsCompass = true // 나침반 표시
        mapView.showsUserLocation = true // 사용자 현재 위치 표시

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // 초기 지도의 확대 정도 설정
        let initialLocation = CLLocationCoordinate2D(latitude: 37.556821, longitude: 126.924712)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: initialLocation, span: span)
        mapView.setRegion(region, animated: true)

        loadRestaurantData()
        setupInfoView()
    }

    @IBAction func navigationSwitchClick(_ sender: UISwitch) {
        hideInfoView()
        if(sender.isOn){
            navigationItem.title="할랄 식당 지도"
            loadRestaurantData()
            isSwitchOn = true
        }else{
            navigationItem.title="모스트 지도"
            loadMosqueData()
            isSwitchOn = false
        }
    }
    
    func createMarker(latitude: Double, longitude: Double, title: String = "???", subtitle: String = "?????") {
        let marker = MKPointAnnotation()
        marker.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.subtitle = subtitle
        mapView.addAnnotation(marker)
    }

    func setupInfoView() {
        // infoView 생성 및 설정
        infoView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300))
        infoView.backgroundColor = .white

        // infoTitle 생성 및 설정
        infoTitle = UILabel(frame: CGRect(x: 0, y: 0, width: infoView.frame.width, height: 40))
        infoTitle.backgroundColor = UIColor(red: 0.6, green: 0.9, blue: 0.2, alpha: 1.0)

        // infoDetail 생성 및 설정
        infoDetail = UILabel(frame: CGRect(x: 16, y: 40, width: infoView.frame.width, height: 180))
        infoDetail.numberOfLines = 0

        // actionButton 생성 및 설정
        actionButton = UIButton(frame: CGRect(x: 16, y: 180, width: infoView.frame.width - 32, height: 44))
        actionButton.setTitle("상세 페이지 이동", for: .normal)
        actionButton.backgroundColor = UIColor.blue
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        infoView.addSubview(infoTitle)
        infoView.addSubview(infoDetail)
        infoView.addSubview(actionButton)

        // view에 infoView 추가
        view.addSubview(infoView)

        // 탭 제스처 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    // UIButton 액션 함수
    @objc func actionButtonTapped() {
        guard let placeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlaceDetailViewController") as? PlaceDetailViewController else { return }
        if(isSwitchOn){
            guard let restaurant = clickedRestaurant else {
                print("No restaurant selected.")
                return
            }
            placeDetailViewController.restaurant = restaurant
            placeDetailViewController.isRestaurant = true
        }
        else{
            guard let mosque = clickedMosque else {
                return
            }
            placeDetailViewController.mosque = mosque
            placeDetailViewController.isRestaurant = false
        }
        self.navigationController?.pushViewController(placeDetailViewController, animated: true)
    }

    @objc func handleTap() {
        hideInfoView()
    }

    func showInfoView(title: String, detail: String) {
        infoTitle.text = title
        infoDetail.text = detail
        infoDetail.sizeToFit()

        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.view.frame.height - 300
        }
    }

    func hideInfoView() {
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.view.frame.height
        }
    }

    // JSON 파일 읽기 및 마커 생성
    func loadRestaurantData() {
        mapView.removeAnnotations(mapView.annotations)
        if let url = Bundle.main.url(forResource: "restaurantData", withExtension: "json") {
            print("Found restaurantData.json at path: \(url.path)")
            do {
                let data = try Data(contentsOf: url)
                print("Data loaded from file: \(data)")
                let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                self.restaurants = restaurants
                for (index, restaurant) in restaurants.enumerated() {
                    print("Processing restaurant at index: \(index)")
                    createMarker(latitude: restaurant.latitude, longitude: restaurant.longitude, title: restaurant.title, subtitle: restaurant.address)
                }
                print("Successfully loaded and parsed restaurantData.json")
            } catch {
                print("Failed to load or parse restaurantData.json: \(error.localizedDescription)")
            }
        } else {
            print("Could not find restaurantData.json")
        }
    }
    func loadMosqueData() {
        mapView.removeAnnotations(mapView.annotations)
        if let url = Bundle.main.url(forResource: "mosqueData", withExtension: "json") {
            print("Found restaurantData.json at path: \(url.path)")
            do {
                let data = try Data(contentsOf: url)
                print("Data loaded from file: \(data)")
                let mosques = try JSONDecoder().decode([Mosque].self, from: data)
                self.mosques = mosques
                for (index, mosque) in mosques.enumerated() {
                    print("Processing mosque at index: \(index)")
                    createMarker(latitude: mosque.latitude, longitude: mosque.longitude, title: mosque.title, subtitle: mosque.address)
                }
            } catch {
                print("Failed to load or parse restaurantData.json: \(error.localizedDescription)")
            }
        } else {
            print("Could not find restaurantData.json")
        }
    }

    // CLLocationManagerDelegate 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // 줌 레벨 설정
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    //infoView 내 제스쳐 무시
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // infoView 및 그 서브뷰에서 터치가 발생하면 제스처를 무시
        if let touchedView = touch.view, touchedView.isDescendant(of: infoView) {
            return false
        }
        return true
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        print("Annotation coordinates: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude),")
        
        if(isSwitchOn){
        let restaurant = restaurants.first { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }
        if let restaurant = restaurant {
            let infoTitle = "   \(restaurant.title)"
            let infoDetail = "주소: \(restaurant.address)\n종류: \(restaurant.type)\n연락처: \(restaurant.phone_number)\n메뉴: \(restaurant.menu)\n가격: \(restaurant.price)\n기타: \(restaurant.note)"
            showInfoView(title: infoTitle, detail: infoDetail)
            clickedRestaurant = restaurant
        }
        }else{
            let mosque = mosques.first { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }
            if let mosque = mosque {
                let infoTitle = "   \(mosque.title)"
                let infoDetail = "\(mosque.address)\n종류: \(mosque.type)\n연락처: \(mosque.phone_number)\n"
                showInfoView(title: infoTitle, detail: infoDetail)
                clickedMosque = mosque
            }
        }
        // 지도의 중심을 마커 위치로 이동
        let center = annotation.coordinate
        mapView.setCenter(center, animated: true)
    }
}
