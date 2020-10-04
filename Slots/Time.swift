//
//  Time.swift
//  Slots
//
//  Created by Diogo Silva on 10/03/20.
//

import Foundation
import SwiftUI

class Time: CustomStringConvertible, Codable, ObservableObject {
    @Published var hour: Int
    @Published var minute: Int
    var second: Int

    init(hour: Int, minute: Int, second: Int = 0) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    init(from fromDate: Date, ignoringSeconds: Bool = false) {
        hour = fromDate.component(.hour)
        minute = fromDate.component(.minute)
        if ignoringSeconds { second = 0 }
        else { second = fromDate.component(.second) }
    }

    convenience init() {
        self.init(from: Date(), ignoringSeconds: true)
    }

    func pickerView() -> some View {
        let timeSelection: Binding<Date> = Binding(get: {
            Date(from: self)
        }, set: { newValue in
            self.hour = newValue.component(.hour)
            self.minute = newValue.component(.minute)
        })

        return DatePicker("Date", selection: timeSelection, displayedComponents: .hourAndMinute)
    }

    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date(from: self))
    }

    func description(relativeTo relativeDate: Date) -> String {
        let currentDate = Date(from: self)
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .short
        return relativeFormatter.localizedString(for: currentDate, relativeTo: relativeDate)
    }

    func conditionalDescription(relativeTo relativeDate: Date) -> String {
        let hourDiff = abs(relativeDate.component(.hour) - self.hour)
        return hourDiff > 1 ? description : description(relativeTo: relativeDate)
    }

    // MARK: Encoding & Decoding
    // We want to encode the hour minute second joined together in a string
    // to avoid using extra space
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let encodedString = try container.decode(String.self)

        let df = DateFormatter()
        df.dateFormat = "HHmmss"
        guard let decodedDate = df.date(from: encodedString) else {
            throw EncodingError.invalidValue("date", EncodingError.Context.init(codingPath: [], debugDescription: "Invalid date value"))
        }

        hour = decodedDate.component(.hour)
        minute = decodedDate.component(.minute)
        second = decodedDate.component(.second)
    }

    func encode(to encoder: Encoder) throws {
        let df = DateFormatter()
        df.dateFormat = "HHmmss"
        let encodedString = df.string(from: Date(from: self))

        var container = encoder.singleValueContainer()
        try container.encode(encodedString)
    }
}
