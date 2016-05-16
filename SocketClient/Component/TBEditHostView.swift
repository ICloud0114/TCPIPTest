//
//  TBEditHostView.swift
//  SocketClient
//
//  Created by 郑云 on 15/6/24.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit


@objc protocol TBEditHostDeletage  {
    
    
   optional func addTcpHost(hostInfo:Dictionary<String,String>)
   optional func addUdpHost(hostInfo:Dictionary<String,String>)
    
   optional func editTcpHost(hostInfo:Dictionary<String,String>)
   optional func editUdpHost(hostInfo:Dictionary<String,String>)
    
   optional func editTcpSubClient(hostInfo:Dictionary<String,String>)
    
   optional func deleteHost()
   optional func cancelAction()
}

class TBEditHostView: UIView {

    
    var delegate: TBEditHostDeletage?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
   
    @IBOutlet weak var ipTextField: UITextField!

    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var wrapButton: UIButton!
    
    @IBOutlet weak var reconnectButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    var isEditHost:Bool = true
    var type = ""
    
    var pid:String = ""
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.layer.opacity = 0.0
        
    }
    
    
    class func editHost(#title: String,hostInfo:Dictionary<String, String>, isUdp:Bool) -> TBEditHostView? {
        
        var editHostView: TBEditHostView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("TBEditHostView", owner: nil, options: nil).last
        
        editHostView = (lastView as? TBEditHostView)
        
        editHostView?.titleLabel.text = title
        editHostView?.isEditHost = true
        
        println(hostInfo)
        
        if isUdp
        {
            editHostView?.type = "UDP"
            editHostView?.reconnectButton.hidden = true
            
            editHostView?.wrapButton.setImage(UIImage(named: "right_select_s"), forState: UIControlState.Selected)
            editHostView?.replyButton.setImage(UIImage(named: "right_select_s"), forState: UIControlState.Selected)
            
            editHostView?.leftButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
            editHostView?.rightButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
        }
        else
        {
            editHostView?.type = "TCP"
            if hostInfo["autoConnect"] == "yes"
            {
                editHostView?.reconnectButton.selected = true
            }
            
            editHostView?.wrapButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.replyButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.reconnectButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.leftButton.setTitleColor(midBgColor, forState: UIControlState.Normal)
            editHostView?.rightButton.setTitleColor(midBgColor, forState: UIControlState.Normal)
        }
        
        if hostInfo["autoWrap"] == "yes"
        {
            editHostView?.wrapButton.selected = true
        }
        if hostInfo["autoReply"] == "yes"
        {
            editHostView?.replyButton.selected = true
        }
        
        editHostView?.ipTextField.text = hostInfo["ip"]
        editHostView?.portTextField.text = hostInfo["port"]
        editHostView?.timeTextField.text = hostInfo["repeat"]
        
        editHostView?.pid = hostInfo["p_id"]!
        return editHostView
    }
    
    class func editTcpSubClientHost(#title: String,hostInfo:Dictionary<String, String>) -> TBEditHostView? {
        
        var editHostView: TBEditHostView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("TBEditHostView", owner: nil, options: nil).last
        
        editHostView = (lastView as? TBEditHostView)
        
        editHostView?.titleLabel.text = title
        editHostView?.isEditHost = true
        
        editHostView?.type = "TcpServer"
        
        println(hostInfo)
        
       editHostView?.reconnectButton.hidden = true
        if hostInfo["autoWrap"] == "yes"
        {
            editHostView?.wrapButton.selected = true
        }
        if hostInfo["autoReply"] == "yes"
        {
            editHostView?.replyButton.selected = true
        }
        
        editHostView?.ipTextField.text = hostInfo["ip"]
        editHostView?.portTextField.text = hostInfo["port"]
        
        editHostView?.ipTextField.userInteractionEnabled = false
        editHostView?.portTextField.userInteractionEnabled = false
        
        editHostView?.timeTextField.text = hostInfo["repeat"]
        
        return editHostView
    }

    
    class func addHost(#title: String, isUdp:Bool) ->TBEditHostView?{
        var editHostView: TBEditHostView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("TBEditHostView", owner: nil, options: nil).last
        
        editHostView = (lastView as? TBEditHostView)
        
        editHostView?.titleLabel.text = title
        editHostView?.isEditHost = false
        
        editHostView?.wrapButton.selected = true
        
        editHostView?.ipTextField.text = localIp
        if isUdp
        {
            editHostView?.type = "UDP"
            editHostView?.reconnectButton.hidden = true
            editHostView?.wrapButton.setImage(UIImage(named: "right_select_s"), forState: UIControlState.Selected)
            editHostView?.replyButton.setImage(UIImage(named: "right_select_s"), forState: UIControlState.Selected)
            editHostView?.leftButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
            editHostView?.rightButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
        }
        else
        {
            editHostView?.type = "TCP"
            editHostView?.wrapButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.replyButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.reconnectButton.setImage(UIImage(named: "mid_select_s"), forState: UIControlState.Selected)
            editHostView?.leftButton.setTitleColor(midBgColor, forState: UIControlState.Normal)
            editHostView?.rightButton.setTitleColor(midBgColor, forState: UIControlState.Normal)
        }
        editHostView?.leftButton.setTitle("取消", forState: UIControlState.Normal)
        return editHostView

    }
    
    func show(inView view: UIView) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(self)
        
        let currentView = self
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[currentView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: NSDictionary(objects: [currentView], forKeys: ["currentView"]) as [NSObject : AnyObject]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: NSDictionary(objects: [currentView], forKeys: ["currentView"]) as [NSObject : AnyObject]))
        self.layoutIfNeeded()
        
        let position = self.alertView.layer.position
        self.alertView.layer.position = CGPointMake(position.x, -(CGRectGetMidX(self.alertView.frame) + CGRectGetHeight(self.alertView.bounds) / 2.0))
        self.alertView.layer.transform = CATransform3DMakeRotation(-CGFloat(35.0 * M_PI / 180.0), 0, 0, 1)
