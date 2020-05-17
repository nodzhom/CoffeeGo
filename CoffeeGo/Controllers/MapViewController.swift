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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        mapView.delegate = self
        locationManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        checkLocationServicesStatus()
        
        getCurrentLocation()
    }

    func checkLocationServicesStatus() {
        if CLLocationManager.locationServicesEnabled() {
            checkAuthorizationStatus()
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Location Services", message: "Please enable location services to use this app", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true)
            }
            
        }
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
            fatalError("Unknown fatal error")
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
                
                let mapEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 300, right: 40)
                
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: mapEdgeInsets, animated: true)
                
            }
        }
    }
    
    func addCoffeeShopsToMap(coffeeShops: [Result]) {
        
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
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "pin40")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        var shopURL = URL(string: "")
        
        for venue in venues {
            if venue.venue.name == view.annotation?.title {
                shopURL = URL(string: venue.snippets.items[0].detail?.object.canonicalUrl ?? "www.google.com")
            }
        }
        
        let safariVC = SFSafariViewController(url: shopURL!)
        safariVC.preferredControlTintColor = .brown
        self.present(safariVC, animated: true, completion: nil)
        
        
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemBlue
        return renderer
    }
    
}

//MARK: - UITableView Functions
extension MapViewController: UITableViewDelegate, UITableViewDataSource, CGTableViewCellDelegate {
    
    func actionButtonTapped(at index: IndexPath) {
        let selectedCafeLocation = CLLocationCoordinate2D(latitude: venues[index.row].venue.location.lat, longitude: venues[index.row].venue.location.lng)
        print(selectedCafeLocation)
        requestDirectionsTo(location: selectedCafeLocation)
        
        let selectedAnnotation = self.mapView.annotations.firstIndex(where: {$0.title == venues[index.row].venue.name})!
        self.mapView.selectAnnotation(mapView.annotations[selectedAnnotation], animated: true)
        tableView.selectRow(at: index, animated: true, scrollPosition: .top)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.rowHeight = 70
        
        let nib = UINib(nibName: "CGTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CGTableViewCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CGTableViewCell") as! CGTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.nameLabel.text = venues[indexPath.row].venue.name
        cell.addressLabel.text = venues[indexPath.row].venue.location.address ?? "No adress"
        cell.distanceLabel.text = "\(String(venues[indexPath.row].venue.location.distance)) m"
        
        let distanceInMinutesAndSeconds = (Double(venues[indexPath.row].venue.location.distance) / 1.4) / 60
        cell.timeLabel.text = "\(String(format: "%.1f", distanceInMinutesAndSeconds)) min"
        

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCafeLocation = CLLocationCoordinate2D(latitude: venues[indexPath.row].venue.location.lat, longitude: venues[indexPath.row].venue.location.lng)
        let cafeRegion = MKCoordinateRegion(center: selectedCafeLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        self.mapView.setRegion(cafeRegion, animated: true)
        
        let selectedAnnotation = self.mapView.annotations.firstIndex(where: {$0.title == venues[indexPath.row].venue.name})!
        self.mapView.selectAnnotation(mapView.annotations[selectedAnnotation], animated: true)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        //debug
        print("tableview selection \(venues[indexPath.row].venue.name)")
        print("annotation selection\(self.mapView.annotations[indexPath.row].title)")
    }
}
