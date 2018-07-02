//
//  HomeViewController.swift
//  DogWalker
//
//  Created by Lauren Nicole Roth on 6/28/18.
//  Copyright © 2018 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class HomeViewController: UIViewController {
  
  @IBOutlet var mapView: GMSMapView!
  private let locationManager = LocationManager.shared
  private var seconds = 0
  private var timer: Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startLocationUpdates()
  }
  
  private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }
  
  private func findUserOnMap(at location: CLLocationCoordinate2D) {
    locationManager.requestLocation()
    mapView.settings.myLocationButton = true
    let cameraPosition = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
    mapView.animate(to: cameraPosition)
    
  }
}

extension HomeViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if let location = locations.first {
      print("Found user's location: \(location)")
      findUserOnMap(at: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
    }

    for newLocation in locations {

      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        //        mapView.add(MKPolyline(coordinates: coordinates, count: 2))
        //        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
        //        mapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
  
  
  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}

