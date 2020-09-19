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
    }

    func applicationWillTerminate(_ notification: Notification) {
        hideCurrentPopover()
        eventMonitor?.stop()
        statusItem = nil
        currentPopover = nil
        
    }

    // MARK: - Views
    private lazy var contentView = ContentView()
    private func menuView() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Edit slots", action: #selector(editSlots), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

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
    }

    private func hideCurrentPopover() {
        // Stop monitoring for closing
        eventMonitor?.stop()

        // hide the popover & deinitalize it
        currentPopover?.performClose(self)
        currentPopover?.close()
        currentPopover = nil
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
            popover.contentViewController = NSHostingController(rootView: SlotBuilder())

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
            currentPopover!.contentViewController = NSHostingController(rootView: SlotBuilder())
            currentPopover!.contentSize = NSSize(width: 400, height: 500)

        case .SlotBuilderCancel:
            hideCurrentPopover()

        case .SlotBuilderSave:
            currentPopover!.contentViewController = NSHostingController(rootView: contentView)
            currentPopover!.contentSize = NSSize(width: 400, height: 400)
        }
    }
}

