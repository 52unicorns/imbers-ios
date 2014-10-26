//
//  Match.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/26/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit

class Match: NSObject {
  var id = ""
  var user: User!
  
  required init(data: NSDictionary) {
    self.id = data["id"] as String
    self.user = User(data: data["user"]! as NSDictionary)
  }
}
