//
//  NewWalkViewController.swift
//  DogWalker
//
//  Created by Lauren Nicole Roth on 6/28/18.
//  Copyright © 2018 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NewWalkViewController: UIViewController {
  
  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  @IBOutlet var mapContainerView: UIView!
  @IBOutlet var mapView: MKMapView!
  
  
  private var walk : Walk?
  private let locationManager = LocationManager.shared
  private var seconds = 0
  private var timer: Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    locationManager.stopUpdatingLocation()
  }
  
  @IBAction func startTapped() {
    startWalk()
  }
  
  @IBAction func stopTapped() {
    let alertController = UIAlertController(title: "End walk?",
                                            message: "Do you wish to end your walk?",
                                            preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.stopWalk()
      self.saveWalk()
      self.performSegue(withIdentifier: .details, sender: nil)
    })
    alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
      self.stopWalk()
      _ = self.navigationController?.popToRootViewController(animated: true)
    })
    
    present(alertController, animated: true)
  }
  
  private func startWalk() {
    launchPromptStackView.isHidden = true
    dataStackView.isHidden = false
    startButton.isHidden = true
    stopButton.isHidden = false
    mapContainerView.isHidden = false
    mapView.removeOverlays(mapView.overlays)
    
    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    startLocationUpdates()
  }
  
  private func stopWalk() {
    launchPromptStackView.isHidden = false
    dataStackView.isHidden = true
    startButton.isHidden = false
    stopButton.isHidden = true
    mapContainerView.isHidden = true
    
    locationManager.stopUpdatingLocation()
  }
  
  func eachSecond() {
    seconds += 1
    updateDisplay()
  }
  
  private func updateDisplay() {
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.minutesPerMile)
    
    distanceLabel.text = "Distance:  \(formattedDistance)"
    timeLabel.text = "Time:  \(formattedTime)"
    paceLabel.text = "Pace:  \(formattedPace)"
  }
  
  private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }
  
  private func saveWalk() {
    let newWalk = Walk(context: CoreDataStack.context)
    newWalk.distance = distance.value
    newWalk.duration = Int16(seconds)
    newWalk.timestamp = Date()
    
    for location in locationList {
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newWalk.addToLocations(locationObject)
    }
    
    CoreDataStack.saveContext()
    
    walk = newWalk
  }
}

// MARK: - Navigation

extension NewWalkViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "WalkDetailsViewController"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! WalkDetailsViewController
      destination.walk = walk
    }
  }
}

// MARK: - Location Manager Delegate

extension NewWalkViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.add(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}

// MARK: - Map View Delegate

extension NewWalkViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}
