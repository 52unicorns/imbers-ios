//
//  SSToken.swift
//  Imbers
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 52unicorns. All rights reserved.
//

import UIKit
import Security

struct SSToken {
  var service: String = ""
  
  func set(acc: String, token: AnyObject?) {
    var result = SSKeychain.setPassword(token as String, forService: service, account: acc)
  }
  
  func get(acc: String) -> String? {
    return SSKeychain.passwordForService(service, account: acc)
  }
  
  func destroy(acc: String) {
    SSKeychain.deletePasswordForService(service, account: acc)
  }
}