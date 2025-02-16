#Throttle For Transmission

A transmission remote client for MacOS written in pure Swift with SwiftUI

# This is a fork of Mission

There are a few things that I loved about TransGui, but it's unstable on mac, and Mission's base was really appealing. I've spoken with the original maintainer and have their blessing.
I've renamed to avoid confusion, and added iOS support.

## Testing
I would call this a Beta. There may be bugs. Let me know, they will be fixed.

##Icons
The app icon as based off the linux Transmission icon.
Static icons use the inbult SF Icons, and thumnails use icons from https://icons8.com


## I'm new to swift and a pedestrian programmer.
I know there is a lot of refactoring to do, things that would reduce complexity. I'll work on it. I've focused on trying to achieve feature parity with other, non mac native tools.

##Done so far:
- Torrent Creation (Experimental)
- Sidebar
- Moved actions into the info screen for easy click-ability
- Added a path option in server settings (Defaults to /transmission/rpc), useful for reverse proxies.
- Opens .torrents and magnet links (This was a big one for me)
- Server selection when adding a torrent
- Filter by Status
- Sorting by date or last updated
- Search
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
- Starring 
- Thumbnails (with caveats )
#IOS App!
- Tested on iPhone 16 pro & iPad Mini 6
- File browsing of remote content with native player & handoff to player of choice
- Save location browsing

##Todo so far:
- Start Paused
- More confirmations - some things happen without feedback that they were successful.
- Accessibility
- Fix bugs
- Code Refactoring - a lot of copy / paste that should be reduces to classes or functions
- helper apps for mac & windows, to make it easy to connect remotely via iOS
- Caddy sample config
- Full label support (Partly implemented with stars)

# Installing

## Mac
- Download the [latest release](https://github.com/Steve2Go/mission25/releases)
- Open Unzip `Throttle.zip`
- Drag `Throttle.app` to `Applications` folder


## iOS
- Download the [latest release](https://github.com/Steve2Go/mission25/releases)
- Use your app installer of choice (I like Sideloadly) https://sideloadly.io

#Remote Preview for iOS

Transmission has no standard remote preview capabilities, and iOS makes it hard to direct link, so I settled on remote access via HTTP.
Think of it as a preview only - The way it's implemented isn't as nice as many dedicated file managers, but it works well to quickly sample any downloads tho check they work etc. It's only tested with video and images at this point, checking for native player support and falling back to your desired player.
Anything not an image or video is offered as a download.

!!!! Use HTTPS & Authentication !!!
Otherwise your entire downloads are open to the world.
Using Basic Authentication is completely insecure without HTTP / SSL
The Simple Server option uses SSL, but a self signed certificate, better than no SSL, but open to man in the middle attacks. The instructions are provided as a test of concept or LAN use only. You should be using VPN or NGINX / Caddy / Others as a reverse proxy with ssl.

##Installing remote Preview 


##Simple Web Server (mac/win) - Easy, less secure, Not recommended for production.
Downloadable from the App Store & Microsoft store.

Create a new server pointed at your downloads folder.
Tick Accessible on your local network
- Basic options - Tick "Show Directory Listing" (Needed for file selection)
- Security - Tick Use HTTPS and generate dummy cert (This is where the risk is)
- Tick Enable Basic HTTP Authentication and choose a sensible password
- Save & Start the server - it will provide you with links that you can use in Throttle

Port forwarding in your router is not recommended for this configuration

##Nginx - Preferred

If you're already using NGNIX to proxy over HTTPS, this is easy, just add a location block to your server configuration:
`location /pathwhenbrowsingfromserver/ {
        auth_basic "Administrator’s Area";
        auth_basic_user_file /etc/apache2/.htpasswd;
        alias /pathtoyourfiles/;
        autoindex on;
    }`
    
and for predictability, in nginx.conf, in the http block you can optionally add:
`disable_symlinks off;
 charset utf-8;
`
    
Verify that apache2-utils (Debian, Ubuntu) or httpd-tools (RHEL/CentOS/Oracle Linux) is installed.
`sudo htpasswd -c /etc/apache2/.htpasswd yourusername`
Press Enter and type the password for yourusername at the prompts

See more details from the source at https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/

##Caddy
Coming



There are many other ways to provide https access to your files, but for security, you should ensure that they are protected by authentication & ssl.
Throttle will take care of accessing basic authentication (which is only secure over ssl)
egory: SwiftUI | TID: 0x4b1abd
