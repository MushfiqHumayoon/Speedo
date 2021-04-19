//
//  ViewController.swift
//  Speedo
//
//  Created by Mushfiq Humayoon on 17/04/21.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Global Variables
    var locationManager: CLLocationManager = CLLocationManager()
    private var geocoder: CLGeocoder!
    
    var currentLocation: CLLocation!
    var traveledDistance:Double = 0
    var arrayKMPH: [Double]! = []
    var isRiding: Bool = false
    var startedPlace: String = String()
    var endedPlace: String = String()

    //MARK: IBoutlets
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var distanceTraveled: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var ridingStatusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        geocoder = CLGeocoder()
        UITabBar.appearance().tintColor = UIColor.red
        isRiding = false
        // Ask for Location Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        if isRiding {
            if startedPlace == "" {
                getRiderLocation(ended: false, location: location)
            }
            if location.horizontalAccuracy > 0 {
                updateLocationInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, speed: location.speed)
            }
            if currentLocation != nil {
                traveledDistance += currentLocation.distance(from: locations.last!)
                if traveledDistance < 1000 {
                    let tdMeter = traveledDistance
                    distanceTraveled.text = (String(format: "%.0f M", tdMeter))
                } else if traveledDistance > 1000 {
                    let tdKm = traveledDistance / 1000
                    distanceTraveled.text = (String(format: "%.1f KM", tdKm))
                }
            }
        }
        getRiderLocation(ended: true, location: location)
        currentLocation = location
    }

    func updateLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, speed: CLLocationSpeed) {
        // 3.6 km/h = 1 m/s, the SI unit of speed, metre per second
        let speedToKilometerPerHour = (speed * 3.6)
        // Checking if speed is less than zero
        if (speedToKilometerPerHour > 0) {
            speedDisplay.text = (String(format: "%.0f", speedToKilometerPerHour))
            arrayKMPH.append(speedToKilometerPerHour)
            averageSpeed()
        } else {
            speedDisplay.text = "0"
        }
    }

    //MARK: Calculate Average Speed
    func averageSpeed(){
        let speed:[Double] = arrayKMPH
        let speedAverage = speed.reduce(0, +) / Double(speed.count)
        avgSpeedLabel.text = (String(format: "%.0f km/h", speedAverage))
    }

    //MARK: Start Ride
    @IBAction func startRide(sender: AnyObject) {
        guard isRiding else {
            traveledDistance = 0
            locationManager.startUpdatingLocation()
            isRiding = true
            ridingStatusLabel.text = "Riding Started, Stay be Healthy!"
            return
        }
        ridingStatusLabel.text = "Already Started Riding, focus on your ride!"
    }
    //MARK: Stop Ride
    @IBAction func stopRide(sender: AnyObject) {
        guard !isRiding else {
            locationManager.stopUpdatingLocation()
           
            isRiding = false
            self.saveToRidingHistory()
            ridingStatusLabel.text = "Riding Stopped, Take some Rest!"
            return
        }
        ridingStatusLabel.text = "Start the Ride to Stop it!"
    }
    //MARK: Offline Storage, Core Data
    func saveToRidingHistory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "History", in: context)
            else{
                print("couldn't find entity History")
                return
        }
        let newRideHistory = NSManagedObject(entity: entity, insertInto: context)
        newRideHistory.setValue(startedPlace, forKey: "startedLocation")
        newRideHistory.setValue(endedPlace, forKey: "endedLocation")
        newRideHistory.setValue(avgSpeedLabel.text, forKey: "averageSpeed")
        newRideHistory.setValue(distanceTraveled.text, forKey: "distanceTraveled")
        newRideHistory.setValue(Date(), forKey: "date")
        do {
           try context.save()
          } catch {
           print("Failed saving")
        }
    }
    //MARK: Get Rider Current Location as Descriptive
    func getRiderLocation(ended: Bool, location: CLLocation) {
        self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) in
            if let place = placemarks?.first?.name {
                if ended {
                    self.endedPlace = place
                }else {
                    self.startedPlace = place
                }
            }
        })
    }
}
