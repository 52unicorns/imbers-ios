//
//  AppDelegate.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    var logged = false
    
    if let token = FBSession.activeSession().accessTokenData?.accessToken {
        logged = true
    }
    
    var storyboardId = logged ? "InnerView" : "LoginView"
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var initViewController: AnyObject! = storyboard.instantiateViewControllerWithIdentifier(storyboardId)
    
    self.window = UIWindow()
    self.window!.frame = UIScreen.mainScreen().bounds
    self.window!.rootViewController = initViewController as? UIViewController
    self.window!.makeKeyAndVisible()

    return true
  }
  
  func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
    FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {}
  func applicationDidEnterBackground(application: UIApplication) {}
  func applicationWillEnterForeground(application: UIApplication) {}
  func applicationDidBecomeActive(application: UIApplication) {}
  func applicationWillTerminate(application: UIApplication) {}
}

