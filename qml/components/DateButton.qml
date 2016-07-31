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
    id: dateContainer
    width: parent.width / 2
    property date storedDate
    property bool dateToday: true
    property bool customDate: false

    onClicked: {
        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {date: storedDate})
        dialog.accepted.connect(function() {
            storedDate = new Date(dialog.date.getFullYear(), dialog.date.getMonth(), dialog.date.getDate(),
                              storedDate.getHours()? storedDate.getHours() : 0,
                                                 storedDate.getMinutes()? storedDate.getMinutes() : 0)
        })
    }
    onStoredDateChanged: {
        var currentDate = new Date
        if (storedDate.getDate() !== currentDate.getDate() ||
                storedDate.getMonth() !== currentDate.getMonth() ||
                storedDate.getFullYear() !== currentDate.getFullYear()) {
            dateContainer.dateToday = false
        }
        else {
            dateContainer.dateToday = true
        }
    }
    Label {
        id: dateLabel
        width: parent.width/2
        text: qsTr("Date")
        color: !dateToday && customDate ? Theme.highlightColor : Theme.secondaryHighlightColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.rightMargin: 5
        horizontalAlignment: Text.AlignLeft
    }
    Label {
        id: dateButton
        width: parent.width/2
        text: Qt.formatDate(storedDate, "dd.MM")
        color: !dateToday && customDate ? Theme.highlightColor : Theme.secondaryHighlightColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dateLabel.right
        anchors.leftMargin: 5
        horizontalAlignment: Text.AlignLeft
    }

}


