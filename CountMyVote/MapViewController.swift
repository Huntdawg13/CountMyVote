//
//  MapViewController.swift
//  CountMyVote
//
//  Created by user190086 on 5/2/21.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var startPoint: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSensorAvailability()
        initializeLocation()
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var DistanceTraveledLabel: UILabel!
    
    @IBOutlet weak var NearestBallotLabel: UILabel!
    
    @IBOutlet weak var DistanceLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func StartTapped(_ sender: UIButton) {
        startLocation()
    }
    
    
    @IBAction func StopTapped(_ sender: UIButton) {
        stopLocation()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func checkSensorAvailability() {
        print("location services: " +
                (CLLocationManager.locationServicesEnabled() ? "yes" : "no"))
    }
    
    func initializeLocation() { // called from start up method
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("location authorized")
        case .denied, .restricted:
            print("location not authorized")
            let alert = UIAlertController(title: "Location Services Disabled", message: "Go to device settings and enable location", preferredStyle: .alert)
                let goAction = UIAlertAction(title: "OK", style: .default,
                    handler: { (action) in
                            print("OK")
                    })
            alert.addAction(goAction)
            alert.preferredAction = goAction // only affects .alert style
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("unknown location authorization")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            print("location changed to authorized")
        } else {
            print("location changed to not authorized")
            self.stopLocation()
        }
    }
    
    
    func startLocation () {
        startPoint = locationManager.location
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        let status = locationManager.authorizationStatus
        if (status == .authorizedAlways) ||
            (status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocation () {
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lookupLocation()
        let location = locations.last
        var locationStr = "Location (lat,long): "
        if let latitude = location?.coordinate.latitude {
            locationStr += String(format: "%.6f", latitude)
        } else {locationStr += "?"}
        if let longitude = location?.coordinate.longitude {
            locationStr += String(format: ", %.6f", longitude)
        } else {locationStr += ", ?"}
        print(locationStr)
        searchMap("Auditor's office")
        let distanceTraveled = (locationManager.location?.distance(from: startPoint!))
        DistanceTraveledLabel.text = "Distance traveled: \(String(format: "%.0f", distanceTraveled!)) meters"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager error: \(error.localizedDescription)")
    }
    
    func lookupLocation() {
        if let location = locationManager.location {
            geoCoder.reverseGeocodeLocation(location, completionHandler: geoCodeHandler)
        }
    }
    
    func geoCodeHandler (placemarks: [CLPlacemark]?, error: Error?) {
        if let placemark = placemarks?.first {
            print("placemark= \(placemark)")
        }
    }
    
    func searchMap(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: searchHandler)
    }
    
    func searchHandler (response: MKLocalSearch.Response?, error: Error?) {
        if let err = error {
            print("Error occured in search: \(err.localizedDescription)")
            NearestBallotLabel.text = "Nearest Ballot Box: ?"
            DistanceLabel.text = "Distance: ?"
        } else if let resp = response {
            print("\(resp.mapItems.count) matches found")
            self.mapView.removeAnnotations(self.mapView.annotations)
            var closestHospital = resp.mapItems[0]
            var closestHospitalDistance = (locationManager.location?.distance(from: closestHospital.placemark.location!))!
            for item in resp.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
                if (locationManager.location!.distance(from: item.placemark.location!)) < closestHospitalDistance {
                    closestHospital = item
                    closestHospitalDistance = (locationManager.location?.distance(from: item.placemark.location!))!
                }
            }
            NearestBallotLabel.text = "Nearest Ballot Box: \(closestHospital.name!))"
            DistanceLabel.text = "Distance: \(String(format: "%.0f", closestHospitalDistance)) meters"
    
        }
    }

}
