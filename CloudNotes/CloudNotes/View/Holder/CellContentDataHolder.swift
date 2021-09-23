//
//  d.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/06.
//

import Foundation

final class CellContentDataHolder {
    let titleLabelText: String
    let dateLabelText: String
    let bodyLabelText: String
    
    init(title: String, date: Date, body: String) {
        let modifiedDate =  DateFormatter().updateLastModifiedDate(date)
        self.dateLabelText = "\(modifiedDate)"
        self.titleLabelText = title
        self.bodyLabelText = body
    }
}
