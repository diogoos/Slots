//
//  ContentView.swift
//  Slots
//
//  Created by Diogo Silva on 09/17/20.
//

import SwiftUI

struct ContentView: View {
    private let currentDayIndex = Calendar.current.dateComponents([.weekday], from: Date()).weekday! - 1
    @ObservedObject var slotTable: SlotTableWrapper

    var body: some View {
        VStack {
            // Current week day
            Text(Calendar.current.weekdaySymbols[currentDayIndex])
                .font(.headline)
                .padding(.bottom)

            // Show schedule for the day
            ForEach(slotTable.table[currentDayIndex]) { slot in
                HStack {
                    Text(slot.name)
                        .padding(.leading)

                    Spacer()

                    Text(slot.time.conditionalDescription(relativeTo: Date()))
                        .padding(.trailing)
                }
                .padding(.vertical, 2)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(3.0)
                .focusable()
                .padding(.vertical, 5)
            }
            .padding(.horizontal)

            // Edit slots button
            Button(action: { sendMessage(.SlotBuilderActivate)}, label: { Text("Edit slots") })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(slotTable: SlotTableWrapper(table: SlotTable(from: UserDefaults.standard)))
    }
}
