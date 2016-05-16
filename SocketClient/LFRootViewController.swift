//
//  LFRootViewController.swift
//  SocketClient
//
//  Created by Lemon on 15-5-21.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit


//let selectedBgColor = UIColor(red: 93.0 / 255.0, green: 170.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
//let normalBgColor = UIColor(red: 65.0 / 255.0, green: 149.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)

let leftBgColor = UIColor(red: 39.0 / 255.0, green: 174.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)
let midBgColor = UIColor(red: 24.0 / 255.0, green: 176.0 / 255.0, blue: 146.0 / 255.0, alpha: 1.0)
let rightBgColor = UIColor(red: 38.0 / 255.0, green: 145.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0)

//left:#27ae60  39 174 96
//
//middle:#18b092  24 176 146
//
//right:#2691d7   38 145 215

class LFRootViewController: UIViewController, UIScrollViewDelegate,TBEditHostDeletage {
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var tcpServerBt: UIButton!
    @IBOutlet weak var tcpBt: UIButton!
    @IBOutlet weak var udpBt: UIButton!
    
    @IBOutlet weak var tcpServerContainerView: UIView!
    @IBOutlet weak var tcpContainerView: UIView!
    @IBOutlet weak var udpContainerView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var beginOffset:CGPoint = CGPointMake(0, 0)
    
    var tcpServerVc: TBTCPServerViewController!
    var tcpVC: LFTCPViewController!
    var udpVC: LFUDPViewController!
    
    var addConnect : TBEditHostView?
    
    var addButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.navigationController?.navigationBar.shadowImage = UIImage.new()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        if (self.navigationController!.navigationBar.respondsToSelector("setBackgroundImage:forBarMetrics:"))
//        {
//
//            for subview  in self.navigationController!.navigationBar.subviews {
//                
//                if subview.isKindOfClass(UIImageView) {
//                    let imageView = subview as! UIImageView
//                    
//                    for obj in imageView.subviews
//                    {
//                        if obj.isKindOfClass(UIImageView)
//                        {
//                            let img = obj as! UIImageView
//                            img.hidden = true
//                        }
//                    }
//                }
//            }
//        }

        self.title = "网络调试助手"
        
        addButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        addButton.setImage(UIImage(named: "nav_add_default"), forState: UIControlState.Normal)
        addButton.setImage(UIImage(named: "nav_add_pressed"), forState: UIControlState.Highlighted)
        addButton.sizeToFit()
        addButton.tintColor = UIColor.whiteColor()
        addButton.showsTouchWhenHighlighted = true
        addButton.addTarget(self, action: "addAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        addButton.hidden = true
        let spaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        spaceItem.width = -5
        let item = UIBarButtonItem(customView: addButton)
        
        self.navigationItem.rightBarButtonItems = [spaceItem, item]

        
        tcpServerBt.tag = 1000

        
        tcpBt.tag = 1001

        
        udpBt.tag = 1002

        
        tcpServerBt.selected = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destinationViewController is LFTCPViewController {
            self.tcpVC = segue.destinationViewController as! LFTCPViewController
        } else if segue.destinationViewController is LFUDPViewController {
            self.udpVC = segue.destinationViewController as! LFUDPViewController
        }
        else if segue.destinationViewController is TBTCPServerViewController
        {
            self.tcpServerVc = segue.destinationViewController as! TBTCPServerViewController
        }
    }
    
    
    func selectSegue(sender:UIButton)
    {
        if sender.selected {return}
    
        tcpServerBt.selected = false
        tcpBt.selected = false
        udpBt.selected = false
        sender.selected = true
        
        switch sender
        {
            case tcpServerBt:

                self.addButton.hidden = true
                self.navigationController?.navigationBar.barTintColor = leftBgColor
                self.selectionView.backgroundColor = leftBgColor

            case tcpBt:

                self.addButton.hidden = false
                self.navigationController?.navigationBar.barTintColor = midBgColor
                self.selectionView.backgroundColor = midBgColor
            
            case udpBt:

                self.addButton.hidden = false
                self.navigationController?.navigationBar.barTintColor = rightBgColor
                self.selectionView.backgroundColor = rightBgColor
            
            default:

                return

        }
        let offset = CGRectGetWidth(self.view.bounds) * CGFloat(sender.tag - 1000)
        self.scrollView.setContentOffset(CGPointMake(offset, 0), animated: true)
        
    }
    
    
    //MARK: - action
    func addAction(sender: UIButton) {
        println("hello world")
        
        if self.tcpBt.selected
        {
            self.addConnect = TBEditHostView.addHost(title: "添加链接", isUdp: false)
            
        }
        else
        {
            
            self.addConnect = TBEditHostView.addHost(title: "添加链接", isUdp: true)
        }
        self.addConnect?.show(inView: self.view.window!)
        
        self.addConnect!.delegate = self
        
    }
    
