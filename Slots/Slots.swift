//
//  Slots.swift
//  Slots
//
//  Created by Diogo Silva on 09/19/20.
//

import Foundation

class Slot: Identifiable, ObservableObject, Codable {
    // MARK: Initializers
    let id = UUID()
    @Published var name: String
    @Published var time: Time

    init(name: String = "", time: Time = Time()) {
        self.name = name
        self.time = time
    }

    // MARK: Encoding & Decoding
    enum CodingKeys: CodingKey {
        case name
        case time
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        time = try container.decode(Time.self, forKey: .time)
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(time, forKey: .time)
    }
}


class SlotTableWrapper: ObservableObject {
    @Published var table: SlotTable

    init(table: SlotTable) {
        self.table = table
    }
}

typealias SlotTable = [[Slot]]
extension SlotTable {
    static let empty: SlotTable = Calendar.current.weekdaySymbols.map({ _ in [] })

    init(from defaults: UserDefaults) {
        if let slotData = defaults.data(forKey: "SlotTable"),
           let decoded = try? JSONDecoder().decode(SlotTable.self, from: slotData) {
            self = decoded
            return
        }
        self = SlotTable.empty
    }

    func save(to defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: "SlotTable")
    }
}
