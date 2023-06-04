# Slots
Slots is a simple Menubar app designed to help you manage your schedule effortlessly.

<!-- images -->
<p align="middle"><img src="https://raw.githubusercontent.com/diogoos/Slots/main/.github/sequencebuilder.png" width="32%" alt="Schedule builder"/><img src="https://raw.githubusercontent.com/diogoos/Slots/main/.github/dayview.png" width="32%" alt="Day view"/><br/>Build your schedule, then just tap to view.<br/><br/><img src="https://raw.githubusercontent.com/diogoos/Slots/main/.github/menubar.png" width="60%" alt="Menubar view"/><br/>View from the menu bar</p>
<!-- end images -->

## About
Keeping track of time, especially during distance learning programs, can be a challenge. It's often difficult to determine when one class ends and another begins. While using a calendar is a possible solution, it often gets cluttered with meetings and classes, making it less effective for tracking project and assignment due dates. To address this, I developed Slots, a lightweight macOS app that conveniently displays your class schedule in the menu bar.

## Features
* Simple Schedule Management: Easily create and customize your own schedule for each day of the week.
* Quick Access: Tap on the menu bar item to open Slots and view your schedule.
* Intuitive Interface: Edit your schedule with ease using the Slot Builder accessible through Option+Clicking the icon.
* Customizable Update Intervals: Choose between update intervals of 1 second, 30 seconds, or 1 minute for the menu bar title.

## Getting started
1. Clone the repository
```bash
git clone https://github.com/diogoos/Slots.git
```
2. Open the project in Xcode
3. Build and run!

## Usage
To access Slots, simply tap on the menu bar item. By clicking the edit button, you can create and customize your own schedule for each day of the week. For a quicker access to the Slot Builder, you can use Option+Click on the icon and then press edit.

Once you have made your adjustments, save your changes. Clicking on the menu bar item again will display your configured time slots. The menu bar text will update to show:

The current time slot
The next time slot (if it starts within the next 20 minutes)
By default, the menu bar title updates every second. However, you can customize the update interval by Option+Clicking the slots item. You have the option to choose update intervals of 1 second, 30 seconds, or 1 minute. To quit the app, simply Option+Click the menu bar item and select Quit.
