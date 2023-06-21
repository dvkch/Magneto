# Disco

Disco is a Swift library allowing various network features : 

- list the interfaces available on a device, including their IP and netmask
- ping a whole interface, using its IP and netmask to list the possibly reachable IPs
- use Bonjour and common service names to obtain a possible hostname for an IP address
- check at regular intervals if a host is reachable on a specific port, for multiple paris at a time

## Setup

It is currently available via Cocoapods. To be able to use `HostnameResolver`, you need to ass the following to your app's `Info.plist`  :

```
<key>NSBonjourServices</key>
<array>
	<string>_smb._tcp</string>
	<string>_afpovertcp._tcp</string>
	<string>_daap._tcp</string>
	<string>_home-sharing._tcp</string>
	<string>_rfb._tcp</string>
	<string>_companion-link._tcp</string>
	<string>_raop._tcp</string>
	<string>_sleep-proxy._udp</string>
	<string>_http._tcp</string>
</array>
```

## License

Use it as you like in every project you want, redistribute as much as you want, preferably with mentions of my name when it applies and don't blame me if it breaks :)

-- dvkch
 
