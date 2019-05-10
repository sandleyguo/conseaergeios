//
//  MapViewController.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//

import MapKit
import CoreLocation
import UIKit
import AWSCognitoIdentityProvider

class MapViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var navMenu: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var currentLocation: UIButton!
    @IBOutlet weak var greyLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var navLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropOffLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var carLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropOffPicker: UIDatePicker!
    @IBOutlet weak var pickUpPicker: UIDatePicker!
    @IBOutlet weak var carMake: UIPickerView!
    @IBOutlet weak var carModel: UIPickerView!
    
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
    var carAppear = false
    
    var modelList: [String] = [String]()
    var makeList: [String] = [String]()
    
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
        
        modelData()
        makeData()
        
        carMake.dataSource = self
        carMake.delegate = self
        
        carModel.dataSource = self
        carModel.delegate = self
        
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
            bookItMenuAppear()
        }
    }
    
    func modelData() {
        modelList = ["4Runner", "Auris", "Auris Touring Sports", "Avensis", "Avensis Touring Sports", "Avensis Verso", "Avensis Wagon", "Aygo", "C-HR", "Camry", "Camry Customwagon", "Camry Stationwagon", "Carina", "Carina Combi", "Carina E", "Carina E Stationwagon", "Carina II", "Carina II Stationwagon", "Celica", "Celica Convertible", "Celica Coupe", "Celica Liftback", "Corolla", "Corolla Combi", "Corolla Coupe", "Corolla Liftback", "Corolla Stationwagon", "Corolla Verso", "Corolla Wagon", "Corona", "Cressida", "Cressida Combi", "Cressida Hardtop", "Crown", "Crown Combi", "Funcruiser", "Funcruiser Hardtop", "Funcruiser Softtop", "Funcruiser Wagon", "GT86", "Hilux", "Hilux Dubbele Cabine", "iQ", "Land Cruiser",  "MR2", "Paseo", "Picnic", "Previa", "Prius",  "Proace Shuttle", "RAV4", "Starlet", "Starlet Combi", "Supra", "Tercel", "Urban Cruiser", "Verso", "Yaris"]
    }
    
    func makeData() {
        makeList = ["Abarth", "Alfa Romeo", "Asia Motors", "Aston Martin", "Audi", "Austin", "Autobianchi", "Bentley", "BMW", "Bugatti", "Buick", "Cadillac", "Carver", "Chevrolet", "Chrysler", "Citroen", "Corvette", "Dacia", "Daewoo", "Daihatsu", "Daimler", "Datsun", "Dodge", "Donkervoort", "DS", "Ferrari", "Fiat", "Fisker", "Ford", "FSO", "Galloper", "Honda", "Hummer", "Hyundai", "Infiniti", "Innocenti", "Jaguar", "Jeep", "Josse", "Kia", "Lada", "Lamborghini", "Lancia", "Land Rover", "Landwind", "Lexus", "Lincoln", "Lotus", "Marcos", "Maserati", "Maybach", "Mazda", "McLaren", "Mega", "Mercedes", "Mercury", "MG", "Mini", "Mitsubishi", "Morgan", "Morris", "Nissan", "Noble", "Opel", "Peugeot", "PGO", "Pontiac", "Porsche", "Princess", "Renault", "Rolls-Royce", "Rover", "Saab", "Seat", "Skoda", "Smart", "Spectre", "SsangYong",  "Subaru", "Suzuki", "Talbot", "Tesla", "Think", "Toyota", "Triumph", " TVR", " Volkswagen", "Volvo", "Yugo", "Others"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows : Int = modelList.count
        if pickerView == carMake {
            countrows = self.makeList.count
        }
        
        return countrows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return modelList[row]
        
        if pickerView == carModel {
            let titleRow = modelList[row]
            return titleRow
        } else if pickerView == carMake {
            let titleRow = makeList[row]
            return titleRow
        }
        
        return ""
    }
    
    @IBAction func menuButton(_ sender: Any) {
        if (menuAppear) {
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
    
    @IBAction func toCarButton(_ sender: Any) {
        pickUpMenuDisappear()
        pickUpAppear = !pickUpAppear
        carMenuAppear()
    }
    
    @IBAction func toPaymentButton(_ sender: Any) {
        carMenuDisappear()
        carAppear = !carAppear
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
    
    func carMenuAppear() {
        if (carAppear) {
            carMenuDisappear()
        } else {
            carLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded() })
            self.view.layoutIfNeeded()
        }
        carAppear = !carAppear
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
    
    func carMenuDisappear() {
        carLeadingConstraint.constant = -414
        self.view.layoutIfNeeded()
    }
    
    func paymentMenuDisappear() {
        paymentLeadingConstraint.constant = -414
        self.view.layoutIfNeeded()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                menuDisappear()
                menuAppear = !menuAppear
            case UISwipeGestureRecognizer.Direction.down:
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
        self.response = nil
        self.refresh()
    }

    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
            })
            return nil
        }
    }
    
}
