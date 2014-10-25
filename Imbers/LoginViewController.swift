//
//  LoginViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
  let manager = AFHTTPRequestOperationManager()
  let ssToken = SSToken(service: kSSTokenAuthService)
  
  let permissions = [
    "public_profile",
    "email",
    "user_friends",
    "user_likes",
    "user_interests",
    "user_birthday",
    "user_location"
  ]
  
  @IBAction func fbLoginButtonTapped(sender: AnyObject) {
    FBSession.openActiveSessionWithReadPermissions(permissions, allowLoginUI: true, completionHandler: {
      session, state, error in
      
      var accessToken = FBSession.activeSession().accessTokenData?.accessToken
      
      if accessToken? != nil {
        self.authenticate(accessToken!)
      }
    })
  }
  
  private func authenticate(token: String) {
    var params = ["grant_type": "assertion", "assertion": token]
    
    self.manager.responseSerializer = AFJSONResponseSerializer()
    self.manager.POST("\(kBaseUrl)/oauth/token", parameters: params,
      success: { (operation, responseObject) in
        self.storeToken(responseObject["access_token"])
        self.performSegueWithIdentifier("LoginSegue", sender: self)
      }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
        var alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
    )
  }
  
  private func storeToken(token: AnyObject?) {
    self.ssToken.set(kSSTokenAuthAccount, token: token as String)
  }
}