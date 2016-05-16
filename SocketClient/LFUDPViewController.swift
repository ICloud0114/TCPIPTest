//
//  LFUDPViewController.swift
//  SocketClient
//
//  Created by Lemon on 15-5-22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit



class LFUDPViewController: UIViewController,TBUdpClientDelegate,TBAddPortDelegate,TBEditHostDeletage,TBHistoryDelegate {

    @IBOutlet weak var showTypeButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
  
    @IBOutlet weak var sendTypeButton: UIButton!
    @IBOutlet weak var cycleButton: UIButton!

    @IBOutlet weak var showHistoryButton: UIButton!
    @IBOutlet weak var hostListTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var showTextView: UITextView!
    
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    
    
    var editHostView :TBEditHostView?
    var editPortView :TBAddPortView?
    var historyListView: TBHistoryListView?
    var nextLine:NSString = "\n"
    
    var dataArray = []
    
    var hostListDic = Dictionary<String, TBUdpClient>()
    
//    var sendObject:TBUdpClient!

    
    var hostIP: String? = ""
    var hostPort: UInt16! = 0
    
    var cellIndex: Int = 10000
    var localHostPort = "9999"
//    var localPort:UILabel!
    
    var repeatSend:NSTimer?
    var dataLibrary = DataLibrary.shareDataLibrary()
    
    var showTextDic = Dictionary<String, Dictionary<String, String>>()
    
    //MARK: override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.edgesForExtendedLayout = UIRectEdge.None
        // Do any additional setup after loading the view.
        
        hostListTableView.tableFooterView = UIView(frame:CGRectZero)
        
        dataLibrary.creatProductTable("UDP")
        
