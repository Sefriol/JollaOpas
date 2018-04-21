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
import "../js/helper.js" as Helper
import "../js/UIConstants.js" as UIConstants

Item {
    id: locationSwitch
    state: "normal"
    anchors.right: parent.right
    anchors.top: from.bottom
    width: Theme.itemSizeSmall
    height: Theme.itemSizeSmall

    property variant from
    property variant to

    Rectangle {
        anchors.fill: parent
        color: Theme.secondaryHighlightColor
        z: -1
        visible: locationSwitchMouseArea.pressed
    }
    Image {
        id: switchImage
        anchors.centerIn: parent
        source: "image://theme/icon-m-shuffle"
        smooth: true
        height: 50 * Theme.pixelRatio
        mirror: false
        width: height
    }
    MouseArea {
        id: locationSwitchMouseArea
        anchors.fill: parent

        onClicked: {
            Helper.switch_locations(from,to)
            switchImage.mirror = !switchImage.mirror
            locationSwitch.state = locationSwitch.state == "normal" ? "rotated" : "normal"
        }
    }
    states: [
        State {
            name: "rotated"
            PropertyChanges { target: locationSwitch; rotation: 180 }
        },
        State {
            name: "normal"
            PropertyChanges { target: locationSwitch; rotation: 0 }
        }
    ]
    transitions: Transition {
        RotationAnimation { duration: 500; direction: RotationAnimation.Clockwise; easing.type: Easing.InOutCubic }
    }
}

