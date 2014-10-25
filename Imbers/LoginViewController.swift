//
//  LoginViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
  let permissions = [
    "public_profile",
    "email",
    "user_friends",
    "user_likes",
    "user_interests",
    "user_birthday"
  ] 
  
  @IBAction func fbLoginButtonTapped(sender: AnyObject) {
    FBSession.openActiveSessionWithReadPermissions(permissions, allowLoginUI: true, completionHandler: {
      session, state, error in
      
      var accessToken = FBSession.activeSession().accessTokenData?.accessToken
      self.performSegueWithIdentifier("LoginSegue", sender: self)
    })
  }
}