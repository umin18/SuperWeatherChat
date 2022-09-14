//
//  FriendsController.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/24/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit
import TWMessageBarManager
import SVProgressHUD
import ViewAnimator
import SamuraiTransition
import CoreLocation

class FriendsController: BaseViewController, FriendDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var friendsCollecView: UICollectionView!
    var data = [UserModel]()
    var locations = [[String:Any]]()
    
    var location : CLLocation?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsCollecView.delegate = self
        friendsCollecView.dataSource = self
        getFriends()
        setUpLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFriends()
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
    
    func animateCollection() {
        friendsCollecView?.reloadData()
        let fromAnimation = AnimationType.from(direction: .bottom, offset: 130.0)
        let zoomAnimation = AnimationType.zoom(scale: 1)
        
        friendsCollecView?.performBatchUpdates({
            UIView.animate(views: friendsCollecView.visibleCells,
            animations:     [zoomAnimation, fromAnimation],
            duration: 1)
        }, completion: nil)
    }
    
    func removeFriend(index: Int) {
        data.remove(at: index)
        friendsCollecView.reloadData()
    }
    
    func presentView(ctrl: SamuraiViewController) {
        ctrl.samuraiTransition.zan = .horizontal
        ctrl.samuraiTransition.duration = 1.0
        self.present(ctrl, animated: true, completion: nil)
    }
   
    @objc func getFriends() {
        FireBaseServices.shared.getFriends { (usersArr) in
            guard let users = usersArr
                else {
                    SVProgressHUD.dismiss()
                    TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Coundn't retrieve Friends Information", comment: ""), type: .error, duration : 5)
                    return
            }
            
            self.data = users
            if self.data.count == 0 {
                TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Info", comment: ""), description: NSLocalizedString("No Friend Found", comment: ""), type: .info, duration: 5)
            } else {
                self.friendsCollecView.reloadData()
            }
        }
    }
    
    @IBAction func reloadData(_ sender: UIButton) {
        getFriends()
    }
    
    @IBAction func mapBtn(_ sender: UIButton) {
        let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MAPController") as! MAPController
        ctrl.locations = locations
        navigationController?.pushViewController(ctrl, animated: true)
    }
    
}

extension FriendsController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FriendCollecCell
        cell.delegate = self
        cell.updateCell(img: data[indexPath.row].image, name: "\(data[indexPath.row].fname) \(data[indexPath.row].lname)", id : data[indexPath.row].userID!, index : indexPath.row)
        locations.append(["latitude" : self.location?.coordinate.latitude ?? 37.2211, "longitude" : self.location?.coordinate.longitude ?? -121.323232 , "icon" : data[indexPath.row].image ?? UIImage()])
        return cell
    }
    
}
