//
//  User.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/26/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class User: NSObject {
  var id = ""
  var name = ""
  var avatar = ""
  
  required init(data: NSDictionary) {
    self.id = data["id"] as String
    self.name = data["first_name"] as String
    self.avatar = data["avatar_url"] as String
  }
}