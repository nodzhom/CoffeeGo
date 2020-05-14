//
//  ViewController.swift
//  CoffeeGo
//
//  Created by Onur Com on 5.05.2020.
//  Copyright © 2020 Onur Com. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SafariServices

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var venues = [Result]()
    let locationManager = CLLocationManager()
    let networkManager = NetworkManager()
    
    //Dummy data
    let stadiums = [Stadium(name: "Emirates Stadium", latitude: 51.5549, longitude: -0.108436),
                    Stadium(name: "Stamford Bridge", latitude: 51.4816, longitude: -0.191034),
                    Stadium(name: "White Hart Lane", latitude: 51.6033, longitude: -0.065684),
                    Stadium(name: "Olympic Stadium", latitude: 51.5383, longitude: -0.016587),
                    Stadium(name: "Old Trafford", latitude: 53.4631, longitude: -2.29139),
                    Stadium(name: "Anfield", latitude: 53.4308, longitude: -2.96096)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        mapView.delegate = self
        locationManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if CLLocationManager.locationServicesEnabled() {
            checkAuthorizationStatus()
        } else {
            //show alert to prompt to turn it on
        }
        
        getCurrentLocation()
        
        //addStatidumsToMap(stadiums: stadiums)
        
        
        //London
        //let startingArea = CLLocationCoordinate2D(latitude: 51.4816, longitude: -0.191034)
        
        //Munich
        //let startingArea = CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820)
        //let coordinateRegion = MKCoordinateRegion(center: startingArea, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        //mapView.setRegion(coordinateRegion, animated: true)
        
        
        //self.networkManager.getCoffeeShopsAt(latitude: "51.4816", longitude: "-0.191034")
    }
    
    
    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .authorizedAlways:
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: break
        // Show alert telling users how to turn on permissions
        case .denied: break
            // Show an alert letting them know what’s up
            
        @unknown default:
            fatalError("App crashed")
        }
    }
    
    func getCurrentLocation() {
        locationManager.requestLocation()
    }
    
    @IBAction func centerOnCurrentLocationTapped(_ sender: UIButton) {
       getCurrentLocation()
    }
    
    func requestDirectionsTo(location: CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .walking

        let directions = MKDirections(request: request)
        mapView.removeOverlays(mapView.overlays)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                
                //testing making the table view smaller
//                self.tableView.translatesAutoresizingMaskIntoConstraints = false
//
//                UIView.animate(withDuration: 2) {
//                    NSLayoutConstraint.activate([
//                        self.tableView.heightAnchor.constraint(equalToConstant: 100)
//                    ])
//                }
                
                

            }
        }

    }
    
    //dummy func
    func addStatidumsToMap(stadiums: [Stadium]) {
        for stadium in stadiums {
            let annotations = MKPointAnnotation()
            annotations.title = stadium.name
            annotations.coordinate = CLLocationCoordinate2D(latitude: stadium.latitude, longitude: stadium.longitude)
            mapView.addAnnotation(annotations)
            
        }
    }
    
    func addCoffeeShopsToMap(coffeeShops:[Result]) {
        DispatchQueue.main.async {
            for coffeeShop in coffeeShops {
                
                let annotation = MKPointAnnotation()
                annotation.title = coffeeShop.venue.name
                annotation.subtitle = coffeeShop.venue.location.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: coffeeShop.venue.location.lat, longitude: coffeeShop.venue.location.lng)
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    
}

//MARK: - NetworkManager Function
extension MapViewController: NetworkManagerDelegate {
    func didGetCoffeeShops(networkManager: NetworkManager, venues: [Result]) {
        DispatchQueue.main.async {
            self.venues = venues
            self.tableView.reloadData()
            self.addCoffeeShopsToMap(coffeeShops: venues)
        }
        
    }
    
}

//MARK: - CoreLocation Delegate Functions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1250, longitudinalMeters: 1250)
                self.mapView.setRegion(region, animated: true)
                //self.mapView.setCenter(location.coordinate, animated: true)
                self.networkManager.getCoffeeShopsAt(latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
                print("This is your current location: lat:\(location.coordinate.latitude) lng:\(location.coordinate.longitude)")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong with location manager")
    }
    
}
//MARK: - MapKit Delegate Functions
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "pin40")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemBlue
        return renderer
    }
    
}

//MARK: - UITableView Functions
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 70
        
        let nib = UINib(nibName: "CGTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CGTableViewCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CGTableViewCell") as! CGTableViewCell
        cell.nameLabel.text = venues[indexPath.row].venue.name
        cell.addressLabel.text = venues[indexPath.row].venue.location.address ?? "No adress"
        cell.distanceLabel.text = "\(String(venues[indexPath.row].venue.location.distance)) m"
        
        let distanceInMinutesAndSecond = (Double(venues[indexPath.row].venue.location.distance) / 1.4) / 60
        cell.timeLabel.text = "\(String(format: "%.1f", distanceInMinutesAndSecond)) min"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCafeLocation = CLLocationCoordinate2D(latitude: venues[indexPath.row].venue.location.lat, longitude: venues[indexPath.row].venue.location.lng)
//        let cafeRegion = MKCoordinateRegion(center: selectedCafeLocation, latitudinalMeters: 250, longitudinalMeters: 250)
//        self.mapView.setRegion(cafeRegion, animated: true)
        
        let selectedAnnotation = self.mapView.annotations.firstIndex(where: {$0.title == venues[indexPath.row].venue.name})!
        self.mapView.selectAnnotation(mapView.annotations[selectedAnnotation], animated: true)
        
        requestDirectionsTo(location: selectedCafeLocation)
        
        //debug
        print("tableview selection \(venues[indexPath.row].venue.name)")
        print("annotation selection\(self.mapView.annotations[indexPath.row].title)")
    }
}
