//
//  MainViewController.swift
//  OmnicoinWallet
//
//  Created by Alex Catchpole on 14/03/2015.
//  Copyright (c) 2015 Alex Catchpole. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableVieww: UITableView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    var sessionID: String!
    var username: String!
    var transactions: NSMutableArray!
    
    //three main arrays
    var transactionsToday: NSMutableArray!
    var transactionsThisMonth: NSMutableArray!
    var transactionAllTime: NSMutableArray!
    var transactionThisWeek: NSMutableArray!
    var mainFinalTrans: NSMutableArray!
    
    var refreshControl: UIRefreshControl!
    
    //set to true if eveything has been sorted
    var transactionsSorted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor(red: 61 / 255, green: 46 / 255, blue: 83 / 255, alpha: 1)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "dataCall", forControlEvents: UIControlEvents.ValueChanged)
        
        var attributDic: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), ]
        var attTitle: NSAttributedString = NSAttributedString(string: "Pull To Refresh", attributes: attributDic as [NSObject : AnyObject])
        self.refreshControl.attributedTitle = attTitle

        tableVieww.addSubview(refreshControl)
        
        
        dataCall()
        transactions = []
        transactionsToday = []
        transactionsThisMonth = []
        transactionThisWeek = []
        mainFinalTrans = []
        
        
        
        tableVieww.registerNib(UINib(nibName: "RecievedCell", bundle: nil), forCellReuseIdentifier: "cell1")
        tableVieww.registerNib(UINib(nibName: "transactionSentCell", bundle: nil), forCellReuseIdentifier: "cell2")
        
        //navbar customer
        self.navigationController?.navigationBar.titleTextAttributes =
        [
            NSFontAttributeName: UIFont(name: "Overpass-Reg", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func dataCall() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var url: NSURL = NSURL(string: "https://omnicha.in/api?method=wallet_getinfo&username=\(username)&password=\(sessionID)")!
        Alamofire.request(.GET, url)
            .responseJSON { (_, _, JSON, _) in
                println(JSON)
                println("got result")
                var dictionary = JSON as! NSDictionary
                var response = dictionary["response"] as! NSDictionary
                var balance = response["balance"] as! Double
                let balanceInt = Int(balance)
                
                var omcPrice = response["omc_usd_price"] as! Double
                var price = omcPrice * balance
                var roundedPrice = price.format("0.2")
                if let transactions = response["transactions"] as? NSMutableArray {
                    self.transactions = response["transactions"] as! NSMutableArray!
                    self.sortTransactions()
                
                }else {
                    println("no transactions")
                }
                
                self.balanceLabel.text = "\(String(balanceInt)) OMC"
                self.priceLabel.text = "$\(String(roundedPrice))"
                self.refreshControl.endRefreshing()
                
        }
        
    }
    
    func sortTransactions() {
        transactionsToday = []
        transactionThisWeek = []
        transactionsThisMonth = []
        mainFinalTrans = []
        for trans in transactions {
            var transs = trans as! NSDictionary
            //checks for bug in api
            if let vout = transs["vout"] as? Int {
                println("undefined trans")
            }else {
                var valuee: Double = transs["value"] as! Double
                var txHash: String = transs["tx_hash"] as! String
                var date: String = transs["date"] as! String
                var confirmations: Int = transs["confirmations"] as! Int
                var balance: Int = transs["balance"] as! Int
                
                //convert value
                var finalValue = valuee / 100000000
                
                //setup calander to compare dates
                let calan = NSCalendar.currentCalendar()
                let now = NSDate()
                
                
                //convert date
                var dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
                dateFormatter.dateFormat = "yy-MM-dd HH:mm:ss"
                
                var datee = dateFormatter.dateFromString(date)!
                var transaction = Transaction(balancee: balance, confirmationss: confirmations, datee: datee, transHashh: txHash, valuee: finalValue)
                
                if calan.compareDate(datee, toDate: now, toUnitGranularity: .CalendarUnitDay) == .OrderedSame {
                    
                    transactionsToday.addObject(transaction)
                    
                }
                //is within last seven days?
                var cs = calan.components(NSCalendarUnit.CalendarUnitDay, fromDate: datee, toDate: now, options: nil)
                if cs.day < 7 {
                    transactionThisWeek.addObject(transaction)
                    
                }
                if calan.compareDate(datee, toDate: now, toUnitGranularity: NSCalendarUnit.CalendarUnitMonth) == .OrderedSame {
                    
                    transactionsThisMonth.addObject(transaction)
                    
                }
                
            }
            
            
        }
        mainFinalTrans.addObject(transactionsToday)
        mainFinalTrans.addObject(transactionThisWeek)
        mainFinalTrans.addObject(transactionsThisMonth)
        
        transactionsSorted = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        tableVieww.reloadData()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var amountToReturn = 0
        if section == 0 {
            amountToReturn = transactionsToday.count
        }else if section == 1 {
            amountToReturn = transactionThisWeek.count
        }else if section == 2 {
            amountToReturn = transactionsThisMonth.count
        }
        println("AMOUNT OF CELLS IN SECITON \(section) is \(amountToReturn)")
        return amountToReturn
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var string = ""
        var view = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 18))
        view.backgroundColor = UIColor(red: 120 / 255, green: 90 / 255, blue: 162 / 255, alpha: 1)
        
        var label = UILabel(frame: CGRectMake(8, 2, tableView.bounds.size.width, 18))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Overpass-Reg", size: 17)
        if section == 0 {
            string = "Today's Transactions"
        }else if section == 1 {
            string = "Week's Transactions"
        }else if section == 2 {
            string = "Month's Transactions"
        }
        label.text = string
        view.addSubview(label)
        
        
        return view
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell1: RecievedCell!
        var cell2: transactionSentCell!
        if transactionsSorted == true {
            var currentArray = mainFinalTrans[indexPath.section]as! NSMutableArray
            var currentTransactionItem = currentArray[indexPath.row] as! Transaction
            println(indexPath.row)
            if currentTransactionItem.value > 0 {
                
                cell1 = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! RecievedCell
                
                var checkerInt = currentTransactionItem.value % 1
                if checkerInt == 0 {
                    
                    var value = Int(currentTransactionItem.value)
                    cell1.value.text = "+\(value) OMC"
                    
                    return cell1
                }else {
                    
                    cell1.value.text = "+\(currentTransactionItem.value) OMC"
                    return cell1
                    
                }
                
                
            }else {
                cell2 = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! transactionSentCell
                
                var checkerInt = currentTransactionItem.value % 1
                if checkerInt == 0 {
                    
                    var value = Int(currentTransactionItem.value)
                    cell2.valueLabel.text = "\(value) OMC"
                    
                    return cell2
                }else {
                    
                    cell2.valueLabel.text = "\(currentTransactionItem.value) OMC"
                    return cell2
                    
                }
                
            }

        }
        println("fatal error")
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            cell.alpha = 1
        })
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        dataCall()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
