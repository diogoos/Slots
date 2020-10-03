//
//  Date+Time.swift
//  Slots
//
//  Created by Diogo Silva on 10/02/20.
//

import Foundation

extension Date {
    func component(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        calendar.component(component, from: self)
    }

    func overriding(component: WritableKeyPath<DateComponents, Int?>,
                    to override: Int,
                    calendar: Calendar = Calendar.current) -> Date {
        var selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        selfComponents[keyPath: component] = override
        return Calendar.current.date(from: selfComponents)!
    }

    mutating func override(component: WritableKeyPath<DateComponents, Int?>,
                  to override: Int,
                  calendar: Calendar = Calendar.current) {
        self = self.overriding(component: component, to: override, calendar: calendar)
    }

    func overriding(components: Set<WritableKeyPath<DateComponents, Int?>>,
                    toMatch override: Date,
                    calendar: Calendar = Calendar.current) -> Date {
        var selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        let overrideComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: override)
        components.forEach { selfComponents[keyPath: $0] = overrideComponents[keyPath: $0] }
        return calendar.date(from: selfComponents)!
    }

    mutating func overriding(components: Set<WritableKeyPath<DateComponents, Int?>>,
                            toMatch override: Date,
                            calendar: Calendar = Calendar.current) {
        self = self.overriding(components: components, toMatch: override, calendar: calendar)
    }

    init(from fromTime: Time) {
        self.init()
        self.override(component: \.hour, to: fromTime.hour)
        self.override(component: \.minute, to: fromTime.minute)
        self.override(component: \.second, to: fromTime.second)
    }
}
