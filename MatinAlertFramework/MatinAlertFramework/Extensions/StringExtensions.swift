//
//  StringExtensions.swift
//  MatinAlertFramework
//
//  Created by Matin Kajabadi on 12/31/20.
//

import Foundation


extension String {
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: NSCharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
}
