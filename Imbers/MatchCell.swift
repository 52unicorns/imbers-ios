//
//  MatchCell.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {
  var index = 0
  var match: Match!
  
  var matchId: String = "" {
    didSet {
      self.reloadAmounts()
    }
  }
  
  var avatar: String = "" {
    didSet {
      self.loadPicture()
    }
  }
  
  @IBOutlet weak var matchName: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var identityLabel: UILabel!
  @IBOutlet weak var revealButton: UIButton!
  
  override func translatesAutoresizingMaskIntoConstraints() -> Bool {
    return true
  }
  
  @IBAction func revealeButtonTapped(sender: UIButton) {
    revealButton.enabled = !revealButton.enabled
    if revealButton.enabled {
      identityLabel.text = "\(match.user.facebook_url)"
      identityLabel.hidden = true
    } else {
      identityLabel.text = "\(match.user.facebook_url)"
      identityLabel.hidden = false
    }
  }
  
  private func reloadAmounts() {
    
    if match.revealed == true {
      revealButton.hidden = false

    }
    
    matchName.text = "\(matchId)"
  }
  
  private func loadPicture() {
    self.changeImage(avatar)
  }
  
  private func changeImage(url: String) {
    var nsurl: NSURL = NSURL(string: url)!
    var imageRequest: NSURLRequest = NSURLRequest(URL: nsurl)
    NSURLConnection.sendAsynchronousRequest(imageRequest,
      queue: NSOperationQueue.mainQueue(),
      completionHandler:{response, data, error in
        let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0))
        var decodedimage = UIImage(data: decodedData!)
        
        if let image = decodedimage? {
          println(image)
          self.avatarImageView.image = image
        } else {
          self.avatarImageView.image = UIImage(named: "avatar")
        }
    })
  }
}
