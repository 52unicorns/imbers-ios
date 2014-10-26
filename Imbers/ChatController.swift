//
//  MessagesController.swift
//  Spyke
//
//  Created by Dimitar Valchanov on 10/25/14.
//  Copyright (c) 2014 Dimitar Valchanov. All rights reserved.
//

import UIKit

class ChatController: JSQMessagesViewController, UIActionSheetDelegate {
  let manager = AFHTTPRequestOperationManager()
  let ssToken = SSToken(service: kSSTokenAuthService)
  var data = Messages()
  
  var match: Match! {
    didSet {
      self.loadMessages(self.getToken())
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Messages";
    

//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "receiveMessagePressed")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func getToken() -> String {
    return ssToken.get(kSSTokenAuthAccount)!
  }
  
  func loadMessages(token: AnyObject?) {
    self.manager.requestSerializer.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
    
    self.manager.GET("\(kBaseUrl)/api/v0/matches/\(match.id)/messages", parameters: nil,
      success: { (operation: AFHTTPRequestOperation! ,responseObject: AnyObject!) in
        println(responseObject.count)

        for result in responseObject as NSArray {
          var message = Message(data: result as NSDictionary)
          
          self.data.addMessage(message)
          self.collectionView.reloadData()
        }
        
        self.title = "\(50 - self.data.messages.count) Messages Left";

        self.scrollToBottomAnimated(true)
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        println("Error: " + error.localizedDescription)
    })
  }
  
  func postMessage(message: String) {
    var params = ["body": message]
    
    self.manager.requestSerializer.setValue("Bearer \(self.getToken())", forHTTPHeaderField: "Authorization")
    
    self.manager.POST("\(kBaseUrl)/api/v0/matches/\(match.id)/messages", parameters: params,
      success: { (operation, responseObject) in
        var message = Message(data: responseObject as NSDictionary)
        
        self.data.addMessage(message)
        self.collectionView.reloadData()
        
        self.title = "\(50 - self.data.messages.count) Messages Left";
        
        self.scrollToBottomAnimated(true)
      }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
        var alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
    )
  }
  

  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.messages.count
  }
  
  override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
    self.postMessage(text)
    
    self.finishSendingMessage()
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    
    return self.data.messages[indexPath.item] as JSQMessageData
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
    
    cell.textView.textColor = UIColor.whiteColor()
    
    return cell
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
    var msg = self.data.messages[indexPath.item] as JSQMessageData
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var color = UIColor()
    var bubble: JSQMessageBubbleImageDataSource!
    
    if match.user.id == msg.senderId() {
      color = UIColor(rgba: "#459fe6")
      bubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(color) as JSQMessageBubbleImageDataSource
    } else {
      color = UIColor(rgba: "#77c9ff")
      bubble = bubbleFactory.incomingMessagesBubbleImageWithColor(color) as JSQMessageBubbleImageDataSource
    }
    
    return bubble as JSQMessageBubbleImageDataSource
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    
    var msg = self.data.messages[indexPath.item] as JSQMessageData
    
    if msg.senderId() == match.user.id {
      return self.data.avatars["avatar"] as JSQMessageAvatarImageDataSource
    } else {
      return self.data.avatars["mine"] as JSQMessageAvatarImageDataSource
    }
  }
  
  
  
  override func didPressAccessoryButton(sender: UIButton!) {
    var sheet = UIActionSheet(title: "Do you want to reveal your Facebook identity?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Reveal", "Decline")
    
    sheet.delegate = self
    
    sheet.showInView(self.view)
  }
  
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    println("\(buttonIndex)")
  }
  
  
  
  
//  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//    
//    return NSAttributedString(string: self.data.messages[indexPath.item].senderId())
//  }
//  
//  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//    return 0
//  }
  
  
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
    
    var msg = self.data.messages[indexPath.item] as JSQMessageData
    
    if msg.senderId() != match.user.id {
      return nil
    }
    
    if indexPath.item - 1 >= 0 {
      var previousMessage = self.data.messages[indexPath.item - 1] as JSQMessageData
      if previousMessage.senderId() == msg.senderId() {
        return nil
      }
    }
    
    return NSAttributedString(string: self.data.messages[indexPath.item].senderDisplayName())
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    
    var msg = self.data.messages[indexPath.item] as JSQMessageData
    
    if msg.senderId() != match.user.id {
      return 0
    }
    
    if indexPath.item - 1 >= 0 {
      var previousMessage = self.data.messages[indexPath.item - 1] as JSQMessageData
      if previousMessage.senderId() == msg.senderId() {
        return 0
      }
    }
    
    return 20
  }
  
//  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//    
//    return nil
//  }
//  
  //  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
  //    return 20
  //  }
  
  //  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
  //    return 20
  //  }
  //
  //  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
  //    return 20
  //  }
  
  
  
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
    println("Load earlier")
  }
  
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
