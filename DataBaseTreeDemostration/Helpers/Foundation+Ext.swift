//
//  Foundation+Ext.swift
//  DataBaseTreeDemostration
//
//  Created by  Macbook on 25.09.2020.
//  Copyright © 2020 Golovelv Maxim. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
