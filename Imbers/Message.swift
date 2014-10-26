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
  var user: User!
  
  required init(data: NSDictionary) {
    self.id = data["id"] as String
    self.body = data["body"] as String
    self.user = User(data: data["user"]! as NSDictionary)
  }
}