//
//  TBTCPServerViewController.swift
//  SocketClient
//
//  Created by 郑云 on 15/5/27.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit

let localIp = IpAddress.deviceIPAdress()

class TBTCPServerViewController: UIViewController,TBAddPortDelegate,TBTcpListenerDelegate,LFTcpClientDelegate,TBHistoryDelegate,TBEditHostDeletage {
    

    @IBOutlet weak var showTypeButton: UIButton!
    @IBOutlet weak var sendTypeButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cycleButton: UIButton!
    
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var showHistoryButton: UIButton!
    @IBOutlet weak var hostListTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    
    @IBOutlet weak var showTextView: UITextView!
    
    var tcpServer = TBTcpListener()

    var editHostView :TBEditHostView?
    var historyListView: TBHistoryListView?
    var editPortView :TBAddPortView?
    var serverSubClient:LFTcpClient!
    var dataLibrary = DataLibrary.shareDataLibrary()
    
    var dataArray:NSMutableArray = []
    
    var dataDictionary = Dictionary<LFTcpClient,Dictionary<String, String>>()
    var showTextDic = Dictionary<LFTcpClient, Dictionary<String, String>>()
    
    var hostPort = "8080"
    var hostState = ""
    var oldObject = LFTcpClient()
    
    var cellIndex = 9999
    var repeatSend:NSTimer?
    
//    var show:Bool = false
    
    //MARK: override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        hostListTableView.tableFooterView = UIView(frame:CGRectZero)
        
        hostState = self.getHostErrorCode(tcpServer.start(8080))
        tcpServer.delegate = self
        self.checkSubClientList(0)
        
