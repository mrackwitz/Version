//
//  Helper.swift
//  Version
//
//  Created by Marius Rackwitz on 26/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation

// based on: http://stackoverflow.com/a/30593673/4194189
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
