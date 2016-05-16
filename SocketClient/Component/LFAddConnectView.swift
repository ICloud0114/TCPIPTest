//
//  LFAddConnectView.swift
//  SocketClient
//
//  Created by Lemon on 15-5-22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit

protocol LFAddConnectViewDelegate : NSObjectProtocol {

    func getHostInfomation(ip: String, port: String, isAutoConnect: Bool)
}

class LFAddConnectView: UIView {
    
    var delegate: LFAddConnectViewDelegate?

    @IBOutlet private weak var alertView: UIView!
    
    @IBOutlet weak var autoConnectButton: UIButton!
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    //@IBInspectable private var alertViewBgColor: UIColor?
    
    class func addConnectView(#title: String) -> LFAddConnectView? {
        var addConnectView: LFAddConnectView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("LFAddConnectView", owner: nil, options: nil).last
        
        addConnectView = (lastView as? LFAddConnectView)
//        if let temp: AnyObject = lastView {
//            if temp is LFAddConnectView {
//                addConnectView = (temp as LFAddConnectView)
//            }
//        }
        
        return addConnectView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.layer.opacity = 0.0
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
        self.alertView.layer.transform = CATransform3DMakeRotation(-CGFloat(45.0 * M_PI / 180.0), 0, 0, 1)

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
    
    
    func needHideAutoConnect(choose:Bool)
    {
        self.autoConnectButton.hidden = choose
    }
    func dismiss() {
        self.endEditing(true)
        
        let position = self.alertView.layer.position
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 0.0
            self.alertView.layer.opacity = 0.2
            self.alertView.layer.position = CGPointMake(position.x, CGRectGetHeight(self.bounds) + CGRectGetHeight(self.alertView.bounds) / 2.0)
            self.alertView.layer.transform = CATransform3DMakeRotation(CGFloat(35.0 * M_PI / 180.0), 0, 0, 1)
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.removeFromSuperview()
        }
    }
    
    
    //MARK:  action
    
    @IBAction func config(sender: UIButton)
    {
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
        else if UInt32(portTextField.text!.toInt()!) > 65535
        {
            println("port ERROR")
            
            self.shake(3,textfield: portTextField)
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
        
        self.delegate?.getHostInfomation(ipTextField.text, port: portTextField.text, isAutoConnect: autoConnectButton.selected)
       
        self.dismiss()
        
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
    
    
    
    
    @IBAction func autoReconnectAction(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    @IBAction func textFieldDidFinishedEdit(sender: UITextField) {
        if sender.isFirstResponder() {
            sender.resignFirstResponder()
        }
    }
    

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {

        let touch = touches.first as! UITouch
        
        if touch.view == self
        {
            self.dismiss()
        }
        
    }
    
}
