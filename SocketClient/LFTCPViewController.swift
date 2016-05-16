//
//  LFTCPViewController.swift
//  SocketClient
//
//  Created by Lemon on 15-5-22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit

class LFTCPViewController: UIViewController,LFTcpClientDelegate,TBEditHostDeletage,TBHistoryDelegate{

    @IBOutlet weak var showTypeButton: UIButton!
    @IBOutlet weak var sendTypeButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cycleButton: UIButton!
    
    @IBOutlet weak var showHistoryButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    
    @IBOutlet weak var hostListTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    
    @IBOutlet weak var showTextView: UITextView!
//    var tcpClient: LFTcpClient!
    
    var nextLine:NSString = "\n"
    
    var hostIP: String? = ""
    var hostPort: UInt16! = 0
    var reConnect: String = ""
    
    var cellIndex: Int!

    var dataArray = []
    
    var editHostView :TBEditHostView?
    var historyListView: TBHistoryListView?
    
    var dataLibrary = DataLibrary.shareDataLibrary()
    var hostListDic = Dictionary<String, LFTcpClient>()
    var showTextDic = Dictionary<String, Dictionary<String, String>>()
    
    var repeatSend:NSTimer?
    
    //MARK: override func
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None
        // Do any additional setup after loading the view.

         hostListTableView.tableFooterView = UIView(frame:CGRectZero)
        
        
        
        dataLibrary.creatProductTable("TCP")
        
        dataArray = dataLibrary.getallDataByTable("TCP")
        
        for dictionary in dataArray
        {
            let pid = dictionary["p_id"] as! String
            
            var dic :Dictionary = Dictionary<String, String>()
            dic["text"] = ""
            dic["receive"] = "0"
            dic["send"] = "0"
            showTextDic[pid] = dic
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
            
            var tcpClient = LFTcpClient()
            
            let errorCode = tcpClient.EnableHeartBeat(10 , interval: 1 , quantity: 10)
            
            if errorCode != 0
            {
                self.saveText(pid, showText: self.checkErrorCode(errorCode),autoWrap:"yes")
            }
            
            
            tcpClient.delegate = self;
            
            hostListDic[pid] = tcpClient
            
        }
        self.checkClientList(dataArray.count)
        
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
    

    //MARK: - action
    
