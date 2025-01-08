# Mission
<p align="center">

<img width="564" alt="Screen shot" src="https://user-images.githubusercontent.com/6336819/185224968-145716da-4565-4c9e-bca7-38fc41e0d3aa.png">
</p>

A transmission remote client for MacOS written in pure Swift with SwiftUI

# This is a fork

The original project appears to have died. 

There are a few things that I loved about TransGui, but it's unstable on mac, and Mission's base was really appealing. I'd happily merge my changes back into main if it comes back to life.
I've added 25 to the name, ie 2025. It's thre repository only, and the intention is to merge this back it the original project comes back to life and the original maintainer is agreeable.

## I'm new to swift and a prdestrian programmer.
I know there is a lot of refactoring to do, things that would reduce complexity. I'll work on it. I've focued on trying to acheive feature parity with other, non mac tools.

##Done so far:
- Added a path option in server settings (Defaults to /transmission/rpc), useful for reverse proxies.
- Opens .torrents and magnet links (This was a big one for me)
- Server selection when adding a torrent
- Filter by Status
- Sorting by date or last updated
- Torrent Information View (Based on Transgui)
- File Selection with add, remove, Select all
- Path mapping with finder integration
- Ability to reannounce and verify files
- disabled updater (For now)
- Fixed a crash when torrents failed to add
- Settings view
-- Delete on download
-- Server on startup - Default or last
-- Server on startup - Default or last

##Todo so far:
- Start Paused
- More confirmations - some things happen whithout feedback that they were successful.
- Muti torrent operations (Started by TheNightmanCodeth for Pause, I've implimented on download file selection done, more to come)
- More filters & Sorting
- Torrent Creation
- Tune UI for usability
- Should everything be in menus or be moved to buttons? Are the menu's fiddly?
- Accessibility
- Fix bugs

# Installing

- Download the [latest release](https://github.com/Steve2Go/mission25/releases)
- Open `Mission.dmg`
- Drag `Mission.app` to `Applications` folder

After installing this app to Applications you need to run following command in the terminal:

xattr -dr com.apple.quarantine /Applications/Mission.app

The reason why this command is needed is that this app is unsigned and macOS will prevent it from running.
This command tells macOS to allow this app to run.

You'll need to do this after each update.
