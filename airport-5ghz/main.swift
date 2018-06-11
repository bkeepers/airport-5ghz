#!/usr/bin/swift

import Foundation
import CoreWLAN

if(CommandLine.arguments.count != 2) {
    print("Usage: airport-5ghz <wifi-password>")
    exit(1)
}

let password = CommandLine.arguments[1]

func networkInfo(ssid: String, bssid: String, channel: CWChannel, rssiValue: Int) -> String {
    return
        "\(ssid.padding(toLength: 24, withPad: " ", startingAt: 0) )" +
        "\(bssid.padding(toLength: 17, withPad: " ", startingAt: 0) )  " +
        "\(channel.channelNumber)".padding(toLength: 3, withPad: " ", startingAt: 0) +
        "  \(rssiValue)"
}

if let wifiClient = CWWiFiClient() {
    if let interface = wifiClient.interface() {
        if !interface.powerOn() {
            print("Wifi interface is not activated")
        } else {
            print("Interface:", interface.interfaceName!)
            print("Mode:", interface.activePHYMode())

            print("\("ESSID".padding(toLength: 24, withPad: " ", startingAt: 0))" +
                "\("BSSID".padding(toLength: 17, withPad: " ", startingAt: 0))  " +
                "\("Ch".padding(toLength: 3, withPad: " ", startingAt: 0))  " + "dBm")

            print("Current Network:")
            print(networkInfo(ssid: interface.ssid()!, bssid: interface.bssid()!, channel: interface.wlanChannel()!, rssiValue: interface.rssiValue()))

            // Get the strongest 5GHz network
            let network = interface.cachedScanResults()!.filter { $0.ssid == interface.ssid() }
                .filter { $0.wlanChannel.channelBand == CWChannelBand.band5GHz }
                .max { $0.rssiValue < $1.rssiValue }!

            if network.wlanChannel == interface.wlanChannel()! {
                print("Already on the best network")
                exit(0)
            }

            print("Best 5GHz Network:")
            print(networkInfo(ssid: network.ssid!, bssid: network.bssid!, channel: network.wlanChannel, rssiValue: network.rssiValue))

            try interface.associate(to: network, password: password)

            print("New Network:")
            print(networkInfo(ssid: interface.ssid()!, bssid: interface.bssid()!, channel: interface.wlanChannel()!, rssiValue: interface.rssiValue()))

        }
    }
}
