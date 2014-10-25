//
//  ViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let manager = AFHTTPRequestOperationManager()
  let ssToken = SSToken(service: kSSTokenAuthService)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
  }
  
  override func viewDidAppear(animated: Bool) {
    if kTutorialSeen == false {
      kTutorialSeen = true
      self.performSegueWithIdentifier("TutorialSegue", sender: self)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func logoutButtonTapped(sender: UIButton) {
    self.revokeAuthToken()
  }
  
  func getToken() -> String {
    return ssToken.get(kSSTokenAuthAccount)!
  }
  
  func deleteToken() {
    ssToken.destroy(kSSTokenAuthAccount)
  }
  
  private func revokeAuthToken() {
    var params = ["token": self.getToken()]
    
    self.manager.responseSerializer = AFJSONResponseSerializer()
    self.manager.POST("\(kBaseUrl)/oauth/revoke", parameters: params,
      success: { (operation, responseObject) in
        self.deleteToken()
        FBSession.activeSession().closeAndClearTokenInformation()
        self.performSegueWithIdentifier("LogoutSegue", sender: self)
      }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
        var alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
    )
  }
}

