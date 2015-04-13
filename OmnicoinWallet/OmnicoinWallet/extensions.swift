//
//  extensions.swift
//  OmnicoinWallet
//
//  Created by Alex Catchpole on 15/03/2015.
//  Copyright (c) 2015 Alex Catchpole. All rights reserved.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
