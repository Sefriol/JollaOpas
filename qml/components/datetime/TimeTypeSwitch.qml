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

Column {
    property bool departure: true
    BackgroundItem {
        id: timeTypeSelector
        width: Screen.width
        onClicked: {
            departure = !departure
        }
        Label {
            id: typeLabel
            text: qsTr("Type")
            color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -arrivalLabel.height/1.5
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeTiny
            x: Theme.horizontalPageMargin
            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Label {
            id: arrivalLabel
            text: qsTr("Arrival")
            color: !departure ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: lsign.left
            anchors.rightMargin: 5
            horizontalAlignment: Text.AlignRight
            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Label {
            id: lsign
            text: "\u25C3"
            color: !departure ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.right: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Label {
            id: rsign
            text:  "\u25B9"
            color: departure ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.left: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Label {
            id: departureLabel
            text: qsTr("Departure")
            color: departure ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: rsign.right
            anchors.leftMargin: 5
            horizontalAlignment: Text.AlignLeft
            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }

    }
}