    @IBAction func clientChangeAction(sender: UIButton) {
        
        
        self.selectSegue(sender)
        
//        if sender.selected {return}
//        
//        
//        tcpServerBt.selected = false
//        tcpBt.selected = false
//        udpBt.selected = false
//        
//        sender.selected = true
//        if tcpServerBt.selected
//        {
//            addButton.hidden = true
//        }
//        else
//        {
//            addButton.hidden = false
//        }
//        
//        if tcpServerBt.selected
//        {
//            self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
//            self.selectionView.backgroundColor = UIColor.blackColor()
//        }
//        else if tcpBt.selected
//        {
//            self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
//            self.selectionView.backgroundColor = UIColor.redColor()
//        }
//        else if udpBt.selected
//        {
//            self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
//            self.selectionView.backgroundColor = UIColor.blueColor()
//        }
//        
//        let offset = CGRectGetWidth(self.view.bounds) * CGFloat(sender.tag - 1000)
//        self.scrollView.setContentOffset(CGPointMake(offset, 0), animated: true)

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        tcpServerBt.selected = false
//        tcpBt.selected = false
//        udpBt.selected = false
   
        let offset = scrollView.contentOffset.x / (CGRectGetWidth(self.view.bounds) / 3)
        
        if scrollView.contentOffset.x - beginOffset.x > 0
        {
            if offset < 1
            {
                
//                self.scrollView.setContentOffset(CGPointMake(0 , 0), animated: true)
//                tcpServerBt.selected = true
//                addButton.hidden = true
//                self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
//                self.selectionView.backgroundColor = UIColor.blackColor()
                
                self.selectSegue(tcpServerBt)

            }
            else if offset >= 1 && offset <= 4
            {
                
//                self.scrollView.setContentOffset(CGPointMake(CGRectGetWidth(self.view.bounds) * 1, 0), animated: true)
//                tcpBt.selected = true
//                addButton.hidden = false
//                self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
//                self.selectionView.backgroundColor = UIColor.redColor()
                self.selectSegue(tcpBt)

            }
            else
            {
                
//                self.scrollView.setContentOffset(CGPointMake(CGRectGetWidth(self.view.bounds) * 2, 0), animated: true)
//                udpBt.selected = true
//                addButton.hidden = false
//                self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
//                self.selectionView.backgroundColor = UIColor.blueColor()
                self.selectSegue(udpBt)

            }
        }
        else
        {
            if offset < 2
            {
                
//                self.scrollView.setContentOffset(CGPointMake(0 , 0), animated: true)
//                tcpServerBt.selected = true
//                addButton.hidden = true
//                self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
//                self.selectionView.backgroundColor = UIColor.blackColor()
                self.selectSegue(tcpServerBt)

            }
            else if offset >= 2 && offset <= 5
            {
                
//                self.scrollView.setContentOffset(CGPointMake(CGRectGetWidth(self.view.bounds) * 1, 0), animated: true)
//                tcpBt.selected = true
//                addButton.hidden = false
//                self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
//                self.selectionView.backgroundColor = UIColor.redColor()
                self.selectSegue(tcpBt)
            }
            else
            {
                
//                self.scrollView.setContentOffset(CGPointMake(CGRectGetWidth(self.view.bounds) * 2, 0), animated: true)
//                udpBt.selected = true
//                addButton.hidden = false
//                self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
//                self.selectionView.backgroundColor = UIColor.blueColor()
                self.selectSegue(udpBt)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        beginOffset = scrollView.contentOffset
    }
    

    //MARK: TBEditHostDelegate
    
    func cancelAction() {
        
    }
    func addTcpHost(hostInfo: Dictionary<String, String>) {
       
        tcpVC.addConnect(hostInfo)
    }
    func addUdpHost(hostInfo: Dictionary<String, String>) {
        
        udpVC.addConnect(hostInfo)
    }
    

}