    @IBAction func textFieldDidFinshEdit() {
        if self.inputTextField.isFirstResponder() {
            self.inputTextField.resignFirstResponder()
        }
    }
    @IBAction func disconnectedAction(sender: AnyObject)
    {
       
        
        if cellIndex != nil && dataArray.count > cellIndex
        {

            let dictionary: AnyObject = dataArray[cellIndex]
            
            let pid = dictionary["p_id"] as! String
            
            var tcpClient :LFTcpClient = hostListDic[pid]!
            if connectButton.selected
            {
                let error = tcpClient.disconnect()
                
                if (error != 0)
                {
                    self.saveText(pid, showText: self.checkErrorCode(error),autoWrap:"yes")
                    
                }
                else
                {
                    println("断开成功")
                    self.saveText(pid, showText: "断开成功！",autoWrap:"yes")
                    
                    connectLabel.text = "连接"
                    connectButton.selected = false
                    println(tcpClient.state)
                    
                    hostListTableView.reloadData()
                    
                    var indexPath = NSIndexPath(forRow:self.cellIndex,inSection:0)
                    
                    self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    
                }
                
            }
            else
            {
                println(tcpClient.state)
                    
                var error =  tcpClient.beginConnect(hostIP, port: hostPort, timerout:1000)
                
                if error != 0
                {
                    self.saveText(pid, showText: self.checkErrorCode(error),autoWrap:"yes")
                    
                }
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
            
            if cellIndex == nil
            {
                SVProgressHUD.showErrorWithStatus("请选择主机", maskType: SVProgressHUDMaskType.Black)
                return
                
            }
            else if cellIndex >= dataArray.count
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
                
                let repeat = dataArray[cellIndex]["repeat"] as! NSString
                
                let interval = repeat.doubleValue / 1000.0
                
                repeatSend = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "repeatedSendData:", userInfo: msgData, repeats: true)
                
                repeatSend?.fire()
                
                self.timerFire()
            }
            else
            {
                
                var pid = dataArray[cellIndex]["p_id"] as! String
                
                var tcpClient = hostListDic[pid]
                let error = tcpClient!.sendData(msgData)
                
                self.checkReceiveData(error, pid: pid, sendData:msgData)
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
        
        if cellIndex != nil && dataArray.count > cellIndex
        {
            let dictionary: AnyObject = dataArray[cellIndex]
            
            let pid = dictionary["p_id"] as! String
            
            self.clearText(pid)
            
        }
        
        receiveLabel.text = "接收：0"
        sendLabel.text = "发送：0"
    }
    
    @IBAction func deleteAction(sender: AnyObject)
    {
        if repeatSend != nil
        {
            self.timerInvalidate()
            
        }
        
        if cellIndex != nil && dataArray.count > cellIndex
        {
            let dictionary: AnyObject = dataArray[cellIndex]
            
            
            var pid = dictionary["p_id"] as! String
            
            
            if hostListDic[pid] != nil
            {
                hostListDic.removeValueForKey(pid)
            }
            if showTextDic[pid] != nil
            {
                showTextDic.removeValueForKey(pid)
            }
            dataLibrary.deleteDataListByTable("TCP", withIp: dictionary["ip"] as! String, andPort: dictionary["port"] as! String)
            
            dataArray = dataLibrary.getallDataByTable("TCP")
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
            
            hostListTableView.reloadData()
        
            SVProgressHUD.showSuccessWithStatus("删除成功", maskType: SVProgressHUDMaskType.Black)
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
        historyListView = TBHistoryListView.showHistoryListViewBy(type: "TCP")
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
    
    
   
    
    //MARK: function
    
    func addConnect(receiveData:Dictionary<String,String>) {
        
        let error =  dataLibrary.checkDataListByTable("TCP", withIp: receiveData["ip"], andPort: receiveData["port"])
        
        if !error
        {
            dataLibrary.insertData(NSDictionary(objectsAndKeys: receiveData["ip"]!,"ip",receiveData["port"]!,"port","未连接","state",receiveData["autoConnect"]!,"autoConnect",receiveData["autoWrap"]!,"autoWrap",receiveData["repeat"]!,"repeat",receiveData["autoReply"]!,"autoReply") as [NSObject : AnyObject] , intoTable: "TCP")
            dataArray = dataLibrary.getallDataByTable("TCP")
            
            let dictionary: AnyObject = dataArray.lastObject!
            cellIndex = dataArray.count - 1
        
            let pid = dictionary["p_id"] as! String
            
            var dic :Dictionary = Dictionary<String, String>()
            dic["text"] = ""
            dic["receive"] = "0"
            dic["send"] = "0"
            showTextDic[pid] = dic
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
            
            var tcpClient = LFTcpClient()
            
            let errorCode = tcpClient.EnableHeartBeat(10 , interval: 1 , quantity: 10)
            
            if errorCode != 0
            {
                self.saveText(pid, showText: self.checkErrorCode(errorCode),autoWrap:"yes")
            }
        
            var error =  tcpClient.beginConnect(self.hostIP, port: self.hostPort, timerout:1000)
            
            if error != 0
            {
                self.saveText(pid, showText: self.checkErrorCode(error),autoWrap:"yes")
                
            }
        
            tcpClient.delegate = self;
        
            hostListDic[pid] = tcpClient
            
            hostListTableView.reloadData()
            
            self.checkClientList(dataArray.count)
            
        }
        else
        {
            SVProgressHUD.showErrorWithStatus("主机已存在", maskType: SVProgressHUDMaskType.Black)
            return
        }
        
    }
    
    func repeatedSendData(timer:NSTimer)
    {
        
        let msgData = timer.userInfo as! NSData
        
        var pid = dataArray[cellIndex]["p_id"] as! String
        
        var tcpClient = hostListDic[pid]

        let error = tcpClient!.sendData(msgData)
        
        self.checkReceiveData(error, pid: pid, sendData: msgData)
    }
    
    func checkReceiveData(error:Int64,pid:String,sendData:NSData)
    {
        if error != 0
        {
            
            showTextView.text = showTextView.text + self.checkErrorCode(error) + (nextLine as String)
            
        }
        else
        {
            
            var dic = showTextDic[pid]!
            let oldCount = dic["send"]!.toInt()!
            
            let num = sendData.length + oldCount
            
            
            dic["send"] = String(num)
            
            showTextDic[pid] = dic
            
            sendLabel.text = "发送：" + String(num)
        }
    }
    
    //自动重连
    func reconnectHost()
    {
        
        var dictionary: AnyObject = dataArray[cellIndex]
        
        var pid = dictionary["p_id"] as! String
        
        var tcpClient: LFTcpClient = hostListDic[pid]!
        
        println(tcpClient.state)
        if !tcpClient.state
        {
            self.saveText(pid, showText: "\n重新连接",autoWrap:"yes")
            
            tcpClient.beginConnect(hostIP, port: hostPort, timerout: 1000)
            
        }
        
    }
    
    //保存文本信息
    
    func saveText(pid:String,showText:String,autoWrap:String)
    {
        var nextData = ""
        if autoWrap == "yes"
        {
            nextData = "\n"
        }
        if showTextDic[pid] != nil
        {
            var dic :Dictionary  = showTextDic[pid]!
            
            if dic["text"] != nil
            {
                var showNewText = showText + nextData + dic["text"]!
                
                dic["text"] = showNewText
                
                showTextDic[pid] = dic
                
                showTextView.text = showNewText
            }
            else
            {
                dic["text"] = showText + nextData
                
                showTextDic[pid] = dic
                
                showTextView.text = showText + nextData
            }
            
        }
        else
        {
            var dic: Dictionary = Dictionary<String, String>()
            
            dic["text"] = showText + nextData
            
            showTextDic[pid] = dic
            
            showTextView.text = showText + nextData
        }
        
    }
    func saveTextInBackground(pid:String,showText:String,autoWrap:String)
    {
        
        var nextData = ""
        if autoWrap == "yes"
        {
            nextData = "\n"
        }
        
        if showTextDic[pid] != nil
        {
            
            var dic :Dictionary  = showTextDic[pid]!
            
            if dic["text"] != nil
            {
                var showNewText = showText + nextData + dic["text"]!
                
                dic["text"] = showNewText
                
                showTextDic[pid] = dic
            }
            else
            {
                var dic: Dictionary = Dictionary<String, String>()
                
                dic["text"] = showText + nextData
                showTextDic[pid] = dic
            }
            
        }
        else
        {
            var dic: Dictionary = Dictionary<String, String>()
            
            dic["text"] = showText + nextData
            showTextDic[pid] = dic
            
        }
        
    }
    func longPressAction(sender: AnyObject) {
        
        let cell = sender.view as! TCPHostListTableViewCell
        
        println(cell.cellid)
        cellIndex = cell.cellid.toInt()!
        var indexPath = NSIndexPath(forRow:cellIndex,inSection:0)
        self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        hostIP = cell.ipLabel.text
        hostPort = UInt16((cell.portLabel.text?.toInt())!)
        
        if (self.editHostView == nil)
        {
            self.editHostView = TBEditHostView.editHost(title: "编辑链接", hostInfo: dataArray[cellIndex] as! Dictionary<String, String>, isUdp: false)
            self.editHostView?.show(inView: self.view.window!)
            
            self.editHostView!.delegate = self
        }
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

    func clearText(pid:String)
    {
        if showTextDic[pid] != nil
        {
            
            var dic:Dictionary = showTextDic[pid]!
            
            if dic["text"] != nil
            {
                dic["text"] = ""
            }
            
            if dic["receive"] != nil
            {
                dic["receive"] = "0"
            }
            if dic["send"] != nil
            {
                dic["send"] = "0"
            }
            
            showTextDic[pid] = dic
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
            
        }
        
    }
    
    func checkErrorCode(code:Int64) ->String
    {
        var errString = ""
        switch code
        {
        case -100000001:
            errString = "对象已经释放"
        case -100000002:
            errString = "调用了无效的函数"
        case -100000003:
            errString = "函数传入无效参数"
        case -100000004:
            errString = "函数重复调用错误"
        case -100000005:
            errString = "内存申请失败"
        case -100000006:
            errString = "系统资源不够"
        case -100000007:
            errString = "死锁错误"
        case -100000008:
            errString = "地址已经在使用中错误"
        case -100000009:
            errString = "地址在当前主机中不可用"
        case -100000010:
            errString = "数据太长"
        case -100000011:
            errString = "广播地址发送数据错误"
        case -100000012:
            errString = "网络不可到达"
        case -100000013:
            errString = "系统IO接口读写错误"
        case -100000014:
            errString = "连接动作被拒绝"
        case -100000015:
            errString = "连接动作超时"
        case -100000016:
            errString = "网络未连接错误"
        case -100000017:
            errString = "链接超时断开错误"
        case -100000018:
            errString = "远程主机关闭连接"
        case -100000019:
            errString = "对象被挂起"
        case -100000020:
            errString = "对象内部资源被损坏"
        case -100000021:
            errString = "未启动先决条件"
        case -100000022:
            errString = "非法调用"
        default:
            break
        }
        return errString
    }
    
    
    func checkClientList(list:Int)
    {
        if list == 0
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "mid_byte_h"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "mid_text_h"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "mid_byte_h"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "mid_text_h"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "mid_cycle_h"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "mid_cycle-off_h"), forState: UIControlState.Normal)
            }
            
            self.connectButton.setImage(UIImage(named: "mid_connect_h"), forState: UIControlState.Normal)
            
            self.showTypeButton.userInteractionEnabled = false
            self.sendTypeButton.userInteractionEnabled = false
            self.connectButton.userInteractionEnabled = false
            self.cycleButton.userInteractionEnabled = false
            self.sendButton.userInteractionEnabled = false
            self.showHistoryButton.userInteractionEnabled = false
            
        }
        else
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "mid_byte"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "mid_text"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "mid_byte"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "mid_text"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "mid_cycle"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "mid_cycle-off"), forState: UIControlState.Normal)
            }
            
            if self.connectButton.selected
            {
                
                self.connectButton.setImage(UIImage(named: "mid_disconnect"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.connectButton.setImage(UIImage(named: "mid_connect"), forState: UIControlState.Normal)
            }
            
            self.showTypeButton.userInteractionEnabled = true
            self.sendTypeButton.userInteractionEnabled = true
            self.connectButton.userInteractionEnabled = true
            self.cycleButton.userInteractionEnabled = true
            self.sendButton.userInteractionEnabled = true
            self.showHistoryButton.userInteractionEnabled = true
        }
        
    }
    //MARK: tableviewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
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
        
        let dictionary: AnyObject = dataArray[indexPath.row]
        
        let pid = dictionary["p_id"] as! String
        
        if hostListDic[pid] != nil
        {
            var tcpClient :LFTcpClient = hostListDic[pid]!
            
            if tcpClient.state
            {
              cell.stateLabel.text = "已连接"
            }
            else
            {
                cell.stateLabel.text = "未连接"
            }
        }
        else
        {
            cell.stateLabel.text = "未连接"
        }
        
        cell.updateHostListWith((dictionary["ip"] as! String), port: (dictionary["port"] as! String))
        
        cell.cellid = String(indexPath.row)
        
        let gesture = UILongPressGestureRecognizer(target: self, action:"longPressAction:" )
        
        
        cell.addGestureRecognizer(gesture)
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
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
            
            cell.contentView.backgroundColor = midBgColor
            
            }) { (flag) -> Void in
                cell.contentView.backgroundColor = UIColor.whiteColor()
                
                if self.repeatSend != nil && self.cellIndex != indexPath.row
                {
                    self.timerInvalidate()
                }
                
                var dictionary: AnyObject = self.dataArray[indexPath.row]
                
                var pid = dictionary["p_id"] as! String
                
                if  self.cellIndex == nil || self.cellIndex != indexPath.row
                {
                    let dic = self.showTextDic[pid]!
                    self.showTextView.text = dic["text"]
                    self.receiveLabel.text = "接收：" + dic["receive"]!
                    self.sendLabel.text = "发送：" + dic["send"]!
                    
                }
                
                self.hostIP = cell.ipLabel.text
                
                self.hostPort = UInt16((cell.portLabel.text?.toInt())!)
                var tcpClient = self.hostListDic[pid]
                
                println(tcpClient!.state)
                
                if self.cellIndex != nil && self.cellIndex == indexPath.row
                {
                    if !tcpClient!.state
                    {
                        println("重新连接")
                        
                        var error =  tcpClient!.beginConnect(self.hostIP, port: self.hostPort, timerout:1000)
                        
                        if error != 0
                        {
                            self.saveText(pid, showText: self.checkErrorCode(error),autoWrap:"yes")
                            
                        }
                    }
                    
                }
                else
                {
                    if tcpClient!.state
                    {
                        self.connectButton.selected = true
                        self.connectLabel.text = "断开"
                        
                    }
                    else
                    {
                        self.connectButton.selected = false
                        self.connectLabel.text = "连接"
                    }
                    
                    
                }
                
                self.cellIndex = indexPath.row
                
        }
        
    }
    
    
    
  
    //MARK: - LFTcpDelegate
    
    func onTcpClient(tcpClient: LFTcpClient!, didConnect result: Int64) {
        dispatch_async(dispatch_get_main_queue(), {
            
            if(result != 0)
            {
                if self.dataArray.count > self.cellIndex
                {
                    var dictionary: AnyObject = self.dataArray[self.cellIndex]
                    
                    let pid = dictionary["p_id"] as! String
                    self.saveText(pid, showText: self.checkErrorCode(result),autoWrap:"yes")
                    println(dictionary)
                    
                    var auto:String = dictionary["autoConnect"] as! String
                    if auto == "yes"
                    {
                        self.reconnectHost()
                    }
                }

            }
            else
            {
                var dictionary: AnyObject = self.dataArray[self.cellIndex]
                
                let pid = dictionary["p_id"] as! String
                self.saveText(pid, showText: "\n连接成功！",autoWrap:"yes")
                self.connectLabel.text = "断开"
                self.connectButton.selected = true
            }
            
            self.hostListTableView.reloadData()
            
            
            var indexPath = NSIndexPath(forRow:self.cellIndex,inSection:0)
            
            self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            println(tcpClient.state)
        })

    }
    
    func onTcpClient(tcpClient: LFTcpClient!, didReadData str: String!, length: Int32)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            
            if str != nil
            {
                
                if self.dataArray.count > self.cellIndex
                {
                    var dictionary: AnyObject = self.dataArray[self.cellIndex]
                    
                    let pid = dictionary["p_id"] as! String
                    let reply = dictionary["autoReply"] as! String
                    let wrap = dictionary["autoWrap"] as! String
                    
                   if self.hostListDic[pid] == tcpClient
                   {
                        if(self.showTypeButton.selected)
                        {
                            let dataString = HexStringTransform.hexStringFromString(str)
                            self.saveText(pid, showText:dataString,autoWrap:wrap)
                            
                        }
                        else
                        {
                            self.saveText(pid, showText:str,autoWrap:wrap)
                            
                        }
                    
                    
                    if self.showTextDic[pid] != nil
                    {
                        var dic = self.showTextDic[pid]!
                        
                        let num = length + dic["receive"]!.toInt()!
                        
                        dic["receive"] = String(num)
                        
                        self.showTextDic[pid] = dic
                        
                        self.receiveLabel.text = "接收：" + String(num)
                    }
                    
                    if reply == "yes"
                    {
                        //kCFStringEncodingGB_18030_2000
                        
                        let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                        
                        let msgData = str.dataUsingEncoding(enc, allowLossyConversion: true)!
                        let error = tcpClient.sendData(msgData)
                        
                        self.checkReceiveData(error, pid: pid, sendData:msgData)
                    }
                    
                   }
                    else
                   {
                        for dic in self.dataArray
                        {
                            let sub_pid = dic["p_id"] as! String
                            
                            let wrap = dic["autoWrap"] as! String
                            var client = self.hostListDic[sub_pid]
                            
                            if client == tcpClient
                            {
                                if(self.showTypeButton.selected)
                                {
//                                    let dataString = self.hex2x(str)
                                    let dataString = HexStringTransform.hexStringFromString(str)
                                    self.saveTextInBackground(sub_pid, showText:dataString,autoWrap:wrap)
                                    
                                }
                                else
                                {
                                    self.saveTextInBackground(sub_pid, showText:str,autoWrap:wrap)
                                    
                                }
                                
                                if self.showTextDic[sub_pid] != nil
                                {
                                    var dic = self.showTextDic[sub_pid]!
                                    
                                    let num = length + dic["receive"]!.toInt()!
                                    
                                    dic["receive"] = String(num)
                                    self.showTextDic[sub_pid] = dic
                                }
                                
                            }
                            
                        }
                    
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func onTcpClientDidDisconnect(tcpClient: LFTcpClient!, error: Int64) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            var dictionary: AnyObject = self.dataArray[self.cellIndex]
            
            let pid = dictionary["p_id"] as! String
            self.saveText(pid, showText: self.checkErrorCode(error),autoWrap:"yes")
            
            println(dictionary)
            
            var auto:String = dictionary["autoConnect"] as! String
            if auto == "yes"
            {
                self.reconnectHost()
            }
            else
            {
                self.hostListTableView.reloadData()
                var indexPath = NSIndexPath(forRow:self.cellIndex,inSection:0)
                
                self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
                let client = self.hostListDic[pid]
                
                if client == tcpClient
                {
                    self.connectButton.selected = false
                    self.connectLabel.text = "连接"
                }
            }
        })

    }
    //MARK: TBEditHostDelegate
    
    func editTcpHost(hostInfo: Dictionary<String, String>) {
        
        hostIP = hostInfo["ip"]
        let port = hostInfo["port"]
        hostPort = UInt16((port!.toInt())!)
        
        dataLibrary.replaceData(NSDictionary(objectsAndKeys: hostInfo["ip"]!,"ip",hostInfo["port"]!,"port",hostInfo["repeat"]!,"repeat",hostInfo["autoWrap"]!,"autoWrap","未连接","state",hostInfo["autoConnect"]!,"autoConnect",hostInfo["autoReply"]!,"autoReply",hostInfo["p_id"]!,"p_id") as [NSObject : AnyObject] , intoTable: "TCP")
        dataArray = dataLibrary.getallDataByTable("TCP")
        
//        var sendDict: AnyObject = dataArray.lastObject!
//        
//        var pid = sendDict["p_id"] as! String
//        
//        var sendObject = LFTcpClient()
//        sendObject.delegate = self;
//        
//        hostListDic[pid] = sendObject
//        
//        var dic :Dictionary = Dictionary<String, String>()
//        dic["text"] = ""
//        dic["receive"] = "0"
//        dic["send"] = "0"
//        showTextDic[pid] = dic
        
        hostListTableView.reloadData()
        var indexPath = NSIndexPath(forRow:cellIndex,inSection:0)
        self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    func cancelAction()
    {
        if self.editHostView != nil
        {
            self.editHostView = nil
        }
    }
    
    func deleteHost()
    {
        if cellIndex != 10000 && cellIndex < dataArray.count
        {
            if repeatSend != nil
            {
                self.timerInvalidate()
            }
    
            let dictionary: AnyObject = dataArray[cellIndex]
            var pid = dictionary["p_id"] as! String
            
            
            if hostListDic[pid] != nil
            {
                hostListDic.removeValueForKey(pid)
            }
            if showTextDic[pid] != nil
            {
                showTextDic.removeValueForKey(pid)
            }
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
            
            dataLibrary.deleteDataListByTable("TCP", withIp: dictionary["ip"] as! String, andPort: dictionary["port"] as! String)
            
            dataArray = dataLibrary.getallDataByTable("TCP")
            
            hostListTableView.reloadData()
            
             SVProgressHUD.showSuccessWithStatus("删除成功", maskType: SVProgressHUDMaskType.Black)
            self.checkClientList(dataArray.count)
        }
        
    }
    
    // MARK: TBHistoryDelegate
    
    func selectDataToTCP(dataString: String) {
        self.inputTextField.text = dataString
    }
    // MARK: Notification
    func resignActionNotification(notification: NSNotification)
    {
        
        if repeatSend != nil
        {
            self.timerInvalidate()
        }
        
    }
    func actionNotification(notification: NSNotification)
    {
        
        hostListTableView.reloadData()
        
    }
    
    
    
}
