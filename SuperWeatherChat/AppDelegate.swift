//
//  AppDelegate.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/22/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleMaps
import GooglePlaces
import Crashlytics
import Fabric
import UserNotifications
import FirebaseMessaging
import GoogleSignIn
import IQKeyboardManagerSwift

let GoogleKey = "AIzaSyBKPIMT_5saI8cS5vmRg8eJqHxvlgNYCx0"
let placesKey = "AIzaSyBKPIMT_5saI8cS5vmRg8eJqHxvlgNYCx0"

let English = "en"
let French = "fr"



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    var location : CLLocation?
    var locationManager = CLLocationManager()
    var cityName: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        IQKeyboardManager.shared.enable = true
        
        GMSServices.provideAPIKey(GoogleKey)
        GMSPlacesClient.provideAPIKey(placesKey)
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        Fabric.with([Crashlytics.self])
        registerForPushNotifications()
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        Messaging.messaging().delegate = self
        
        if (Auth.auth().currentUser != nil) {
            let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            self.window?.rootViewController = ctrl
        }
        return true
    }
    
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                if granted {
                    print("Allowed")
                    UIApplication.shared.registerForRemoteNotifications()
                }else{
                    print("Not Allowed")
                }
                print("Permission granted: \(granted)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        let varAvgvalue = String(format: "%@", deviceToken as CVarArg)
        
        let  token = varAvgvalue.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        
        print(token)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)
        Messaging.messaging().subscribe(toTopic: "Topic")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      let googlehandler = GIDSignIn.sharedInstance()?.handle(url)
        
//        let googlehandler = GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
        
        
      return googlehandler!
    }
   


}


