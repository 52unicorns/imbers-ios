//
//  ViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
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
    FBSession.activeSession().closeAndClearTokenInformation()
    self.performSegueWithIdentifier("LogoutSegue", sender: self)
  }
}

