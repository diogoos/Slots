# Slots
A simple mac menubar app for managing time 

<!-- images -->
<p align="middle"><img src="https://i.ibb.co/8jn0FWQ/Screen-Shot-2020-10-10-at-08-48-50.png" width="32%" alt="Schedule builder"/><img src="https://i.ibb.co/VmvF2jz/Screen-Shot-2020-10-12-at-08-49-50.png" width="32%" alt="Day view"/><br/>Build your schedule, then just tap to view.<br/><br/><img src="https://i.ibb.co/gRhrPCs/Screen-Shot-2020-10-05-at-09-20-46.png" width="60%" alt="Menubar view"/><br/>View from the menu bar</p>
<!-- end images -->

## About
Especially during the Distance Learning program, it has become hard to keep track of time. It can be hard to tell when a specific class ends, and when another begins. Although using a calendar is a possible solution, I don't really like this - my whole calendar is cluttered with meetings and classes, when I prefer to use it for project and assignment due dates. So, I built this tiny mac app that will keep track of when classes start and end, and show them in the menubar.

## Usage
Tap on the menu bar item to open Slots. Tap on the edit button to create and customize your own schedule, specific for each day of the week. You can also access the Slot Builder by Option+Clicking on the icon, then pressing edit. Once you have made your adjustments, tap save. When you click on the menu bar item again, it will show you the time slots you configured. The menu bar text will also update. It will display:
- The current time slot
- The next time slot (if it starts in the next 20 minutes)

The menu bar title updates every second by default. If you Option+Click the slots item, you can change between update intervals of 1 second, 30 seconds, and 1 minute. To quit the app, Option+Click the menu bar item, then select Quit.


## Advanced Usage
> Note: This section has *not* been extensively tested. All configuration settings should work; however, their usage is not recommended.
### Custom refresh rate
The refresh rate options exposed to the user are 1 second, 30 seconds and 1 minute. You can change them by Option+Clicking the menu. However, if you want a custom refresh rate, you are able to set this using the *defaults* terminal command. There are a few limitations in setting a custom update interval: for the options configurable in the menu bar, the app will start updating on the correct time. For example, if you select 1 minute, the app will update once, then start updating every minute at 0 seconds. However, if you select a custom option, such as 2 minutes, then the app will update once, then update every 2 minutes from that time. This means that the updates will not sync up to the current minute. The menu bar might update at 09:20:14 instead of 09:20:00.

- Calculate your desired refresh rate in seconds
- Open `Terminal.app`
- Use the following command `defaults write com.ds.Slots refreshRate -int yourRefreshRateInSeconds`
- Quit Slots and relaunch the app
- To revert back to the default refreshRate use `defaults delete com.ds.Slots refreshRate`

### JSON Schedule
The slot builder is a friendly interface to build your Slot schedules. However, some people may prefer to configure this through another interface. Therefore, Slots *experimentally* supports loading your own JSON Schedule. Please note that invalid formatting or settings may cause the app to crash on launch, or ignore your schedule.

#### JSON Structure
The Slot JSON structure works like this:
```JSON
[
  [], // Sunday is empty
  [ // Monday has two events
    {
      "name": "Monday Event 1", // The title of the event, as a string
      "time": "060000" // The time of the event as a string in the following format (HHmmss)
    },
    {
      "name": "Monday Event 2", // The title of the event, as a string
      "time": "080000" // The time of the event as a string in the following format (HHmmss)
    },
  ], 
  [], // Tuesday is empty
  [], // Wednesday is empty
  [], // Thursday is empty
  [], // Friday is empty
  []  // Saturday is empty
]
```
#### Applying JSON Schedule
1. Quit Slots (Option+Click on logo, then press Quit)
2. Open `Terminal.app`
3. Minify your JSON code, combining everything into one line
4. Run the following command `/usr/libexec/PlistBuddy ~/Library/Containers/com.ds.Slots/Data/Library/Preferences/com.ds.Slots.plist`
5. Escape the JSON into a string. For example, `"[[{\"name\": \"hi\", time: \"000100\"}], [], [], [], [], [], []]"`
6. Write `set ` then paste in your string
7. Type in `save`
8. Type in `exit`


## License
Copyright © 2020

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
