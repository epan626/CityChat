
//  LoadingViewController.swift
//  chat
//
//  Created by Eric Pan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation


class LoadingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingMapView: MKMapView!
    var currentLocation: CLLocation?
    var locationManager = CLLocationManager()
    var city: Dictionary<String, Any>?
    var cityCoordinates: CLLocationCoordinate2D?
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    var user = [User]()
    var test: String?

    //MARK: Views
    override func viewDidLoad() {

        super.viewDidLoad()


        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.loadingMapView.showsUserLocation = true
            self.currentLocation = self.locationManager.location
        }
        locationManager.delegate = self
        continueButton.isHidden = true
        loadingMapView.delegate = self
       // progress bar animation
        UIView.animate(withDuration: 3.0, animations: { () -> Void in
            self.progressView.setProgress(0.0, animated: true)
        })
//        logout
//                do{
//                    try FIRAuth.auth()?.signOut()
//                } catch {
//                    let alert = UIAlertController(title: "Invalid", message: "There was an issue logging out. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }

    }
    override func viewDidAppear(_ animated: Bool) {

        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.findChatroom(completion: {
                self.zoomInOnUserLocation(completion: {
                    let when = DispatchTime.now() + 0.1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        if FIRAuth.auth()?.currentUser?.uid != nil {
                            let loggedUserId = FIRAuth.auth()?.currentUser?.uid
                            FIRDatabase.database().reference().child("users").child(loggedUserId!).observe(.value, with: { (snapshot) in
                                guard let loggedInUserInfo = snapshot.value as? [String: AnyObject] else{
                                    return
                                }
                                let user = User()
                                user.setValuesForKeys(loggedInUserInfo)
                                self.user.append(user)
                            }, withCancel: nil)
                            self.loadingLabel.isHidden = true
                            self.continueButton.addTarget(self, action: #selector(self.performChatDisplaySegue), for: .touchUpInside)
                            if let cityName = self.city?["city"]{
                                self.continueButton.setTitle("Continue to the \(cityName) chat", for: .normal)
                                self.continueButton.isHidden = false
                            } else{
                                self.continueButton.setTitle("Sorry, there are no chatrooms available near you", for: .normal)
                                self.continueButton.isHidden = false
                            }
                            
                        } else {
                            self.loadingLabel.isHidden = true
                            self.continueButton.setTitle("Please login or register to continue", for: .normal)
                            self.continueButton.addTarget(self, action: #selector(self.performLogRegSegue), for: .touchUpInside)
                            self.continueButton.isHidden = false
                        }
                    }
                })
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.progressView.setProgress(2.0, animated: true)
        })
    }
    
    //MARK: Helpers
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
//        print("I AM IN THE DIDCHANGEAUTHORIZATIONSECTION")
//        if status == CLAuthorizationStatus.denied{
//            locationManager.requestWhenInUseAuthorization()
//        } else if status == CLAuthorizationStatus.authorizedAlways{
//            print("already authorized")
//        } else{
//            print("NO MATCH")
//        }
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                self.performSegue(withIdentifier: "cityChatSegue", sender: snapshot)
            }, withCancel: nil)
            
        } else {
            let when = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                let mvc = self.storyboard?.instantiateViewController(withIdentifier: "logRegController")
                self.present(mvc!, animated: true, completion: nil)
            }
            
        }
    }
    
    func zoomInOnUserLocation(completion: @escaping () -> ()){
        guard let latitude = self.city?["lat"] as? CLLocationDegrees else{
            completion()
            return
        }
        guard let longitude = self.city?["lng"] as? CLLocationDegrees else{
            completion()
            return
        }
        let cityCenterLocation = CLLocation(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(0.16, 0.16)
        let region = MKCoordinateRegionMake(cityCenterLocation.coordinate, span)
        loadingMapView.setRegion(region, animated: true)
        completion()
    }
    
    func findChatroom(completion: @escaping () -> ()){
        print("finding chatroom")
        FIRDatabase.database().reference().child("city-locations").observe(.value, with: { (snapshot) in
            
            guard let cities = snapshot.value as? NSArray else{
                return
            }

            guard let latitude = self.currentLocation?.coordinate.latitude, let longitude = self.currentLocation?.coordinate.longitude else{
                print("THE LOCATION IS NOT SET")
                return
            }
            
            let coordinate0 = CLLocation(latitude: latitude, longitude: longitude)

            for city in cities{
                let comparisonCity = city as! Dictionary<String, Any>
                let coordinate1 = CLLocation(latitude: comparisonCity["lat"] as! CLLocationDegrees, longitude: comparisonCity["lng"] as! CLLocationDegrees)
                let distanceInMeters = coordinate0.distance(from: coordinate1)
                print(distanceInMeters)
                if distanceInMeters < 7500.00{
                    self.city = comparisonCity
                    let cityCenterCoordinates = CLLocationCoordinate2D(latitude: comparisonCity["lat"] as! CLLocationDegrees, longitude: comparisonCity["lng"] as! CLLocationDegrees)
                    self.cityCoordinates = cityCenterCoordinates
                    let circle = MKCircle(center: cityCenterCoordinates, radius: 7500.00)
                    self.loadingMapView.add(circle)
                    completion()
                }
            }
            
            
        }, withCancel: nil)
        completion()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.lightGray
            circleRenderer.alpha = 0.3
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cityChatSegue" {
            if let tabVC = segue.destination as? UITabBarController {
                tabVC.selectedIndex = 1
                let loggedUser = self.user[0]
                if let chatroomController = tabVC.viewControllers?[1] as? allChatController{
                    chatroomController.user = loggedUser
                    chatroomController.city = self.city
                }
                if let navController = tabVC.viewControllers?[0] as? UINavigationController{
                    if let userListController = navController.topViewController as? UserListViewController{
                        print("I'M SETTING THE DIRECT MESSAGE CONTROLLER USER")
                        userListController.user = loggedUser
                    }
                }
            }
        } else{
            if let logRegController = segue.destination as? MainViewController{
                logRegController.city = self.city
            }
        }
    }
    
    func performLogRegSegue(){
        performSegue(withIdentifier: "loginRegSegue", sender: self)
    }
    
    func performChatDisplaySegue(){
        performSegue(withIdentifier: "cityChatSegue", sender: self)
    }
}