        print("local ip --->\(localIp)")
        
    }
    
    override func viewDidLayoutSubviews() {
        
        var bg = UIView(frame: hostListTableView.frame)
        bg.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        var vline = UIView(frame: CGRectMake(CGRectGetWidth(hostListTableView.frame) - 1, 0, 1, CGRectGetHeight(hostListTableView.frame)))
        
        vline.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.1)
        
        bg.addSubview(vline)
        hostListTableView.backgroundView = bg
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resignActionNotification:", name:"ResignActionNotificationIdentifier", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actionNotification:", name:"ActiveNotificationIdentifier", object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.textFieldDidFinshEdit()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ResignActionNotificationIdentifier", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ActiveNotificationIdentifier", object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - func
    
    
    func getHostErrorCode(code:Int64) ->String
    {
        var error = ""
        
        switch code
        {
            case -100000008:
             error = "初始化失败！"
        default:
            error = "正在监听.."
        }
        return error
    }
    
    func checkErrorCode(code:Int64) ->String
    {
         var errString = ""
        switch code
        {
            case -100000001:
                errString = "\n对象已经释放"
            case -100000002:
                errString = "\n调用了无效的函数"
            case -100000003:
                errString = "\n函数传入无效参数"
            case -100000004:
                errString = "\n函数重复调用错误"
            case -100000005:
                errString = "\n内存申请失败"
            case -100000006:
                errString = "\n系统资源不够"
            case -100000007:
                errString = "\n死锁错误"
            case -100000008:
                errString = "\n地址已经在使用中错误"
            case -100000009:
                errString = "\n地址在当前主机中不可用"
            case -100000010:
                errString = "\n数据太长"
            case -100000011:
                errString = "\n广播地址发送数据错误"
            case -100000012:
                errString = "\n网络不可到达"
            case -100000013:
                errString = "\n系统IO接口读写错误"
            case -100000014:
                errString = "\n连接动作被拒绝"
            case -100000015:
                errString = "\n连接动作超时"
            case -100000016:
                errString = "\n网络未连接错误"
            case -100000017:
                errString = "\n链接超时断开错误"
            case -100000018:
                errString = "\n远程主机关闭连接"
            case -100000019:
                errString = "\n对象被挂起"
            case -100000020:
                errString = "\n对象内部资源被损坏"
            case -100000021:
                errString = "\n未启动先决条件"
            case -100000022:
                errString = "\n非法调用"
            default:
        break
        }
        return errString
    }
    
    func createDictionaryByTcpClient(tcpClient:LFTcpClient)
    {
        var subDic  = Dictionary<String,String>()
        
        subDic["autoConnect"] = "no"
        subDic["autoReply"] = "no"
        subDic["autoWrap"] = "yes"
        subDic["ip"] = tcpClient.ip
        subDic["port"] = String(tcpClient.port)
        subDic["repeat"] = "100"
        subDic["state"] = "已连接"
        
        dataDictionary[tcpClient] = subDic
    }
    
    func saveText(client:LFTcpClient,showText:String,autoWrap:String)
    {
        var nextData = ""
        if autoWrap == "yes"
        {
            nextData = "\n"
        }
        
        var oldString = self.showTextView.text as NSString
        var oldClientInfo = NSString(format: "[%@:%d]\n", client.ip,client.port) as String
        if client == oldObject
        {
            let subString = oldString.substringFromIndex(count(oldClientInfo))
            
            self.showTextView.text = oldClientInfo + showText + nextData + (subString as String)
            
        }
        else
        {
            self.showTextView.text = oldClientInfo + showText +  "\n" + (oldString as String)
            
            oldObject = client
        }
        
//        var nextData = ""
//        if autoWrap == "yes"
//        {
//            nextData = "\n"
//        }
//        if showTextDic[client] != nil
//        {
//            var dic :Dictionary  = showTextDic[client]!
//            
//            if dic["text"] != nil
//            {
//                var showNewText = showText + nextData + dic["text"]!
//                
//                dic["text"] = showNewText
//                
//                showTextDic[client] = dic
//                
//                showTextView.text = showNewText
//            }
//            else
//            {
//                dic["text"] = showText
//                
//                showTextDic[client] = dic
//                
//                showTextView.text = showText
//            }
//            
//            
//        }
//        else
//        {
//            var dic: Dictionary = Dictionary<String, String>()
//            
//            dic["text"] = showText
//            
//            showTextDic[client] = dic
//            
//            showTextView.text = showText
//        }
        
    }
    func saveTextInBackground(client:LFTcpClient,showText:String,autoWrap:String)
    {
        var nextData = ""
        if autoWrap == "yes"
        {
            nextData = "\n"
        }
        
        var oldString = self.showTextView.text as NSString
        var oldClientInfo = NSString(format: "[%@:%d]\n", client.ip,client.port) as String
        if client == oldObject
        {
            let subString = oldString.substringFromIndex(count(oldClientInfo))
            
            self.showTextView.text = oldClientInfo  + showText + nextData + (subString as String)
            
        }
        else
        {
            self.showTextView.text = oldClientInfo  + showText + "\n" + (oldString as String)
            oldObject = client
        }
//        var nextData = ""
//        if autoWrap == "yes"
//        {
//            nextData = "\n"
//        }
//
//        if showTextDic[client] != nil
//        {
//            
//            var dic :Dictionary  = showTextDic[client]!
//            
//            if dic["text"] != nil
//            {
//                var showNewText = showText + nextData + dic["text"]!
//                
//                dic["text"] = showNewText
//                
//                showTextDic[client] = dic
//            }
//            else
//            {
//                var dic: Dictionary = Dictionary<String, String>()
//                
//                dic["text"] = showText + nextData
//                showTextDic[client] = dic
//            }
//            
//        }
//        else
//        {
//            var dic: Dictionary = Dictionary<String, String>()
//            
//            dic["text"] = showText + nextData
//            showTextDic[client] = dic
//            
//        }
        
    }
    
    func clearText(client:LFTcpClient)
    {
        if showTextDic[client] != nil
        {
            
            var dic:Dictionary = showTextDic[client]!
            
            if dic["receive"] != nil
            {
                dic["receive"] = "0"
            }
            if dic["send"] != nil
            {
                dic["send"] = "0"
            }
            
            showTextDic[client] = dic
            
        }
        self.showTextView.text = ""
        oldObject = LFTcpClient()
        
    }
    
    func checkReceiveData(error:Int64,client:LFTcpClient,sendData:NSData)
    {
        if error != 0
        {
            
            showTextView.text = showTextView.text + self.checkErrorCode(error) + "\n"
            
        }
        else
        {
            
            var dic = showTextDic[client]!
            let oldCount = dic["send"]!.toInt()!
            
            let num = sendData.length + oldCount
            
            
            dic["send"] = String(num)
            
            showTextDic[client] = dic
            
            sendLabel.text = "发送：" + String(num)
        }
    }
    
    func longPressAction(sender: AnyObject) {
        
        let cell = sender.view as! TCPHostListTableViewCell
        
        println(cell.cellid)
        cellIndex = cell.cellid.toInt()!
        if cell.cellid != "9999"
        {
            var indexPath = NSIndexPath(forRow:cellIndex,inSection:1)
            self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            
            if (self.editHostView == nil)
            {
                serverSubClient  = dataArray[cellIndex] as! LFTcpClient
                
                let hostInfo = dataDictionary[serverSubClient]
                
                self.editHostView = TBEditHostView.editTcpSubClientHost(title: "编辑连接", hostInfo: hostInfo!)
                editHostView!.show(inView: self.view.window!)
                self.editHostView?.delegate = self
            }
        }
        else
        {
            
            if (self.editPortView == nil)
            {
                var indexPath = NSIndexPath(forRow:0,inSection:0)
                self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                
                self.editPortView = TBAddPortView.addPortView(host: "tcpServer")
                editPortView!.show(inView: self.view.window!)
                
                editPortView!.delegate = self
            }
        }
        
    }
    func repeatedSendData(timer:NSTimer)
    {
        let msgData = timer.userInfo as! NSData
        
        let error = serverSubClient!.sendData(msgData)
        
        self.checkReceiveData(error, client:serverSubClient , sendData:msgData)
    }
    
    func timerFire()
    {
        sendButton.selected = true
        showHistoryButton.userInteractionEnabled = false
        sendTypeButton.userInteractionEnabled = false
        inputTextField.userInteractionEnabled = false
        inputTextField.background = UIImage(named: "txt_bg_h")
    }
    
    func timerInvalidate()
    {
        repeatSend?.invalidate()
        repeatSend = nil
        sendButton.selected = false
        showHistoryButton.userInteractionEnabled = true
        sendTypeButton.userInteractionEnabled = true
        inputTextField.userInteractionEnabled = true
        inputTextField.background = UIImage(named: "txt_bg")
    }
    
    func checkSubClientList(list:Int)
    {
        if list == 0
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "tab_button_byte_pressed"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "tab_button_text_pressed"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "tab_button_byte_pressed"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "tab_button_text_pressed"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "tab_button_cycle_pressed"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "tab_button_cycle-off_pressed"), forState: UIControlState.Normal)
            }
            
            self.disconnectButton.setImage(UIImage(named: "tab_button_disconnect_pressed"), forState: UIControlState.Normal)
            
            self.showTypeButton.userInteractionEnabled = false
            self.sendTypeButton.userInteractionEnabled = false
            self.disconnectButton.userInteractionEnabled = false
            self.cycleButton.userInteractionEnabled = false
            self.sendButton.userInteractionEnabled = false
            self.showHistoryButton.userInteractionEnabled = false
            
        }
        else
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "tab_button_byte_default"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "tab_button_text_default"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "tab_button_byte_default"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "tab_button_text_default"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "tab_button_cycle_default"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "tab_button_cycle-off_default"), forState: UIControlState.Normal)
            }
            
            self.disconnectButton.setImage(UIImage(named: "tab_button_disconnect_default"), forState: UIControlState.Normal)
            
            self.showTypeButton.userInteractionEnabled = true
            self.sendTypeButton.userInteractionEnabled = true
            self.disconnectButton.userInteractionEnabled = true
            self.cycleButton.userInteractionEnabled = true
            self.sendButton.userInteractionEnabled = true
            self.showHistoryButton.userInteractionEnabled = true
        }
        
    }

    
    //MARK: - action
    
    @IBAction func textFieldDidFinshEdit() {
        if self.inputTextField.isFirstResponder() {
            self.inputTextField.resignFirstResponder()
        }
    }
    
    @IBAction func disconnectedAction(sender: AnyObject)
    {
        
        if serverSubClient != nil
        {
            let error = serverSubClient.disconnect()
            
            if (error != 0)
            {
                
                self.saveText(serverSubClient, showText:self.checkErrorCode(error),autoWrap:"yes")
                
            }
            else
            {
                println("断开成功")
                self.saveText(serverSubClient, showText: "\n断开成功！",autoWrap:"yes")
                
                self.dataDictionary.removeValueForKey(serverSubClient)
                self.dataArray.removeObject(serverSubClient)
                self.checkSubClientList(dataArray.count)
                self.serverSubClient = nil
                self.hostListTableView.reloadData()
                
            }
            
            if repeatSend != nil
            {
               self.timerInvalidate()
            }
            
        }
        
    }
    @IBAction func sendMessageAction(sender: AnyObject)
    {
        
        var button = sender as! UIButton
        
        if button.selected
        {
            self.timerInvalidate()
        }
        else
        {
            if inputTextField.text.isEmpty
            {
//                SVProgressHUD.showErrorWithStatus("不能发送空内容", maskType: SVProgressHUDMaskType.Black)
                return
            }
            else
            {
                dataLibrary.creatProductTable("HISTORY")
                let error =  dataLibrary.checkDataListByTable("HISTORY", withDataString: inputTextField.text)
                
                if error != "invalid"
                {
                    dataLibrary.deleteDataListByTable("HISTORY", pid: error)
                }
                dataLibrary.insertData(NSDictionary(objectsAndKeys:inputTextField.text,"history") as [NSObject : AnyObject] , intoTable: "HISTORY")
            }
            
            if cellIndex == 9999 || serverSubClient == nil
            {
                SVProgressHUD.showErrorWithStatus("请选择主机", maskType: SVProgressHUDMaskType.Black)
                
                return
            }
            
            var msgData:NSData
            
            //kCFStringEncodingGB_18030_2000
            
            let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
            
            if sendTypeButton.selected
            {
                
                let sumString = HexStringTransform.stringFromHexString2(inputTextField.text)
                msgData = sumString.dataUsingEncoding(enc, allowLossyConversion: true)!
                
            }
            else
            {
                msgData = inputTextField.text.dataUsingEncoding(enc, allowLossyConversion: true)!
            }
            
            if cycleButton.selected
            {
                
                let infoDict = dataDictionary[serverSubClient]!
                
                let repeat = infoDict["repeat"]! as NSString
                
                let interval = repeat.doubleValue / 1000.0
                
                repeatSend = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "repeatedSendData:", userInfo: msgData, repeats: true)
                
                repeatSend?.fire()
                
                self.timerFire()
            }
            else
            {
                
                let error = serverSubClient!.sendData(msgData)
                
                self.checkReceiveData(error, client:serverSubClient, sendData:msgData)
            }
        }
        
        
    }
    
    
    @IBAction func showDataTypeAction(sender: AnyObject)
    {
        var button = sender as! UIButton
        
        button.selected = !button.selected
        
    }
    @IBAction func sendDataTypeAction(sender: AnyObject)
    {
        var button = sender as! UIButton
        
        button.selected = !button.selected

        if inputTextField.text.isEmpty
        {
            return
        }
        
        if (button.selected == true)
        {
//            inputTextField.text = self.hex2x(inputTextField.text)
            inputTextField.text = HexStringTransform.hexStringFromString(inputTextField.text)
        }
        else
        {
            inputTextField.text = HexStringTransform.stringFromHexString2(inputTextField.text)
            
        }
    }
    
    @IBAction func clearAction(sender: AnyObject)
    {
        if serverSubClient != nil
        {
            self.clearText(serverSubClient)
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
        }
        else
        {
            self.showTextView.text = ""
        }
        
    }
    
    
    @IBAction func cycleAction(sender: AnyObject)
    {
        
        var button:UIButton = sender as! UIButton
        
        
        if repeatSend != nil
        {
            self.timerInvalidate()
        }
        button.selected = !button.selected
        
    }
    
    
    @IBAction func showHistoryListAction(sender: AnyObject)
    {
        historyListView = TBHistoryListView.showHistoryListViewBy(type: "TcpServer")
        historyListView?.delegate = self
        historyListView?.show(inView: self.view.window!)
        
    }
    
    
    
    
    //MARK: - notification
    func keyboardWillShow(notification: NSNotification) {
        
        if !self.inputTextField.isFirstResponder() {
            return
        }
        
        let keyboardUserInfo: [NSObject : AnyObject]? = notification.userInfo
        let keyboardFrameValue: AnyObject? = keyboardUserInfo?[UIKeyboardFrameEndUserInfoKey]
        let keyboardDuration: AnyObject? = keyboardUserInfo?[UIKeyboardAnimationDurationUserInfoKey]
        
        
        var keyboardFrame: CGRect = CGRectZero
        
        if let value: AnyObject = keyboardFrameValue {
            if value is NSValue {
                let val = (value as! NSValue)
                keyboardFrame = val.CGRectValue()
            }
        }
        
        var timerInterval: CFTimeInterval = 0
        if let duration: AnyObject = keyboardDuration {
            if duration is NSNumber {
                let numDuration = (duration as! NSNumber)
                timerInterval = numDuration.doubleValue
            }
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(timerInterval)
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bottomView.bounds) - (CGRectGetHeight(keyboardFrame) + CGRectGetHeight(self.bottomView.bounds)))
        
        CATransaction.commit()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardUserInfo: [NSObject : AnyObject]? = notification.userInfo
        let keyboardDuration: AnyObject? = keyboardUserInfo?[UIKeyboardAnimationDurationUserInfoKey]
        var timerInterval: CFTimeInterval = 0
        if let duration: AnyObject = keyboardDuration {
            if duration is NSNumber {
                let numDuration = (duration as! NSNumber)
                timerInterval = numDuration.doubleValue
            }
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(timerInterval)
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        self.bottomView.transform = CGAffineTransformIdentity
        
        CATransaction.commit()
    }
    
    
    func resignActionNotification(notification: NSNotification)
    {
        
        if repeatSend != nil
        {
            self.timerInvalidate()
        }
        
        tcpServer.stop()
        hostState = "停止监听"
    }
    
    func actionNotification(notification: NSNotification)
    {
        let hostport = Int32(hostPort.toInt()!)
        tcpServer.stop()
        hostState = self.getHostErrorCode(tcpServer.start(hostport))
        tcpServer.delegate = self
            
        hostListTableView.reloadData()
    }
    
    //MARK:tableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            return dataArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TCPHostList", forIndexPath: indexPath) as! TCPHostListTableViewCell
        
        var selectedView = UIView(frame: cell.contentView.frame)
        
        var line:UIView = UIView(frame: CGRectMake(0, CGRectGetHeight(cell.contentView.frame), CGRectGetWidth(cell.contentView.frame), 1))
        
        line.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.2)
        selectedView.addSubview(line)
        cell.selectedBackgroundView = selectedView
        cell.selectedBackgroundView.backgroundColor = UIColor.whiteColor()
        
        let gesture = UILongPressGestureRecognizer(target: self, action:"longPressAction:" )
        cell.addGestureRecognizer(gesture)
        
        if indexPath.section == 0
        {
            cell.ipLabel.text = localIp
            cell.portLabel.text = hostPort
            cell.stateLabel.text = hostState
            cell.cellid = "9999"
            
            return cell
        }
        else
        {
            println("-----xxxxxx------")
            let subClient = dataArray[indexPath.row] as! LFTcpClient
            
            cell.ipLabel.text = subClient.ip
            cell.portLabel.text = String(subClient.port)
            cell.stateLabel.text = "已连接"
            cell.cellid = String(indexPath.row)
            return cell
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
        } else if (editingStyle == UITableViewCellEditingStyle.Insert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TCPHostListTableViewCell
        
        UIView.animateWithDuration(0.001, animations: { () -> Void in
            
            cell.contentView.backgroundColor = leftBgColor
            
            }) { (flag) -> Void in
                cell.contentView.backgroundColor = UIColor.whiteColor()
         
                if indexPath.section == 0
                {
                    println("ZyZyZyZyZyZy")
                    println(self.hostState)
                    if self.hostState == "初始化失败！" || self.hostState == "停止监听"
                    {
                        let hostport = Int32(self.hostPort.toInt()!)
                        self.tcpServer.stop()
                        self.hostState = self.getHostErrorCode(self.tcpServer.start(hostport))
                        self.tcpServer.delegate = self
//                        SVProgressHUD.showSuccessWithStatus("TCP Server 正在监听", maskType: SVProgressHUDMaskType.Black)
                    }
                    else
                    {
                        self.tcpServer.stop()
                        self.hostState = "停止监听"
//                        SVProgressHUD.showErrorWithStatus("TCP Server 停止监听", maskType: SVProgressHUDMaskType.Black)
                    }
                    self.cellIndex = 9999
                    self.hostListTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    
                    var indexPath = NSIndexPath(forRow:0,inSection:0)
                    
                    self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    
                    /**
                    *  按键功能失效
                    */
                    self.checkSubClientList(0)
                    
                }
                else
                {
                    self.cellIndex = indexPath.row
                    
                    let selectClient = self.dataArray[indexPath.row] as! LFTcpClient
                    
                    if self.serverSubClient != selectClient
                    {
                        if self.repeatSend != nil
                        {
                            self.timerInvalidate()
                        }
                        
                        self.serverSubClient = selectClient
                        var dic = self.showTextDic[self.serverSubClient]!
                        
//                        if dic["text"] != nil
//                        {
//                            self.showTextView.text = dic["text"]
//                        }
//                        else
//                        {
//                            self.showTextView.text = ""
//                        }
                        
                        self.receiveLabel.text = "接收：" + dic["receive"]!
                        self.sendLabel.text = "发送：" + dic["send"]!
                        
                    }
                    self.checkSubClientList(1)
                }
        }

               
    }

    //MARK:TBAddportDelegate
    func getTcpServerPort(port: String) {
        
        let hostport = Int32(port.toInt()!)

        self.hostPort = port
        self.tcpServer.stop()
        
        self.hostState = self.getHostErrorCode(self.tcpServer.start(hostport))

        var indexPath = NSIndexPath(forRow:0,inSection:0)
        
        self.hostListTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        
        self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
    }
    
    func cancelAction() {
        if self.editPortView != nil
        {
            self.editPortView = nil
        }
        
        if self.editHostView != nil
        {
            self.editHostView = nil
        }
    }
    
    //MARK:TBTcpListenerDelegate
    func receiveClient(client: LFTcpClient) {
        
        dispatch_async(dispatch_get_main_queue(), {

            let subClient = client as LFTcpClient
            subClient.delegate = self
            self.dataArray.addObject(subClient)
            self.checkSubClientList(self.dataArray.count)
            self.createDictionaryByTcpClient(subClient)
            var dic :Dictionary = Dictionary<String, String>()

            dic["receive"] = "0"
            dic["send"] = "0"
            self.showTextDic[client] = dic
//            self.showTextView.text = ""
            
            self.saveText(client, showText: "\n建立连接", autoWrap: "yes")
            
            self.hostListTableView.reloadData()
            
            if self.serverSubClient == nil
            {
                self.serverSubClient = client
                
                self.cellIndex = self.dataArray.count - 1
            }
            
            var indexPath = NSIndexPath(forRow:self.cellIndex,inSection:1)
            self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
//            if self.show
//            {
//               SVProgressHUD.showInfoWithStatus(NSString(format: "IP: %@ \n端口: %lld", client.ip, client.port) as String, maskType: SVProgressHUDMaskType.Gradient)
//            }
            
            
        })
        
    }
    func onTcpClient(tcpClient: LFTcpClient!, didConnect result: Int64) {

        
    }
    
    func onTcpClient(tcpClient: LFTcpClient!, didReadData str: String!, length: Int32)
    {
        println("receive data------->" + str)

        dispatch_async(dispatch_get_main_queue(), {
            
            
            if str != nil
            {
                
                var dictionary: AnyObject = self.dataDictionary[tcpClient]!
                
                let reply = dictionary["autoReply"] as! String
                let wrap = dictionary["autoWrap"] as! String
                
                if self.serverSubClient == tcpClient
                {
                    if(self.showTypeButton.selected)
                    {
//                        let dataString = self.hex2x(str)
                        let dataString = HexStringTransform.hexStringFromString(str)
                        self.saveText(self.serverSubClient, showText:dataString,autoWrap:wrap)
                        
                    }
                    else
                    {
                        self.saveText(self.serverSubClient, showText:str,autoWrap:wrap)
                        
                    }
                    
                    
                    if self.showTextDic[self.serverSubClient] != nil
                    {
                        var dic = self.showTextDic[self.serverSubClient]!
                        
                        let num = length + dic["receive"]!.toInt()!
                        
                        dic["receive"] = String(num)
                        
                        self.showTextDic[self.serverSubClient] = dic
                        
                        self.receiveLabel.text = "接收：" + String(num)
                    }
                    
                    if reply == "yes"
                    {
                        //kCFStringEncodingGB_18030_2000
                        
                        let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                        
                        let msgData = str.dataUsingEncoding(enc, allowLossyConversion: true)!
                        let error = tcpClient.sendData(msgData)
                        
                        self.checkReceiveData(error, client: self.serverSubClient, sendData:msgData)
                    }
                    
                }
                else
                {
                    for client  in self.dataArray
                    {
                        
                        if client as! LFTcpClient == tcpClient
                        {
                            if(self.showTypeButton.selected)
                            {
//                                let dataString = self.hex2x(str)
                                let dataString = HexStringTransform.hexStringFromString(str)
                                self.saveTextInBackground(client as! LFTcpClient, showText:dataString,autoWrap:wrap)
                                
                            }
                            else
                            {
                                self.saveTextInBackground(client as! LFTcpClient, showText:str,autoWrap:wrap)
                                
                            }
                            
                            if self.showTextDic[client as! LFTcpClient] != nil
                            {
                                var dic = self.showTextDic[client as! LFTcpClient]!
                                
                                let num = length + dic["receive"]!.toInt()!
                                
                                dic["receive"] = String(num)
                                self.showTextDic[client as! LFTcpClient] = dic
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func onTcpClientDidDisconnect(tcpClient: LFTcpClient!, error: Int64) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if self.serverSubClient == tcpClient
            {
                if self.repeatSend != nil
                {
                   self.timerInvalidate()
                }
            
                self.serverSubClient = nil
                self.clearText(tcpClient)
            }
            self.dataArray.removeObject(tcpClient)
            self.dataDictionary.removeValueForKey(tcpClient)
            self.checkSubClientList(self.dataArray.count)
            self.hostListTableView.reloadData()
            
//            self.showTextView.text = tcpClient.ip + ":  " + self.checkErrorCode(error)
            self.saveText(tcpClient, showText: self.checkErrorCode(error), autoWrap: "yes")
            
        })
        
    println("断开链接")
    }
    
    //MARK: TBHistoryDelegate
    
    func selectDataToTcpServer(dataString: String) {
        self.inputTextField.text = dataString
    }
    
    //MARK: TBEditHostDelegate
    
    func editTcpSubClient(hostInfo: Dictionary<String, String>) {
        
        dataDictionary.removeValueForKey(serverSubClient)
        
        dataDictionary[serverSubClient] = hostInfo
    }
    func deleteHost()
    {
        serverSubClient.disconnect()
        self.clearText(serverSubClient)
        self.dataDictionary.removeValueForKey(serverSubClient)
        self.dataArray.removeObject(serverSubClient)
       
        self.hostListTableView.reloadData()
        
        self.checkSubClientList(dataArray.count)
    }

    
    
}