//
//  Transaction.swift
//  OmnicoinWallet
//
//  Created by Alex Catchpole on 22/03/2015.
//  Copyright (c) 2015 Alex Catchpole. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    var balance: Int!
    var confirmations: Int!
    var date: NSDate!
    var transHash: String!
    var value: Double!
    
    init(balancee: Int, confirmationss: Int, datee: NSDate, transHashh: String, valuee: Double) {
        balance = balancee
        confirmations = confirmationss
        date = datee
        transHash = transHashh
        value = valuee
        
    }
   
}
