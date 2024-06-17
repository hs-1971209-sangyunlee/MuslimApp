
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    var infoView: UIView!
    var infoScrollView: UIScrollView!
    var infoTitle: UILabel!
    var infoDetail: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true //줌 가능
        mapView.showsCompass = true //나침반 표시
        mapView.showsUserLocation = true //사용자 현재 위치 표시

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
    
    func createMarker(latitude: Double, longitude: Double, title: String = "???", subtitle: String = "?????"){
        let marker = MKPointAnnotation()
        
        marker.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.subtitle = subtitle
        mapView.addAnnotation(marker)
    }
    
    func setupInfoView() {
        // infoView 생성 및 설정
        infoView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 200))
        infoView.backgroundColor = .white
        
        // infoTitle 생성 및 설정
        infoTitle = UILabel(frame: CGRect(x: 0, y: 0, width: infoView.frame.width, height: 40))
        infoTitle.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
        // infoScrollView 생성 및 설정
        infoScrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: infoView.frame.width, height: 160))
        infoScrollView.backgroundColor = .white
        infoScrollView.showsVerticalScrollIndicator = true
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.bounces = true
        
        // infoDetail 생성 및 설정
        infoDetail = UILabel(frame: CGRect(x: 16, y: 0, width: infoScrollView.frame.width - 32, height: 150))
        infoDetail.numberOfLines = 0
        
        infoScrollView.addSubview(infoDetail)
        infoView.addSubview(infoTitle)
        infoView.addSubview(infoScrollView)
        view.addSubview(infoView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap() {
        hideInfoView()
    }

    func showInfoView(title: String, detail: String) {
        infoTitle.text = title
        infoDetail.text = detail
        infoDetail.sizeToFit()
        infoScrollView.contentSize = CGSize(width: infoScrollView.frame.width, height: infoDetail.frame.height)
        
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.view.frame.height - 200
        }
    }

    func hideInfoView() {
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.view.frame.height
        }
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
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        print("Annotation coordinates: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude),")
        let restaurant = restaurants.first { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }
        if let restaurant = restaurant {
            let infoTitle = "   \(restaurant.title)"
            let infoDetail = "\(restaurant.address)\n종류: \(restaurant.type)\n연락처: \(restaurant.phone_number)\n메뉴:\(restaurant.menu)\n가격\(restaurant.price)\n기타\n\(restaurant.note)"
            showInfoView(title: infoTitle, detail: infoDetail)
        }else{
            let infoTitle = "???"
            let infoDetail = "종류: ??? \n연락처: ??? \n "
            showInfoView(title: infoTitle, detail: infoDetail)
        }
        // 지도의 중심을 마커 위치로 이동
        let center = annotation.coordinate
        mapView.setCenter(center, animated: true)

    }
}
