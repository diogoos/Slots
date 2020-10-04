//
//  AppDelegate.swift
//  Slots
//
//  Created by Diogo Silva on 09/17/20.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var eventMonitor: EventMonitor?
    private var currentPopover: NSPopover?
    private var statusItem: NSStatusItem!
    private var statusTimer: Timer!
    private var slotTable: SlotTableWrapper!

    private var updateInterval: TimerUpdateInterval = .everySecond
    private enum TimerUpdateInterval {
        case everyMinute
        case every30Seconds
        case everySecond
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = statusItem.button {
            button.title = "Slots"
            button.action = #selector(statusItemPressed)
        }

        // Create the event monitor, checking for closes
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.hideCurrentPopover()
        }

        // Load the defaults
        slotTable = SlotTableWrapper(table: SlotTable(from: UserDefaults.standard))

        // Start timer
        timerTick()
        setupTimer()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hideCurrentPopover()
        eventMonitor?.stop()
        statusItem = nil
        currentPopover = nil
        
    }

    // MARK: - Views
    private lazy var contentView = ContentView(slotTable: self.slotTable)
    private lazy var builderView = SlotBuilder(slotTable: self.slotTable)
    private func menuView() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Edit slots", action: #selector(editSlots), keyEquivalent: ""))
        #if DEBUG
        menu.addItem(NSMenuItem(title: "Debug timetable", action: #selector(debug), keyEquivalent: ""))
        #endif
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Updates every", action: nil, keyEquivalent: ""))
        let everySec = NSMenuItem(title: "1 second", action: #selector(setEverySecond), keyEquivalent: "")
        let every30Sec = NSMenuItem(title: "30 seconds", action: #selector(setEvery30Seconds), keyEquivalent: "")
        let everyMin = NSMenuItem(title: "1 minute", action: #selector(setEveryMinute), keyEquivalent: "")

        switch updateInterval {
        case .everySecond: everySec.state = .on
        case .everyMinute: everyMin.state = .on
        case .every30Seconds: every30Sec.state = .on
        }
        menu.addItem(everySec)
        menu.addItem(every30Sec)
        menu.addItem(everyMin)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    @objc func setEverySecond()    { statusTimer.invalidate(); updateInterval = .everySecond; setupTimer() }
    @objc func setEvery30Seconds() { statusTimer.invalidate(); updateInterval = .every30Seconds; setupTimer() }
    @objc func setEveryMinute()    { statusTimer.invalidate(); updateInterval = .everyMinute; setupTimer() }

    #if DEBUG
    @objc func debug() {
        for (index, daySlots) in slotTable.table.enumerated() {
            print("Day \(index)")
            for slot in daySlots {
                print("  - \(slot.name) at \(slot.time)")
            }
        }
    }
    #endif

    // MARK: - Helpers
    private func showCurrentPopover() {
        // Make sure the popover exists
        guard let currentPopover = currentPopover else { return }

        // Make sure the menu bar exists
        guard let button = self.statusItem.button else { return }

        // Start monitoring for popover closing
        eventMonitor?.start()

        // Actually display the popover
        currentPopover.show(relativeTo: button.bounds,
                            of: button,
                            preferredEdge: NSRectEdge.minY)

        currentPopover.contentViewController?.view.window?.becomeKey()
        NSApp.keyWindow?.makeFirstResponder(nil)
    }

    private func hideCurrentPopover() {
        // Stop monitoring for closing
        eventMonitor?.stop()

        // hide the popover & deinitalize it
        currentPopover?.performClose(self)
        currentPopover?.close()
        currentPopover = nil
    }

    // MARK: - Timer
    func setupTimer() {
        // get the date component for the next minute
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())

        // get interval and when to next fire
        let updateIntervalSec: TimeInterval!
        switch updateInterval {
        case .everySecond:
            updateIntervalSec = 1
        case .every30Seconds:
            updateIntervalSec = 30
            if components.second ?? 0 > 30 {
                components.minute = components.minute! + 1
                components.second = 0
            } else {
                components.second = 30
            }
        case .everyMinute:
            updateIntervalSec = 60
            components.minute = components.minute! + 1
            components.second = 0
        }

        let fires = Calendar.current.date(from: components)!

        statusTimer = Timer(fire: fires, interval: updateIntervalSec, repeats: true) { [weak self] timer in
            self?.timerTick()
        }

        // add the timer to the loop
        RunLoop.main.add(statusTimer, forMode: .default)
    }

    func timerTick() {
        // get the slots for the day
        let now = Date()
        let currentDayIndex = Calendar.current.dateComponents([.weekday], from: now).weekday! - 1
        var currentSlots = slotTable.table[currentDayIndex]

        // if there is nothing set up yet, just show the text Slots
        if currentSlots.count == 0 {
            statusItem.button?.title = "Slots"
            return
        }

        // add the current date to the array
        let nowSlot = Slot(name: "#_PROTECTED_NOW_#", time: Time(from: now, ignoringSeconds: true))
        currentSlots.append(nowSlot)

        // sort the current slots by time
        currentSlots.sort { (lhs: Slot, rhs: Slot) in
            return Date(from: lhs.time) < Date(from: rhs.time)
        }

        // get one slot before now, and one slot after now
        let nowIndex = currentSlots.firstIndex(where: { nowSlot.id == $0.id })! // crash if we don't find it
        let beforeIndex = currentSlots.index(before: nowIndex)
        let afterIndex = currentSlots.index(after: nowIndex)

        // create the tile
        var statusItemTitle = currentSlots[beforeIndex].name

        // if there is a future event 20 minutes or less from now,
        // add the event to the title
        if beforeIndex >= 0 && (afterIndex <= currentSlots.count - 1) {
            let upcomingTime = Date(from: currentSlots[afterIndex].time)
            if upcomingTime.distance(to: now) >= -20*60 {
                statusItemTitle += " | \(currentSlots[afterIndex].name) "
                statusItemTitle += currentSlots[afterIndex].time.description(relativeTo: now)
            }
        }

        // set the title in the menu bar
        statusItem.button?.title = statusItemTitle
    }

    // MARK: - Intents
    @objc func statusItemPressed() {
        // show menu on option key press
        if NSEvent.modifierFlags.contains(.option) {
            hideCurrentPopover()

            statusItem.menu = menuView()
            statusItem.button?.performClick(self)
            statusItem.menu = nil

            // pretend there's a popover, just so one doesn't appear on second click
            currentPopover = NSPopover()
        }

        // check if a popover is being shown
        if currentPopover == nil {
            // show main page
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 300, height: 400)
            popover.contentViewController = NSHostingController(rootView: contentView)
            currentPopover = popover
            showCurrentPopover()
            return
        }

        // otherwise, hide the existing popover
        hideCurrentPopover()
    }

    @objc func editSlots() {
        DispatchQueue.main.async {
            self.hideCurrentPopover()

            let popover = NSPopover()
            popover.contentSize = NSSize(width: 400, height: 500)
            popover.contentViewController = NSHostingController(rootView: self.builderView)

            self.currentPopover = popover
            self.showCurrentPopover()
        }
    }

    // MARK: - Messages
    enum Message {
        case SlotBuilderActivate
        case SlotBuilderCancel
        case SlotBuilderSave
    }

    func handle(_ message: Message) {
        switch message {
        case .SlotBuilderActivate:
            currentPopover!.contentViewController = NSHostingController(rootView: builderView)
            currentPopover!.contentSize = NSSize(width: 400, height: 500)

        case .SlotBuilderCancel:
            hideCurrentPopover()

        case .SlotBuilderSave:
            currentPopover!.contentViewController = NSHostingController(rootView: contentView)
            currentPopover!.contentSize = NSSize(width: 400, height: 400)
        }
    }
}

