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
  private var locationList: [CLLocation] = [] {
    didSet {
      if let location = locationList.first {
        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        mapView.animate(to: cameraPosition)
        showMarker(position: cameraPosition.target)
      }
    }
  }
  
  let trackingPath: GMSMutablePath = GMSMutablePath()
  let trackingPolyline: GMSPolyline = GMSPolyline()
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    setupLocation()
    setupMap()
  }
  
  private func setupLocation() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }
  
  private func setupMap() {
    mapView.settings.myLocationButton = true
  }

  private  func showMarker(position: CLLocationCoordinate2D){
    let marker = GMSMarker()
    marker.position = position
    marker.title = "Current Location"
    marker.snippet = "snippet"
    marker.map = mapView
  }
}

extension HomeViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let newLocationCoordinate = locations.last!.coordinate
   
 
    for newLocation in locations {

      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        
        let lastLocation2D = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        
        self.mapView.animate(toLocation: lastLocation2D)
        
        trackingPath.add(locations.last!.coordinate)

        mapView.clear()

        trackingPolyline.path = trackingPath
        trackingPolyline.map = mapView
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

