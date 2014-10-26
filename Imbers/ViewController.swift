//
//  ViewController.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  let manager = AFHTTPRequestOperationManager()
  let ssToken = SSToken(service: kSSTokenAuthService)
  
  @IBOutlet weak var tableView: UITableView!
  
  var matches: [AnyObject] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.getMatches(self.getToken())
    
    // Get rid of default separators.
    self.tableView.tableFooterView = UIView(frame: CGRectZero)
    
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
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //TODO - Preload and prepare these. Do not calculate them every time!!!
    var cell: MatchCell = self.tableView.dequeueReusableCellWithIdentifier("MatchCell") as MatchCell

    var user = self.matches[indexPath.row] as User
    cell.matchId = user.name
    cell.avatar = user.avatar
    
    return cell
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  /**
  * Define the height of each cell.
  */
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    return kCellHeight
  }
  
  /**
  * A table view cell was selected.
  */
  func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    println(indexPath.row)
    //self.performSegueWithIdentifier("DetailedGoalView", sender: self)
  }
  
  /**
  * Define the number of rows in each section.
  *
  * Called multiple times?! Why?
  */
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.matches.count
  }
  
  
  
  private func getMatches(token: AnyObject?) {
    self.manager.requestSerializer.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
    
    self.manager.GET("\(kBaseUrl)/api/v0/matches", parameters: nil,
      success: { (operation: AFHTTPRequestOperation! ,responseObject: AnyObject!) in
        for result in responseObject as NSArray {
          var user = User(data: result["user"]!! as NSDictionary)
          self.matches.append(user)
        }
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        println("Error: " + error.localizedDescription)
    })
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

