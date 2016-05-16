//
//  TBHistoryListView.swift
//  SocketClient
//
//  Created by 郑云 on 15/7/1.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit


@objc protocol TBHistoryDelegate  {
    
    optional func selectDataToUDP(dataString:String)
    optional func selectDataToTCP(dataString:String)
    optional func selectDataToTcpServer(dataString:String)
}
class TBHistoryListView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate: TBHistoryDelegate?
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    
    
    var sign:String = ""
    var dataLibrary = DataLibrary.shareDataLibrary()
    var dataArray = []
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.opacity = 0.0
        
        
        self.historyTableView.rowHeight = UITableViewAutomaticDimension
        
        self.historyTableView.estimatedRowHeight = 44
        
        dataLibrary.creatProductTable("HISTORY")
        
        dataArray = dataLibrary.getallDataByTable("HISTORY")
    }
    
    
    class func showHistoryListViewBy(#type:String) -> TBHistoryListView? {
        var historyListView: TBHistoryListView?
        
        let lastView: AnyObject? = NSBundle.mainBundle().loadNibNamed("TBHistoryListView", owner: nil, options: nil).last
        
        historyListView = (lastView as? TBHistoryListView)
        
        historyListView?.sign = type
        return historyListView
    }
    
    func show(inView view: UIView) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(self)
        
        let currentView = self
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[currentView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: NSDictionary(objects: [currentView], forKeys: ["currentView"]) as [NSObject : AnyObject]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: NSDictionary(objects: [currentView], forKeys: ["currentView"]) as [NSObject : AnyObject]))
        self.layoutIfNeeded()
        
        let position = self.popView.layer.position
        self.popView.layer.position = CGPointMake(0, self.bounds.size.height)
        self.popView.layer.transform = CATransform3DMakeRotation(-CGFloat(45.0 * M_PI / 180.0), 0, 0, 0.5)
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 1.0
            self.popView.layer.position = position
            self.popView.layer.transform = CATransform3DIdentity
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()

        }
        
    }
    
    func dismiss() {
        self.endEditing(true)
        
        let position = self.popView.layer.position
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.opacity = 0.0
            self.popView.layer.opacity = 0.2
            self.popView.layer.position = CGPointMake(0, self.bounds.size.height)
            self.popView.layer.transform = CATransform3DMakeRotation(CGFloat(35.0 * M_PI / 180.0), 0, 0, 1)
            }) { (flag) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.removeFromSuperview()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        if touch.view == self.bgView
        {
            self.dismiss()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
       
       let cell = (NSBundle.mainBundle().loadNibNamed("TBHistoryListCell", owner: nil, options: nil).last as? TBHistoryListCell)!
        
        cell.numLabel.text = String(indexPath.row)
        cell.titleLabel.text = dataArray[indexPath.row] as? String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TBHistoryListCell
        
        switch sign
        {
            case "UDP":
            
            self.delegate?.selectDataToUDP!(cell.titleLabel.text!)
            
            case "TCP":
            self.delegate?.selectDataToTCP!(cell.titleLabel.text!)
            case "TcpServer":
            self.delegate?.selectDataToTcpServer!(cell.titleLabel.text!)
            
            
        default:
         println(cell.titleLabel.text)
        }
        self.dismiss()
        
    }
}