//
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.65, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 1.0
            self.alertView.layer.position = position
            self.alertView.layer.transform = CATransform3DIdentity
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.ipTextField.becomeFirstResponder()
        }
        
        
    }
    
    func dismiss() {
        
        self.endEditing(true)
        
        let position = self.alertView.layer.position
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 0.0
            self.alertView.layer.opacity = 0.2
            self.alertView.layer.position = CGPointMake(position.x, CGRectGetHeight(self.bounds) + CGRectGetHeight(self.alertView.bounds) / 2.0)
            self.alertView.layer.transform = CATransform3DMakeRotation(CGFloat(45.0 * M_PI / 180.0), 0, 0, 1)
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.removeFromSuperview()
        }
        
        self.delegate?.cancelAction!()
    }
    
    class Regex {
        let internalExpression: NSRegularExpression
        let pattern: String
        
        init(_ pattern: String) {
            self.pattern = pattern
            var error: NSError?
            self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
        }
        
        func test(input: String) -> Bool {
            let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
            return matches.count > 0
        }
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        
        if ipTextField.text.isEmpty
        {
            println(" ip ERROR")
            
            self.shake(3,textfield: ipTextField)
            return
        }
        else if portTextField.text.isEmpty
        {
            println("port ERROR")
            
            self.shake(3,textfield: portTextField)
            return
        }
        else if timeTextField.text.isEmpty
        {
            self.shake(3,textfield: timeTextField)
            return
        }
        
        
        var str_componets = ipTextField.text
        
        let splitedarray = split(str_componets){$0 == "."}
        
        for  i in splitedarray
        {
            
            if i.toInt() > 255
            {
                self.shake(3, textfield: ipTextField)
                return
            }
        }
        
        
        if Regex("\\d+\\.\\d+\\.\\d+\\.\\d+").test(ipTextField.text) {
            println("matches pattern")
        }
        else
        {
            print("not matches!")
            self.shake(3,textfield: ipTextField)
            return
        }
        
        if Regex("^[0-9]*$").test(portTextField.text)
        {
            if UInt32(portTextField.text!.toInt()!) > 65535
            {
                println("port ERROR")
                
                self.shake(3,textfield: portTextField)
                return
            }
        }
        else
        {
            self.shake(3,textfield: portTextField)
            return
        }
        if !Regex("^[0-9]*$").test(timeTextField.text)
        {
            self.shake(3,textfield: timeTextField)
            return
        }
        
        
        var hostInfo = Dictionary<String,String>()
        
        hostInfo["ip"] = ipTextField.text
        hostInfo["port"] = portTextField.text
        hostInfo["repeat"] = timeTextField.text
        
        if wrapButton.selected
        {
            hostInfo["autoWrap"] = "yes"
        }
        else
        {
            hostInfo["autoWrap"] = "no"
        }
        
        if replyButton.selected
        {
            hostInfo["autoReply"] = "yes"
        }
        else
        {
            hostInfo["autoReply"] = "no"
        }
        
        
        
        switch type
        {
            case "UDP":
                if isEditHost
                {
                    hostInfo["p_id"] = pid
                    self.delegate?.editUdpHost!(hostInfo)
                }
                else
                {
                    self.delegate?.addUdpHost!(hostInfo)
                }
            case "TCP":
                if reconnectButton.selected
                {
                    hostInfo["autoConnect"] = "yes"
                }
                else
                {
                    hostInfo["autoConnect"] = "no"
                }
                
                if isEditHost
                {
                    hostInfo["p_id"] = pid
                    self.delegate?.editTcpHost!(hostInfo)
                }
                else
                {
                    self.delegate?.addTcpHost!(hostInfo)
            }

            case "TcpServer":
                
               self.delegate?.editTcpSubClient!(hostInfo)

        default:
            break
        }
        
        self.dismiss()
    }
    @IBAction func deleteAction(sender: AnyObject) {
        
        if isEditHost
        {
            self.delegate?.deleteHost!()
            self.dismiss()
        }
        else
        {
            self.dismiss()
        }
    }
    
    @IBAction func autoWrapAction(sender: AnyObject) {
        
        var button = sender as! UIButton
        button.selected = !button.selected
        
    }
    @IBAction func autoReconnectAction(sender: AnyObject) {
        
        var button = sender as! UIButton
        button.selected = !button.selected
        
    }
    @IBAction func autoReplyAction(sender: UIButton)
    {
        sender.selected = !sender.selected
        
    }
    @IBAction func textFieldDidFinishedEdit(sender: UITextField) {
        if sender.isFirstResponder() {
            sender.resignFirstResponder()
        }
    }
    
    func shake(times: NSInteger,textfield:UITextField)
    {
        println(times)
        UIView.animateWithDuration(0.04, animations: { () -> Void in
            
            textfield.transform = CGAffineTransformMakeTranslation(5, 0)
            
            
            }, completion: { (flag) -> Void in
                
                UIView.animateWithDuration(0.04, animations: { () -> Void in
                    textfield.transform = CGAffineTransformMakeTranslation(-5, 0)
                    }, completion: { (flag) -> Void in
                        
                        if times > 1
                        {
                            self.shake(times - 1, textfield: textfield)
                        }
                        else
                        {
                            textfield.transform = CGAffineTransformIdentity
                        }
                })
                
        })
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        if touch.view == self.bgView
        {
            self.dismiss()
        }
        
    }
   
}

