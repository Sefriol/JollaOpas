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

BackgroundItem {
    width: parent.width
    property date storedDate
    property alias text: startTimeLabel.text
    signal timeChanged(date newTime)

    Label {
        id: typeLabel
        text: qsTr("Time")
        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -startTimeLabel.height
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeTiny
        x: Theme.horizontalPageMargin
    }
    Label {
        id: startTimeLabel
        width: parent.width
        text: Qt.formatDateTime(storedDate, "hh:mm")
        color: Theme.highlightColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 5
        horizontalAlignment: Text.AlignRight
    }
    onClicked: {
        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog",
            {hourMode: (DateTime.TwentyFourHours), hour: storedDate.getHours(), minute: storedDate.getMinutes()})
        dialog.accepted.connect(function() {
            storedDate = new Date(storedDate.getFullYear() ? storedDate.getFullYear() : 0,
                                  storedDate.getMonth() ? storedDate.getMonth() : 0,
                                  storedDate.getDate() ? storedDate.getDate() : 0,
                                  dialog.time.getHours(),
                                  dialog.time.getMinutes())
        })
    }
    IconButton {
        id: clockNowButton
        width: parent.width/4
        icon.source: "image://theme/icon-m-watch"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.horizontalCenter
        onClicked: {
            content_column.setTimeNow()
        }
        Label {
            id: nowText
            text: qsTr("Now")
            color: clockNowButton.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.icon.right
            font.pixelSize: Theme.fontSizeTiny
        }
    }
}
