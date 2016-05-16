//
//  TBAddPortView.swift
//  SocketClient
//
//  Created by 郑云 on 15/6/3.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit



@objc  protocol TBAddPortDelegate{
    
    optional func getUdpPort(port:String)
    optional func getTcpServerPort(port:String)
    optional func cancelAction()
}
class TBAddPortView: UIView {

   var delegate: TBAddPortDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.layer.opacity = 0.0
    }
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var dark_bg: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var server = ""
    
    class func addPortView(#host: String) -> TBAddPortView? {
        var addPortView: TBAddPortView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("TBAddPortView", owner: nil, options: nil).last
        
        addPortView = (lastView as? TBAddPortView)
        
        addPortView?.server = host
        
        if host == "udp"
        {
            addPortView?.cancelButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
            addPortView?.submitButton.setTitleColor(rightBgColor, forState: UIControlState.Normal)
        }
        
        return addPortView
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
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.65, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 1.0
            self.alertView.layer.position = position
            self.alertView.layer.transform = CATransform3DIdentity
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.portTextField.becomeFirstResponder()
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
    @IBAction func cancelAction(sender: AnyObject) {
        
        self.dismiss()
    }
    @IBAction func submitAction(sender: AnyObject)
    {
        
        if portTextField.text.isEmpty
        {
            println("ERROR")
            
            self.shake(3)
            return
        }
       else if UInt32(portTextField.text!.toInt()!) > 65535
        {
            println("ERROR")
            
            self.shake(3)
            return
        }
        
        switch server
        {
            case "tcpServer":
                self.delegate?.getTcpServerPort!(self.portTextField.text)
            case "udp":
                self.delegate?.getUdpPort!(self.portTextField.text)
            default:
                self.dismiss()
        }
        
        self.dismiss()
    }
    
    
    
    func shake(times: NSInteger)
    {
        println(times)
        UIView.animateWithDuration(0.04, animations: { () -> Void in
            
            self.portTextField.transform = CGAffineTransformMakeTranslation(5, 0)
            
            
            }, completion: { (flag) -> Void in
                
                UIView.animateWithDuration(0.04, animations: { () -> Void in
                    self.portTextField.transform = CGAffineTransformMakeTranslation(-5, 0)
                    }, completion: { (flag) -> Void in
                        
                        if times > 1
                        {
                            
                            self.shake(times - 1)
                        }
                        else
                        {
                            self.portTextField.transform = CGAffineTransformIdentity
                        }
                })
                
        })
        
    }
    
    @IBAction func textFieldEditingDidEndAction(sender: AnyObject) {
        if sender.isFirstResponder() {
            sender.resignFirstResponder()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        if touch.view == self.dark_bg
        {
            self.dismiss()
        }
        
    }
}
