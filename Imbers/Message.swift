//
//  Match.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/26/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class Message: NSObject {
  var id = ""
  var body = ""
  var created_at = ""
  var date: NSDate!
  var user: User!
  
  required init(data: NSDictionary) {
    self.id = data["id"] as String
    self.body = data["body"] as String
    
    self.created_at = data["created_at"] as String
    
    var formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    var date = formatter.dateFromString(data["created_at"] as String)
    self.date = date
    
    self.user = User(data: data["user"]! as NSDictionary)
  }
}