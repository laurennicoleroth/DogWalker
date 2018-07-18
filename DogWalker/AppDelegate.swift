//
//  AppDelegate.swift
//  DogWalker
//
//  Created by Lauren Nicole Roth on 6/28/18.
//  Copyright © 2018 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UINavigationBar.appearance().tintColor = .gray
    UINavigationBar.appearance().barTintColor = .white
    let locationManager = LocationManager.shared
    locationManager.requestAlwaysAuthorization()
    
    GMSServices.provideAPIKey(googleMapsAPIKey)
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    CoreDataStack.saveContext()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    CoreDataStack.saveContext()
  }
  
}
