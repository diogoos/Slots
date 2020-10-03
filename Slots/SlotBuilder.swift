//
//  SlotBuilder.swift
//  Slots
//
//  Created by Diogo Silva on 09/18/20.
//

import SwiftUI

extension RoundedRectangle {
    /// Custom RoundedRectangle-based border
    struct Border: View {
        struct colors {
            static let lightPrimary: Color = Color.primary.opacity(0.8)
        }

        var dash = [CGFloat]()
        var width: Int = 2
        var cornerRadius: Int = 8

        var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: dash))
                .foregroundColor(Self.colors.lightPrimary)
        }
    }
}


struct PageNavigationBar<Content: View>: View {
    @Binding var pageIndex: Int

    let minIndex: Int = 0
    let maxIndex: Int

    var label: (Int) -> (Content)

    private var previousPageExists: Bool { pageIndex > minIndex }
    private var nextPageExists: Bool { pageIndex < maxIndex }

    func previousPage() { if previousPageExists { pageIndex -= 1 } }
    func nextPage()     { if nextPageExists { pageIndex += 1 } }

    var body: some View {
        HStack {
            Button(action: previousPage, label: { Text("<") })
                .disabled(!previousPageExists)

            label(pageIndex)

            Button(action: nextPage, label: { Text(">") })
                .disabled(!nextPageExists)
        }
        .frame(maxWidth: .infinity, minHeight: 30)
        .background(Color(NSColor.textBackgroundColor))
    }
}

struct SlotBuilder: View {
    // Recieve the SlotTable from the AppDelegate
    @ObservedObject var slotTable: SlotTableWrapper

    // Manage the current slot
    @State private var currentIndex: Int = 0
    private var currentSlot: [Slot] { slotTable.table[currentIndex] }

    // Close the popover, discarding changes
    private func closePopover() {
        sendMessage(AppDelegate.Message.SlotBuilderCancel)
        DispatchQueue.main.async {
            slotTable.table = SlotTable(from: UserDefaults.standard)
        }
    }

    // Close the popover and save changes
    private func saveSlots() {
        slotTable.table.save(to: UserDefaults.standard)
        sendMessage(AppDelegate.Message.SlotBuilderSave)
    }


    // Create a new slot
    private func createSlot() {
        withAnimation { slotTable.table[currentIndex].append(Slot()) }
    }

    // Button to create a new slot
    private var addButton: some View {
        Button(action: createSlot) {
            VStack(spacing: 0) {
                Image("add")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(RoundedRectangle.Border.colors.lightPrimary)
                    .frame(width: 30)
                Text("Add a slot")
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .overlay(RoundedRectangle.Border(dash: [15]))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top)
    }

    // Content view heading
    private var heading: some View {
        HStack {
            Text("Sequence builder")
                .font(.headline)

            Spacer()

            Button(action: self.closePopover, label: { Text("Cancel") })
            Button(action: self.saveSlots, label: { Text("Save") })
        }
    }

    // Main view
    var body: some View {
        VStack {
            VStack {
                heading

                ForEach(currentSlot) { slot in
                    SlotView(slot: slot, parent: self)
                    .tag(slot.id)
                }

                addButton
            }
            .padding()

            Spacer()

            PageNavigationBar(pageIndex: $currentIndex,
                              maxIndex: Calendar.current.weekdaySymbols.count - 1,
                              label: { Text(Calendar.current.weekdaySymbols[$0]) })
        }
        .onAppear(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
    }

    // Sort table helper
    func sortTable() {
        slotTable.table[currentIndex].sort { (lhs: Slot, rhs: Slot) in
            return Date(from: lhs.time) < Date(from: rhs.time)
        }
    }

    // Remove slot with a specific id
    func removeSlot(id: UUID) {
        guard let slotIndex = currentSlot.firstIndex(where: { $0.id == id }) else { return }
        slotTable.table[currentIndex].remove(at: slotIndex)
    }
}

struct SlotView: View {
    @ObservedObject var slot: Slot
    var parent: SlotBuilder

    private func withTimeBugFix<Content: View>(content: () -> (Content)) -> some View {
        content().focusable(true, onFocusChange: { _ in
            slot.time = slot.time
            parent.sortTable()
        })
    }

    private var removeButton: some View {
        Button(action: {
            parent.removeSlot(id: slot.id)
        }, label: {
            Image("xmark.circle.fill")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .foregroundColor(Color.gray)
        })
        .buttonStyle(PlainButtonStyle())
        .focusable()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Name")

                TextField("Slot name", text: $slot.name)
                    .textFieldStyle(SquareBorderTextFieldStyle())

                withTimeBugFix {
                    Group {
                        slot.time.pickerView()
                        removeButton
                    }
                }

            }
            .onHover(perform: { if !$0 { parent.sortTable() } })
        }
        .frame(minHeight: 60)
        .padding(.horizontal)
        .overlay(RoundedRectangle.Border())
        .onAppear(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
    }
}



#if DEBUG
struct SlotBuilder_Previews: PreviewProvider {
    static var previews: some View {
        SlotBuilder(slotTable: SlotTableWrapper(table: SlotTable()))
            .frame(width: 400, height: 500)
    }
}
#endif