        dataArray = dataLibrary.getallDataByTable("UDP")
        
//        for dic in dataArray
//        {
//            var sendObject = TBUdpClient()
//            sendObject.delegate = self;
//            
//            let pid = dic["p_id"] as! String
//            
//            hostListDic[pid] = sendObject
//        }
//        
//        
//        var localHost = TBUdpClient(port: 8080)
//        localHost.delegate = self
//        
//        hostListDic["local"] = localHost
        
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
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: nil)
        
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
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        
        if sendButton.selected
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
            
            if cellIndex != 10000
            {
                var msgData:NSData
                
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
                    
                    if dataArray.count > cellIndex
                    {
                        var dataDict: AnyObject = dataArray[cellIndex]
                        let pid = dataDict["p_id"] as! String
                        var sendObject = hostListDic[pid]!
                        
                        let error = sendObject.sendData(msgData, ip:hostIP, port:hostPort!)
                        
                        self.checkReceiveData(error, pid: pid, sendData: msgData)
                    }
                    
                    
                }
                
                
            }
            else
            {
                SVProgressHUD.showErrorWithStatus("请选择主机", maskType: SVProgressHUDMaskType.Black)
                return
            }
        }
        
    }
    
    
    @IBAction func clearAction(sender: AnyObject) {
        
        if cellIndex == 10000
        {
            self.clearText("local")
        }
        if dataArray.count > cellIndex
        {
            let dictionary: AnyObject = dataArray[cellIndex]
            
            let pid = dictionary["p_id"] as! String
            
            self.clearText(pid)
            
        }
        
        receiveLabel.text = "接收：0"
        sendLabel.text = "发送：0"
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
            inputTextField.text =  HexStringTransform.hexStringFromString(inputTextField.text)
            
        }
        else
        {
            inputTextField.text = HexStringTransform.stringFromHexString2(inputTextField.text)
        }
        
        
    }
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        
        
        
    }
    
   
    

    
   
    @IBAction func cycleAction(sender: AnyObject)
    {
        cycleButton.selected = !cycleButton.selected
        if repeatSend != nil
        {
            self.timerInvalidate()
        }
    }
  
    @IBAction func showHistoryListAction(sender: AnyObject)
    {
        historyListView = TBHistoryListView.showHistoryListViewBy(type: "UDP")
        historyListView?.delegate = self
        historyListView?.show(inView: self.view.window!)
    }
    
    //MARK:function
    
    func addConnect(receiveData:Dictionary<String, String>) {
        
        
        hostIP = receiveData["ip"]
        let port = receiveData["port"]
        hostPort = UInt16((port!.toInt())!)
        
        let error =  dataLibrary.checkDataListByTable("UDP", withIp: receiveData["ip"], andPort: receiveData["port"])
        
        if !error
        {
            
            dataLibrary.insertData(NSDictionary(objectsAndKeys: receiveData["ip"]!,"ip",receiveData["port"]!,"port",receiveData["repeat"]!,"repeat",receiveData["autoWrap"]!,"autoWrap",receiveData["autoReply"]!,"autoReply") as [NSObject : AnyObject] , intoTable: "UDP")
            dataArray = dataLibrary.getallDataByTable("UDP")
            
            var sendDict: AnyObject = dataArray.lastObject!
            
            cellIndex = dataArray.count - 1
            
            var pid = sendDict["p_id"] as! String
            
            var sendObject = TBUdpClient()
            sendObject.delegate = self;
            
            hostListDic[pid] = sendObject
            
            var dic :Dictionary = Dictionary<String, String>()
            dic["text"] = ""
            dic["receive"] = "0"
            dic["send"] = "0"
            showTextDic[pid] = dic
            

            hostListTableView.reloadData()
            
            var indexPath = NSIndexPath(forRow:(dataArray.count - 1),inSection:1)
            
            self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
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

        
        var dataDict: AnyObject = dataArray[cellIndex]
        let pid = dataDict["p_id"] as! String
        var sendObject = hostListDic[pid]
        let error = sendObject!.sendData(msgData, ip:hostIP, port:hostPort!)
        
        self.checkReceiveData(error, pid: pid, sendData: msgData)
        
    }
    func longPressAction(sender: AnyObject) {
        
        let cell = sender.view as! hostListTableViewCell
        
        println(cell.cellid)
        cellIndex = cell.cellid.toInt()!
        if cell.cellid != "10000"
        {
            var indexPath = NSIndexPath(forRow:cellIndex,inSection:1)
            self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            hostIP = cell.ipLabel.text
            hostPort = UInt16((cell.portLabel.text?.toInt())!)
            
            if (self.editHostView == nil)
            {
                self.editHostView = TBEditHostView.editHost(title: "编辑链接", hostInfo: dataArray[cellIndex] as! Dictionary<String, String>, isUdp: true)
                self.editHostView?.show(inView: self.view.window!)
                
                self.editHostView!.delegate = self
            }
        }
        else
        {
            if (self.editPortView == nil)
            {
                var indexPath = NSIndexPath(forRow:0,inSection:0)
                self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                
                self.editPortView = TBAddPortView.addPortView(host: "udp")
                editPortView!.show(inView: self.view.window!)
                
                editPortView!.delegate = self
            }
            
        }
        
        
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
    
    func checkClientList(list:Int)
    {
        if list == 0
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "right_byte_h"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "right_text_h"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "right_byte_h"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "right_text_h"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "right_cycle_h"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "right_cycle-off_h"), forState: UIControlState.Normal)
            }
            
            self.showTypeButton.userInteractionEnabled = false
            self.sendTypeButton.userInteractionEnabled = false
            self.cycleButton.userInteractionEnabled = false
            self.sendButton.userInteractionEnabled = false
            self.showHistoryButton.userInteractionEnabled = false
            
        }
        else
        {
            if self.showTypeButton.selected
            {
                self.showTypeButton.setImage(UIImage(named: "right_byte"), forState: UIControlState.Selected)
            }
            else
            {
                self.showTypeButton.setImage(UIImage(named: "right_text"), forState: UIControlState.Normal)
            }
            
            if self.sendTypeButton.selected
            {
                self.sendTypeButton.setImage(UIImage(named: "right_byte"), forState: UIControlState.Selected)
            }
            else
            {
                self.sendTypeButton.setImage(UIImage(named: "right_text"), forState: UIControlState.Normal)
            }
            
            if self.cycleButton.selected
            {
                
                self.cycleButton.setImage(UIImage(named: "right_cycle"), forState: UIControlState.Selected)
            }
            else
            {
                
                self.cycleButton.setImage(UIImage(named: "right_cycle-off"), forState: UIControlState.Normal)
            }
            
            self.showTypeButton.userInteractionEnabled = true
            self.sendTypeButton.userInteractionEnabled = true

            self.cycleButton.userInteractionEnabled = true
            self.sendButton.userInteractionEnabled = true
            self.showHistoryButton.userInteractionEnabled = true
        }
        
    }
    //MARK: TableView Delegate
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("hostListCell", forIndexPath: indexPath) as! hostListTableViewCell
        
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
            cell.updateHostListWith("本地端口", port:localHostPort)
            
            cell.cellid = "10000"
            
            return cell
        }
        else
        {
            let dictionary: AnyObject = dataArray[indexPath.row]
            
            cell.updateHostListWith((dictionary["ip"] as! String), port: (dictionary["port"] as! String))
            
            cell.cellid = String(indexPath.row)
            
            println("celllllid " + cell.cellid)
            
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! hostListTableViewCell
        
        UIView.animateWithDuration(0.001, animations: { () -> Void in
            
            cell.contentView.backgroundColor = rightBgColor
            
            }) { (flag) -> Void in
                cell.contentView.backgroundColor = UIColor.whiteColor()
                
        }
        
        if indexPath.section == 0
        {
            
            if repeatSend != nil
            {
                self.timerInvalidate()
            }
        
            cellIndex = 10000
            
            var dic = showTextDic["local"]!
            
            showTextView.text = dic["text"]
            
            receiveLabel.text = "接收：" + dic["receive"]!
            sendLabel.text = "发送：" + dic["send"]!
            
            self.checkClientList(0)
            
        }
        else
        {
            
            println("didselect " + cell.cellid)
            
            if  cellIndex == 10000 || cellIndex != indexPath.row
            {
                
                if repeatSend != nil
                {
                    self.timerInvalidate()

                }
                var dictionary: AnyObject = dataArray[indexPath.row]
                
                var pid = dictionary["p_id"] as! String
                
                var dic = showTextDic[pid]!
                
                showTextView.text = dic["text"]
            
                
                receiveLabel.text = "接收：" + dic["receive"]!
                sendLabel.text = "发送：" + dic["send"]!
                
                cellIndex = indexPath.row
                
                hostIP = cell.ipLabel.text
                hostPort = UInt16((cell.portLabel.text?.toInt())!)
                
                println(dataArray[indexPath.row])
                
            }
            self.checkClientList(1)
        }
        
        
    }
   
    
    //MARK: TBUdpDelegate
    func onUdpClient(udpClient: TBUdpClient!, didNotReceiveDataWithTag tag: Int, dueToError error: NSError!) {
        
    }
    
    func onUdpClient(udpClient: TBUdpClient!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        
    }
    
    
    func onUdpClient(udpClient: TBUdpClient!, didReceiveData string: String!, withLength length: Int32, fromHost host: String!, port: UInt16) -> Bool  {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if string != nil
            {
                
                if self.hostListDic["local"] == udpClient
                {
                    
                    if self.cellIndex == 10000
                    {
                        if(self.showTypeButton.selected)
                        {

                            let dataString = HexStringTransform.hexStringFromString(string)
                            self.saveText("local", showText:dataString,autoWrap:"yes")
                            
                        }
                        else
                        {
                            self.saveText("local", showText:string,autoWrap:"yes")
                            
                        }
                        
                        
                        if self.showTextDic["local"] != nil
                        {
                            var dic = self.showTextDic["local"]!
                            
                            let num = length + dic["receive"]!.toInt()!
                            
                            
                            dic["receive"] = String(num)
                            
                            self.showTextDic["local"] = dic
                            
                            self.receiveLabel.text = "接收：" + String(num)
                        }
                    }
                    else
                    {
                        if(self.showTypeButton.selected)
                        {
//                            let dataString = self.hex2x(string)
                            let dataString = HexStringTransform.hexStringFromString(string)
                            self.saveTextInBackground("local", showText:dataString,autoWrap:"yes")
                            
                        }
                        else
                        {
                            self.saveTextInBackground("local", showText:string,autoWrap:"yes")
                            
                        }
                        
                        if self.showTextDic["local"] != nil
                        {
                            var dic = self.showTextDic["local"]!
                            
                            let num = length + dic["receive"]!.toInt()!
                            
                            dic["receive"] = String(num)
                            self.showTextDic["local"] = dic
                        }
                    }
                    
                    
                }
                else if self.dataArray.count > self.cellIndex
                {
                    var dictionary: AnyObject = self.dataArray[self.cellIndex]
                    
                    let pid = dictionary["p_id"] as! String
                    
                    let wrap = dictionary["autoWrap"] as! String
                    let reply = dictionary["autoReply"] as! String
                    
                    if self.hostListDic[pid] == udpClient
                    {
                        if(self.showTypeButton.selected)
                        {
//                            let dataString = self.hex2x(string)
                            let dataString = HexStringTransform.hexStringFromString(string)
                            self.saveText(pid, showText:dataString,autoWrap:wrap)
                            
                        }
                        else
                        {
                            self.saveText(pid, showText:string,autoWrap:wrap)
                            
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
                            let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                            let msgData = string.dataUsingEncoding(enc, allowLossyConversion: true)!
                            let error = udpClient.sendData(msgData, ip:self.hostIP, port:self.hostPort!)
                            
                            self.checkReceiveData(error, pid: pid, sendData: msgData)
                        }

                        
                    }
                    else
                    {
                        for dic in self.dataArray
                        {
                            let sub_pid = dic["p_id"] as! String
                            let wrap = dictionary["autoWrap"] as! String
                            var client = self.hostListDic[sub_pid]
                            
                            if client == udpClient
                            {
                                if(self.showTypeButton.selected)
                                {
//                                    let dataString = self.hex2x(string)
                                    let dataString = HexStringTransform.hexStringFromString(string)
                                    self.saveTextInBackground(sub_pid, showText:dataString,autoWrap:wrap)
                                    
                                }
                                else
                                {
                                    self.saveTextInBackground(sub_pid, showText:string,autoWrap:wrap)
                                    
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
        return true
    }
    
    func onUdpClient(udpClient: TBUdpClient!, didSendDataWithTag tag: Int) {
        
    }
    
    func onUdpClientDidClose(udpClient: TBUdpClient!) {
        
        
        
    }
    
    func onUdpClient(udpClient: TBUdpClient!, createObjectError error: Int64) {
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if error != 0
            {
                self.showTextView.text = self.showTextView.text + self.checkErrorCode(error) + (self.nextLine as String)

                
            }
        })
    }
    
    func onUdpClientDidReceiveError(error: Int64) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if error != 0
            {
                self.showTextView.text = self.showTextView.text + self.checkErrorCode(error) + (self.nextLine as String)
                
                if self.repeatSend != nil
                {
                    self.timerInvalidate()
                }
                
            }
        })
    }
    
    //MARK: TBAddPortDelegate
    
    func getUdpPort(port: String) {
        
        
        println("Local Port is " + port)
        
//        self.localPort.text = port
        
        self.localHostPort = port
        if hostListDic["local"] != nil
        {
            hostListDic.removeValueForKey("local")
            
            var localHost = TBUdpClient(port: UInt16(port.toInt()!))
            localHost.delegate = self
            
            hostListDic["local"] = localHost
            
            var dic :Dictionary = Dictionary<String, String>()
            dic["text"] = ""
            dic["receive"] = "0"
            dic["send"] = "0"
            showTextDic["local"] = dic
            
            showTextView.text = ""
            receiveLabel.text = "接收：0"
            sendLabel.text = "发送：0"
        
        }
        var indexPath = NSIndexPath(forRow:0,inSection:0)
        
        self.hostListTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        
        self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    //MARK: TBEditHostDelegate
    func editUdpHost(hostInfo: Dictionary<String, String>)
    {
        hostIP = hostInfo["ip"]
        let port = hostInfo["port"]
        hostPort = UInt16((port!.toInt())!)
        
        dataLibrary.replaceData(NSDictionary(objectsAndKeys: hostInfo["ip"]!,"ip",hostInfo["port"]!,"port",hostInfo["repeat"]!,"repeat",hostInfo["autoWrap"]!,"autoWrap",hostInfo["autoReply"]!,"autoReply",hostInfo["p_id"]!,"p_id") as [NSObject : AnyObject] , intoTable: "UDP")
        dataArray = dataLibrary.getallDataByTable("UDP")
        
        var sendDict: AnyObject = dataArray[cellIndex]
        
        var pid = sendDict["p_id"] as! String
        
        var sendObject = TBUdpClient()
        sendObject.delegate = self;
        
        if hostInfo["ip"] == "255.255.255.255"
        {
            sendObject.enableBroadcast()
        }
        
        hostListDic[pid] = sendObject
        
        var dic :Dictionary = Dictionary<String, String>()
        dic["text"] = ""
        dic["receive"] = "0"
        dic["send"] = "0"
        showTextDic[pid] = dic
        
        hostListTableView.reloadData()
        var indexPath = NSIndexPath(forRow:cellIndex,inSection:1)
        self.hostListTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)

    }
    
    func cancelAction()
    {
        if self.editPortView != nil
        {
            self.editPortView = nil
        }
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
            
            dataLibrary.deleteDataListByTable("UDP", withIp: dictionary["ip"] as! String, andPort: dictionary["port"] as! String)
            
            dataArray = dataLibrary.getallDataByTable("UDP")
            
            hostListTableView.reloadData()
            
             SVProgressHUD.showSuccessWithStatus("删除成功", maskType: SVProgressHUDMaskType.Black)
            
            self.checkClientList(dataArray.count)
        }
        
    }
    
    // MARK: TBHistoryDelegate
    
    func selectDataToUDP(dataString: String) {
        self.inputTextField.text = dataString
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

        var localObject = hostListDic["local"]
        localObject?.close()
        localObject = nil
        
        
        for dic in dataArray
        {
            let pid = dic["p_id"] as! String
            
            var sendObject = hostListDic[pid]
            sendObject?.close()
            sendObject = nil
        }
        
        
        
    }
    func actionNotification(notification: NSNotification)
    {
        
        for dic in dataArray
        {
            let pid = dic["p_id"] as! String
            var sendObject = TBUdpClient()
            sendObject.delegate = self;
            
            if dic["ip"] as! String == "255.255.255.255"
            {
               sendObject.enableBroadcast()
            }
            
            hostListDic[pid] = sendObject
            
            if showTextDic[pid] == nil
            {
                var dic :Dictionary = Dictionary<String, String>()
                dic["text"] = ""
                dic["receive"] = "0"
                dic["send"] = "0"
                showTextDic[pid] = dic
            }
        }
        
        
//        if localHostPort != nil
//        {
            var localHost = TBUdpClient(port: UInt16(localHostPort.toInt()!))
            localHost.delegate = self
            
            hostListDic["local"] = localHost
            
            if showTextDic["local"] == nil
            {
                var dic :Dictionary = Dictionary<String, String>()
                dic["text"] = ""
                dic["receive"] = "0"
                dic["send"] = "0"
                showTextDic["local"] = dic
            }
//        }
        
    }
   
}
