//
//  Date.swift
//  Slots
//
//  Created by Diogo Silva on 10/02/20.
//

import Foundation

extension Date {
    func component(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    func overriding(component: WritableKeyPath<DateComponents, Int?>,
                    to override: Int,
                    calendar: Calendar = Calendar.current) -> Date {
        var selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        selfComponents[keyPath: component] = override
        return Calendar.current.date(from: selfComponents) ?? self
    }

    func overriding(components: Set<WritableKeyPath<DateComponents, Int?>>,
                    toMatch override: Date,
                    calendar: Calendar = Calendar.current) -> Date {
        var selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        let overrideComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: override)
        components.forEach { selfComponents[keyPath: $0] = overrideComponents[keyPath: $0] }
        return calendar.date(from: selfComponents)!
    }

    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var conditionalRelativeTimeString: String {
        let hourDiff = self.component(.hour) - Date().component(.hour)

        if abs(hourDiff) > 1 {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return df.string(from: self)
        }

        return relativeTimeString
    }
}
