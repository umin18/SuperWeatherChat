//
//  HomeController.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/22/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit
import TWMessageBarManager
import SVProgressHUD
import GooglePlaces
import CoreLocation
import ViewAnimator
import TransitionButton

class HomeController: CustomTransitionViewController, CLLocationManagerDelegate {
    
    var user1 : UserModel?
    var weekWeather = [Weather]()
    var earthQuakeLocs = [Location]()
    
    var location : CLLocation?
    var locationManager = CLLocationManager()

    @IBOutlet weak var collectionV: UICollectionView!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeZoneLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var mainWeatherImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionV.delegate = self
        collectionV.dataSource = self
        
        setUpLocation()
        setUpImgView()
        getUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateCollection()
        getUserInfo()
    }
    
    func animateCollection() {
        collectionV?.reloadData()
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 1)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/5)
        
        collectionV?.performBatchUpdates({
            UIView.animate(views: collectionV.visibleCells,
            animations: [zoomAnimation, rotateAnimation, fromAnimation],
            duration: 1)
        }, completion: nil)
    }
    
    func setUpLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func setUpImgView() {
        userImgView.layer.borderWidth = 4
        userImgView.layer.borderColor = #colorLiteral(red: 1, green: 0.6112429371, blue: 0.6917650963, alpha: 0.5)
        userImgView.layer.cornerRadius = userImgView.frame.size.width / 2
        userImgView.clipsToBounds = true
    }
    
    func getUserInfo() {
    
        SVProgressHUD.show()
        FireBaseServices.shared.getUser { (user1) in
            guard let user = user1
                else {
                    SVProgressHUD.dismiss()
                    TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Couldn't retreive user information", comment: ""), type: .error, duration: 5)
                    return
            }
            
            //set all user info in UI
            DispatchQueue.main.async {
                self.userImgView.image = user.image
                self.userEmailLbl.text = user.email
            }
            
            self.getWeeklyWeather(latitude: self.location?.coordinate.latitude ?? 0, longitude: self.location?.coordinate.longitude ?? 0)
        }
    }
    
    func getWeeklyWeather(latitude : Double, longitude : Double) {
        
        SVProgressHUD.show()
            APIHandler().getWeatherInfo(latitude: latitude, longitude: longitude, completionHandler: { (weather) in
                //Set weather info in UI
                guard let weeklyWeather = weather
                    else {
                        TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Couldn't retreive Weather information", comment: ""), type: .error, duration: 5)
                        return
                    }
                
                DispatchQueue.main.async {
                    self.weekWeather = weeklyWeather
                    self.collectionV.reloadData()
                    self.dateLbl.text = weeklyWeather[0].date
                    self.tempLbl.text = "H : \(weeklyWeather[0].temperatureHigh)F / L : \(weeklyWeather[0].temperatureLow)F"
                    self.timeZoneLbl.text = weeklyWeather[0].timezone
                    self.timeLbl.text = weeklyWeather[0].time
                    self.summaryLbl.text = weeklyWeather[0].summary
                    self.getWeatherIcon(weather: weeklyWeather[0].icon)
                }
                SVProgressHUD.dismiss()
            })
    }
    
    func getWeatherIcon(weather: String) {
        switch weather {
        case "clear-day" :
            self.mainWeatherImgView.image = UIImage(named: "sun")
        case "clear-night" :
            self.mainWeatherImgView.image = UIImage(named: "sun")
        case "rain" :
            self.mainWeatherImgView.image = UIImage(named: "rain")
        case "snow" :
            self.mainWeatherImgView.image = UIImage(named: "snow")
        case "sleet" :
            self.mainWeatherImgView.image = UIImage(named: "sleet")
        case "wind" :
            self.mainWeatherImgView.image = UIImage(named: "windy")
        case "fog" :
            self.mainWeatherImgView.image = UIImage(named: "fog")
        case "cloudy" :
            self.mainWeatherImgView.image = UIImage(named: "cloud")
        case "partly-cloudy-day" :
            self.mainWeatherImgView.image = UIImage(named: "partly-cloudy")
        case "partly-cloudy-night" :
            self.mainWeatherImgView.image = UIImage(named: "partly-cloudy")
        default:
            self.mainWeatherImgView.image = UIImage(named: "sun")
        }
    }
    
    func getEarthQuakeAPI() {
        SVProgressHUD.show()
        APIHandler().getEarthQuakeInfo {
            (locs) in
            guard let locations = locs
                else {
                    SVProgressHUD.dismiss()
                    TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Couldn't retreive EarthQuake information", comment: ""), type: .error, duration: 5)
                    return
            }
            if locations.count > 0 {
                self.earthQuakeLocs = locations
                var coordinates = [[Double]]()
                for loc in locations {
                    coordinates.append(loc.coordinates)
                }
                let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EarthQuakeController") as! EarthQuakeController
                ctrl.coordinates = coordinates
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.navigationController?.pushViewController(ctrl, animated: true)
                }
            } else {
                    TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("No data found!", comment: ""), type: .error, duration: 5)
            }
        }
    }
    
    
    @IBAction func earthQuakeBtn(_ sender: UIButton) {
        getEarthQuakeAPI()
    }
    
    @IBAction func placesBtn(_ sender: UIButton) {
        openStarLocation()
    }
    
}

extension HomeController : GMSAutocompleteViewControllerDelegate {
    
    func openStarLocation() {
        let autoCompleteCtrl = GMSAutocompleteViewController()
        autoCompleteCtrl.delegate = self
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteCtrl, animated: true, completion: nil)
    }
    
    //Mark - GMSAutoCompleteViewControllerDelegate methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error : \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let latitude : Double = place.coordinate.latitude
        let longitude : Double = place.coordinate.longitude
        getWeeklyWeather(latitude: latitude, longitude: longitude)
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension HomeController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatherCollCell
        cell.updateCell(highTemp: weekWeather[indexPath.row].temperatureHigh, lowTemp: weekWeather[indexPath.row].temperatureLow, timezone: weekWeather[indexPath.row].timezone, date: weekWeather[indexPath.row].date, weather: weekWeather[indexPath.row].icon)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dateLbl.text = weekWeather[indexPath.row].date
        timeLbl.text = weekWeather[indexPath.row].time
        timeZoneLbl.text = weekWeather[indexPath.row].timezone
        summaryLbl.text = weekWeather[indexPath.row].summary
        getWeatherIcon(weather: weekWeather[indexPath.row].icon)
        tempLbl.text = "H: \(weekWeather[indexPath.row].temperatureHigh)F/ L: \(weekWeather[indexPath.row].temperatureLow)F"
    }
    
    
}



