//
//  AppDelegate.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-09-20.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import SendBirdSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let sendBirdAppId = "1754D364-8F39-4A56-9BB4-56C864B30871"
    private let sendBirdApiToken = "cf5e77a80465353ccaac33a7c520fa51fa753a46"

    var window: UIWindow?
    var locationManager: CLLocationManager?
    let userDefaults = UserDefaults()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // configure google login services
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        // get current user location
        getUserLocation()

        SBDMain.initWithApplicationId(Constants.sendBirdAppId)
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // do not monitor location changes in the backgroud
        locationManager?.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // start monitoring location changes in the foreground
        locationManager?.startUpdatingLocation()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }

    // Google sign in support
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

}

// MARK: - Location

extension AppDelegate: CLLocationManagerDelegate {

    fileprivate func getUserLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }

        // get the location manager
        locationManager = CLLocationManager()
        locationManager!.delegate = self

        // get user authorization if necesary
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // request authorization
            locationManager!.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // already authorized
            break
        default:
            // authorization rejected
            return
        }

        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        // start monitoring user location changes
        locationManager!.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userDefaults.set("\(location.coordinate.latitude)", forKey: Constants.latKey)
            userDefaults.set("\(location.coordinate.longitude)", forKey: Constants.lonKey)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error!!")
        print(error)
    }

}

