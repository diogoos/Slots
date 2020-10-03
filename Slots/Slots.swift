//
//  Slots.swift
//  Slots
//
//  Created by Diogo Silva on 09/19/20.
//

import Foundation

class Slot: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String = ""
    @Published var date: Date = Date()

    struct Static: Codable {
        private(set) var name: String
        private(set) var date: Date

        var dynamic: Slot {
            Slot(name: name, date: date)
        }

        init(name: String, date: Date) {
            self.name = name
            self.date = date.overriding(component: \.day, to: 1)
                            .overriding(component: \.month, to: 1)
                            .overriding(component: \.year, to: 2001)
        }
    }

    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }

    init() {
        self.name = ""
        self.date = Date().overriding(component: \.day, to: 1)
                          .overriding(component: \.month, to: 1)
                          .overriding(component: \.year, to: 2001)
    }

    var staticSlot: Slot.Static { Slot.Static(name: name, date: date) }
}

struct SlotTable {
    // [[slot, slot, slot], [slot, slot], ....
    //       monday           tuesday      etc
    var slotsTable: [[Slot]]

    subscript(x: Int) -> [Slot] {
        get {
            return slotsTable[x]
        }
        set {
            slotsTable[x] = newValue
        }
    }

    struct Static: Codable {
        private(set) var staticSlotTable: [[Slot.Static]]

        var dynamic: SlotTable {
            let slots = staticSlotTable.map { row in row.map { $0.dynamic } }
            return SlotTable(slotsTable: slots)
        }
    }

    var staticTable: SlotTable.Static {
        let staticSlots = slotsTable.map { slotRow in slotRow.map { $0.staticSlot } }
        return SlotTable.Static(staticSlotTable: staticSlots)
    }

    init(slotsTable: [[Slot]]) {
        self.slotsTable = slotsTable
    }

    init(defaults: UserDefaults) {
        let emptyTable: [[Slot]] = Calendar.current.weekdaySymbols.map({ _ in [] })

        guard let slotData = defaults.data(forKey: "SlotTable") else {
            self.slotsTable = emptyTable
            return
        }
        do {
            let staticSlotTable = try JSONDecoder().decode(SlotTable.Static.self, from: slotData)
            self = staticSlotTable.dynamic
        } catch {
            self.slotsTable = emptyTable
        }
    }

    func save(to defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(staticTable) else { return }
        defaults.set(data, forKey: "SlotTable")
    }
}

extension Array where Element == Slot {
    mutating func sortByDate() {
        self.sort(by: { $0.date < $1.date })
    }

    func sortedByDate() -> Self {
        return self.sorted(by: { $0.date < $1.date })
    }
}
