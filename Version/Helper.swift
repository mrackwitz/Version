//
//  Helper.swift
//  Version
//
//  Created by Marius Rackwitz on 26/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation


extension Array {
    func `try`(index: Int) -> Element? {
        if index >= 0 && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
