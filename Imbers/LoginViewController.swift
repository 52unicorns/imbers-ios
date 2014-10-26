//
//  LoginViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit
import MediaPlayer

class LoginViewController: UIViewController, FBLoginViewDelegate {
  let manager = AFHTTPRequestOperationManager()
  let ssToken = SSToken(service: kSSTokenAuthService)
  let moviePlayer: MPMoviePlayerController = MPMoviePlayerController()
  
  let permissions = [
    "public_profile",
    "email",
    "user_friends",
    "user_likes",
    "user_interests",
    "user_birthday",
    "user_location"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.playVideo()
  }
  
  @IBAction func fbLoginButtonTapped(sender: AnyObject) {
    FBSession.openActiveSessionWithReadPermissions(permissions, allowLoginUI: true, completionHandler: {
      session, state, error in
      
      var accessToken = FBSession.activeSession().accessTokenData?.accessToken
      
      if accessToken? != nil {
        self.authenticate(accessToken!)
      }
    })
  }
  
  func playVideo() {
    var path = NSBundle.mainBundle().pathForResource("test", ofType: "mp4")
    var url = NSURL(fileURLWithPath: path!)
    moviePlayer.contentURL = url
    
    moviePlayer.view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
    moviePlayer.controlStyle = MPMovieControlStyle.None
    
    view.addSubview(moviePlayer.view)
    view.sendSubviewToBack(moviePlayer.view)
    moviePlayer.play()
  }
  
  private func authenticate(token: String) {
    var params = ["grant_type": "assertion", "assertion": token]
    
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