//
//  NearMeChatViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 12/5/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import JSQMessagesViewController

class NearMeChatViewController: JSQMessagesViewController {

    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 195/255, green: 0/255, blue: 82/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(displayP3Red: 195/255, green: 0/255, blue: 82/255, alpha: 1.0))
    var messages = [JSQMessage]()
    
    let serviceType = "NearMeChat"
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    //initial setup
    func setup(){
        self.senderId = UIDevice.current.identifierForVendor?.uuidString
        self.senderDisplayName = UIDevice.current.identifierForVendor?.uuidString
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        self.browser = MCBrowserViewController(serviceType:serviceType, session:self.session)
        
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.session)
        self.assistant.start()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    func updateChat(_ text : String!, fromPeer peerID: MCPeerID) {
        var name : String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        let currentDate = Date()
        let message = JSQMessage(senderId: name, senderDisplayName: name, date: currentDate, text: text)
        self.messages.append(message!)
        self.finishSendingMessage()
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NearMeChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let data = self.collectionView(self.collectionView, messageDataForItemAt: indexPath)
        if (self.senderDisplayName == data?.senderDisplayName()) {
            return nil
        }
        return NSAttributedString(string: data!.senderDisplayName())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = self.collectionView(self.collectionView, messageDataForItemAt: indexPath)
        if (self.senderDisplayName == data?.senderDisplayName()) {
            return 0.0
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

extension NearMeChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message!)
        self.finishSendingMessage()
        
        let msg = text!.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print("Error")
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.present(self.browser, animated: true, completion: nil)
    }
}

extension NearMeChatViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish( _ browserViewController: MCBrowserViewController)  {
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled( _ browserViewController: MCBrowserViewController)  {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NearMeChatViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)  {
        DispatchQueue.main.async {
            let msg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            self.updateChat(String(msg!), fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)  {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)  {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)  {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)  {
    }
}

