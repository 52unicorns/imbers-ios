//
//  Messages.swift
//  Spyke
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 Dimitar Valchanov. All rights reserved.
//

import UIKit

class Messages: NSObject {
  var messages = NSMutableArray()
  var avatar: AnyObject!
  var avatars: [String: AnyObject] = [:]
  
  override init () {
    super.init()
    
    var avatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("J", backgroundColor: UIColor.grayColor(), textColor: UIColor.whiteColor(), font: UIFont(name: "Helvetica", size: 100), diameter: 200)
    
    var mine = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatar"), diameter: 200)
    
    self.avatars["mine"] = mine
    self.avatars["avatar"] = avatar
  }

  func addMessage(message: Message) {
    var msg = JSQTextMessage(senderId: message.user.id, senderDisplayName: message.user.name, date: NSDate(), text: message.body);
    
    messages.insertObject(msg, atIndex: 0)
    //messages.addObject(msg)
  }
}
