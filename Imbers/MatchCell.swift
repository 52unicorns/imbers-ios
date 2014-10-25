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
  
  var matchId: String = "" {
    didSet {
      self.reloadAmounts()
    }
  }
  
  @IBOutlet weak var matchName: UILabel!
  
  override func translatesAutoresizingMaskIntoConstraints() -> Bool {
    return true
  }
  
  private func reloadAmounts() {
    matchName.text = "\(matchId))"
  }
}
