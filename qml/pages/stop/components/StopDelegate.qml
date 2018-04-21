/**********************************************************************
*
* This file is part of the JollaOpas, forked from Jopas originally
* forked from Meegopas.
* More information:
*
*   https://github.com/hsarkanen/JollaOpas
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Heikki Sarkanen <heikki.sarkanen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jani Mikkonen <jani.mikkonen@gmail.com>
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*
* All assets contained within this project are copyrighted by their
* respectful authors.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* See full license at http://www.gnu.org/licenses/gpl-3.0.html
*
**********************************************************************/

import QtQuick 2.1
import Sailfish.Silica 1.0
import QtPositioning 5.3

ListItem {
    id: stop_item
    signal near
    contentHeight: Theme.itemSizeMedium
    property bool highlight: false

    onClicked: {
        // follow mode disables panning to location
        if(!appWindow.followMode) {
            if (appWindow.mapVisible)
                map.map_loader.item.flickable_map.panToLatLong(model.latitude,model.longitude)
            else
                panningDelayTimer.start() // Workaround to wait for small delay before panning to ensure that all tiles are loaded correctly when panning and map isn't already visible
        }
        // show map if currently hidden
        appWindow.mapVisible = true
    }
    Timer {
        id: panningDelayTimer
        interval: 200
        repeat: false
        onTriggered: {
            map.map_loader.item.flickable_map.panToLatLong(model.latitude,model.longitude)
        }
    }

    Location {
        id: coordinate

        coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
    }

    onStateChanged: {
        if (state == "near")
            stop_item.near()
    }

    state: (coordinate.coordinate.distanceTo(stop_page.position.position.coordinate) && coordinate.coordinate.distanceTo(stop_page.position.position.coordinate) < 150)? "near": "far"

    states: [
        State {
            name: "far"
        },
        State {
            name: "near"
        }
    ]

    Label {
        id: diff
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        horizontalAlignment: Qt.AlignLeft
        text: "+" + time_diff + " min"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
    }

    Label {
        id: time
        anchors.top: diff.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        horizontalAlignment: Qt.AlignLeft
        text: (index === 0)? Qt.formatTime(depTime, "hh:mm") : Qt.formatTime(arrTime, "hh:mm")
        font.pixelSize: Theme.fontSizeMedium
        color: stop_item.highlight ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: station_code
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.paddingSmall
        horizontalAlignment: Qt.AlignRight
        text: shortCode ? "(" + shortCode + ")" : ""
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
    }

    Label {
        text: name
        horizontalAlignment: Qt.AlignRight
        anchors.right: parent.right
        anchors.top: station_code.bottom
        anchors.rightMargin: Theme.paddingSmall
        font.pixelSize: Theme.fontSizeMedium
        color: stop_item.highlight ? Theme.highlightColor : Theme.primaryColor
    }
}
