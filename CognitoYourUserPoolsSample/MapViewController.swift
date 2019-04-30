//
//  MapViewController.swift
//  ConSEAerge
//
//  Created by Sandley Guo on 12/17/18.
//  Copyright © 2018 Sandley Guo. All rights reserved.
//

import MapKit
import CoreLocation
import UIKit
import AWSCognitoIdentityProvider

class MapViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var navMenu: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var currentLocation: UIButton!
    @IBOutlet weak var greyLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var navLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropOffLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView!

    var locationManager = CLLocationManager()
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    var menuAppear = false
    var bookItAppear = false
    var dropOffAppear = false
    var pickUpAppear = false
    var paymentAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        self.refresh()
        
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        dismissKeyboard()
        
        searchField.delegate = self
        
        navMenu.layer.shadowOpacity = 1
        navMenu.layer.shadowRadius = 3
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
        beachLocation()
    }
    
    func beachLocation() {
        let locations = [
            ["title": "Monmouth Beach",    "latitude": 40.330298, "longitude": -73.973762],
            ["title": "Ocean Grove Beach", "latitude": 40.305000, "longitude": -73.977562]
        ]
        
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location["title"] as? String
            annotation.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! Double, longitude: location["longitude"] as! Double)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation {
            print("Your annotation title: \(annotation.title)");
            //bookItAppear = !bookItAppear
            bookItMenuAppear()
        }
    }
    
    @IBAction func menuButton(_ sender: Any) {
        if (menuAppear) {
            //navLeadingConstraint.constant = -315
            //UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
            //greyLeadingConstraint.constant = -414
            menuDisappear()
        } else {
            navLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
            greyLeadingConstraint.constant = 0
        }
        
        menuAppear = !menuAppear
    }
    
    @IBAction func parkingButton(_ sender: Any) {
        bookItMenuDisappear()
        bookItAppear = !bookItAppear
        dropOffMenuAppear()
    }
    
    @IBAction func allParkingButton(_ sender: Any) {
        bookItMenuDisappear()
        bookItAppear = !bookItAppear
        dropOffMenuAppear()
    }
    
    @IBAction func toPickUpButton(_ sender: Any) {
        dropOffMenuDisappear()
        dropOffAppear = !dropOffAppear
        pickUpMenuAppear()
    }
    
    @IBAction func toPaymentButton(_ sender: Any) {
        pickUpMenuDisappear()
        pickUpAppear = !pickUpAppear
        paymentMenuAppear()
    }
    
    @IBAction func paymentToMapButton(_ sender: Any) {
        paymentMenuDisappear()
        paymentAppear = !paymentAppear
    }
    
    
    func menuDisappear() {
        navLeadingConstraint.constant = -315
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
        greyLeadingConstraint.constant = -414
    }
    
    func bookItMenuAppear() {
        if (bookItAppear) {
            bookItMenuDisappear()
        } else {
            bookLeadingConstraint.constant = 448
            self.view.layoutIfNeeded()
            greyLeadingConstraint.constant = 0
        }
        bookItAppear = !bookItAppear
    }
    
    func dropOffMenuAppear() {
        if (dropOffAppear) {
            dropOffMenuDisappear()
        } else {
            dropOffLeadingConstraint.constant = 448
            self.view.layoutIfNeeded()
            greyLeadingConstraint.constant = 0
        }
        dropOffAppear = !dropOffAppear
    }
    
    func pickUpMenuAppear() {
        if (pickUpAppear) {
            pickUpMenuDisappear()
        } else {
            pickUpLeadingConstraint.constant = 448
            self.view.layoutIfNeeded()
            greyLeadingConstraint.constant = 0
        }
        pickUpAppear = !pickUpAppear
    }
    
    func paymentMenuAppear() {
        if (paymentAppear) {
            paymentMenuDisappear()
        } else {
            paymentLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
            self.view.layoutIfNeeded()
        }
        paymentAppear = !paymentAppear
    }
    
    func bookItMenuDisappear() {
        bookLeadingConstraint.constant = -448
        self.view.layoutIfNeeded()
        greyLeadingConstraint.constant = -414
    }
    
    func dropOffMenuDisappear() {
        dropOffLeadingConstraint.constant = -448
        self.view.layoutIfNeeded()
        greyLeadingConstraint.constant = -414
    }
    
    func pickUpMenuDisappear() {
        pickUpLeadingConstraint.constant = -448
        self.view.layoutIfNeeded()
        greyLeadingConstraint.constant = -414
    }
    
    func paymentMenuDisappear() {
        paymentLeadingConstraint.constant = -414
        self.view.layoutIfNeeded()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                //navLeadingConstraint.constant = -315
                //UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
                //greyLeadingConstraint.constant = -414
                menuDisappear()
                menuAppear = !menuAppear
            case UISwipeGestureRecognizer.Direction.down:
                //navLeadingConstraint.constant = -315
                //UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
                //greyLeadingConstraint.constant = -414
                bookItMenuDisappear()
                bookItAppear = !bookItAppear
                dropOffMenuDisappear()
                dropOffAppear = !dropOffAppear
                pickUpMenuDisappear()
                pickUpAppear = !pickUpAppear
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func dismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchField.resignFirstResponder()
    }
    
    @IBAction func signOut(_ sender: Any) {
        menuDisappear()
        menuAppear = !menuAppear
        self.user?.signOut()
        //self.title = nil
        self.response = nil
        //self.tableView.reloadData()
        self.refresh()
    }

    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                //self.title = self.user?.username
                //self.tableView.reloadData()
            })
            return nil
        }
    }
    
}
