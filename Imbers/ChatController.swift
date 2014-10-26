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
  var timer: NSTimer!
  var lastDate = ""
  
  var match: Match! {
    didSet {
      self.loadMessages(self.getToken())
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Messages"
    
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "receiveMessagePressed")
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    timer.invalidate()
  }
  
  func getToken() -> String {
    return ssToken.get(kSSTokenAuthAccount)!
  }
  
  func loadMessages(token: AnyObject?) {
    self.manager.requestSerializer.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
    
    self.manager.GET("\(kBaseUrl)/api/v0/matches/\(match.id)/messages", parameters: nil,
      success: { (operation: AFHTTPRequestOperation! ,responseObject: AnyObject!) in

        if responseObject.count > 0 {
          self.lastDate = responseObject[0]["created_at"] as String
          
          for result in responseObject as NSArray {
            
            var message = Message(data: result as NSDictionary)
            
            self.data.addMessage(message)
            self.collectionView.reloadData()
          }
          
          self.title = "\(50 - self.data.messages.count) Messages Left";
          
          self.scrollToBottomAnimated(true)
        }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("loadNewMessages"), userInfo: nil, repeats: true)
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        println("Error: " + error.localizedDescription)
    })
  }
  
  func loadNewMessages() {
    self.manager.requestSerializer.setValue("Bearer \(self.getToken())", forHTTPHeaderField: "Authorization")
    
    self.manager.GET("\(kBaseUrl)/api/v0/matches/\(match.id)/messages?since=\(self.lastDate)", parameters: nil,
      success: { (operation: AFHTTPRequestOperation! ,responseObject: AnyObject!) in
        if responseObject.count > 0 {
          self.lastDate = responseObject[0]["created_at"] as String
          
          for result in responseObject as NSArray {
            var message = Message(data: result as NSDictionary)
            
            self.data.addLastMessage(message)
            self.collectionView.reloadData()
          }
          
          self.title = "\(50 - self.data.messages.count) Messages Left";
          self.scrollToBottomAnimated(true)
        }
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        println("Error: " + error.localizedDescription)
    })
  }
  
  func postMessage(message: String) {
    var params = ["body": message]
    
    self.manager.requestSerializer.setValue("Bearer \(self.getToken())", forHTTPHeaderField: "Authorization")
    
    if data.messages.count >= 50 {
      return
    }
    
    self.manager.POST("\(kBaseUrl)/api/v0/matches/\(match.id)/messages", parameters: params,
      success: { (operation, responseObject) in
        self.lastDate = responseObject["created_at"] as String
        
        var message = Message(data: responseObject as NSDictionary)
        
        self.data.addLastMessage(message)
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
      color = UIColor(rgba: "#c1a7f2")
      bubble = bubbleFactory.incomingMessagesBubbleImageWithColor(color) as JSQMessageBubbleImageDataSource
//      bubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(color) as JSQMessageBubbleImageDataSource
    } else {
      color = UIColor(rgba: "#a27aec")
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
    var sheet = UIActionSheet(title: "Do you want to reveal your Facebook identity?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Reveal")
    
    sheet.delegate = self
    
    sheet.showInView(self.view)
  }
  
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 {
      self.revealAccount()
    }
  }
  
  private func revealAccount() {
    self.manager.requestSerializer.setValue("Bearer \(self.getToken())", forHTTPHeaderField: "Authorization")
    
    self.manager.POST("\(kBaseUrl)/api/v0/matches/\(match.id)/reveal", parameters: nil,
      success: { (operation, responseObject) in
        println(responseObject)
      }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
        var alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
    )
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
    
//    if msg.senderId() != match.user.id {
//      return nil
//    }
//    
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
    
//    if msg.senderId() != match.user.id {
//      return 0
//    }
    
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
