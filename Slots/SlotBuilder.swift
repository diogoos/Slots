//
//  SlotBuilder.swift
//  Slots
//
//  Created by Diogo Silva on 09/18/20.
//

import SwiftUI

struct RoundedBorder: View {
    struct colors {
        static var lightPrimary: Color = Color.primary.opacity(0.8)
    }

    var dash = [CGFloat]()
    var width: Int = 2
    var cornerRadius: Int = 8
    var color: Color = RoundedBorder.colors.lightPrimary

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: dash))
            .foregroundColor(RoundedBorder.colors.lightPrimary)
    }
}

struct SlotBuilder: View {
    @State private var slots: SlotTable

    @State private var currentIndex: Int = 0
    private var currentSlot: [Slot] { slots[currentIndex] }

    private var canRemove: Bool { self.currentIndex > 0 }
    private var canAdd: Bool { self.currentIndex < Calendar.current.weekdaySymbols.count-1 }

    init() {
        _slots = .init(initialValue: SlotTable(defaults: UserDefaults.standard))
    }

    func sort() {
        withAnimation {
            slots[currentIndex].sortByDate()
        }
    }

    private func closePopover() {
        sendMessage(AppDelegate.Message.SlotBuilderCancel)
        DispatchQueue.main.async {
            slots = SlotTable(defaults: UserDefaults.standard)
        }
    }

    private func saveSlots() {
        slots.save(to: UserDefaults.standard)
        sendMessage(AppDelegate.Message.SlotBuilderSave)
    }

    private var addButton: some View {
        Button(action: {
            withAnimation {
                self.slots[currentIndex].append(Slot())
            }
        }) {
            VStack(spacing: 0) {
                Image("add")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(RoundedBorder.colors.lightPrimary)
                    .frame(width: 30)
                Text("Add a slot")
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .overlay(RoundedBorder(dash: [15]))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top)
    }

    private var daySwitcher: some View {
        HStack {
            Button(action: {
                if canRemove {
                    self.currentIndex += -1
                }
            }, label: { Text("<") })
            .disabled(!canRemove)

            Text("\(Calendar.current.weekdaySymbols[currentIndex])")

            Button(action: {
                if canAdd {
                    self.currentIndex += 1
                }
            }, label: { Text(">") })
            .disabled(!canAdd)
        }
        .frame(maxWidth: .infinity, minHeight: 30)
        .background(Color(NSColor.textBackgroundColor))
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Sequence builder")
                        .font(.headline)

                    Spacer()

                    Button(action: self.closePopover, label: { Text("Cancel") })
                    Button(action: self.saveSlots, label: { Text("Save") })
                }

                ForEach(currentSlot) { slot in
                    SlotView(slot: slot, parent: self)
                    .tag(slot.id)
                }

                self.addButton
            }
            .padding()

            Spacer()

            self.daySwitcher
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct SlotView: View {
    @ObservedObject var slot: Slot
    var parent: SlotBuilder

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Name")

                TextField("Slot name", text: $slot.name)
                    .textFieldStyle(SquareBorderTextFieldStyle())

                DatePicker("Date", selection: $slot.date, displayedComponents: .hourAndMinute)
                    .onHover(perform: { a in
                        if !a { parent.sort() }
                    })
                    .datePickerStyle(FieldDatePickerStyle())
            }
        }
        .frame(minHeight: 60)
        .padding(.horizontal)
        .overlay(RoundedBorder())
    }
}

struct SlotBuilder_Previews: PreviewProvider {
    static var previews: some View {
        SlotBuilder()
            .frame(width: 400, height: 500)
    }
}

