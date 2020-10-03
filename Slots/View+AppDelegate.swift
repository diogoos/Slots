//
//  View+AppDelegate.swift
//  Slots
//
//  Created by Diogo Silva on 10/02/20.
//

import Foundation
import SwiftUI

extension View {
    func sendMessage(_ msg: AppDelegate.Message) {
        (NSApp.delegate as? AppDelegate)?.handle(msg)
    }
}
