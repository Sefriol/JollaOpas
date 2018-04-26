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
import "qrc:/reittiopas.js" as Reittiopas

Item {
    id: stationDelegate
    height: Theme.itemSizeSmall

    Column {
        id: time_column
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.paddingSmall
        width: 100

        Label {
            text: Qt.formatTime(time, "hh:mm")
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
        }
    }

    Row {
        height: parent.height
        anchors.left: time_column.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.paddingSmall
        layoutDirection: Qt.RightToLeft

        Label {
            text: name
            horizontalAlignment: Qt.AlignRight
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
        }

        Label {
            id: station_code
            horizontalAlignment: Qt.AlignRight
            anchors.verticalCenter: parent.verticalCenter
            text: typeof(shortCode) === "undefined" ? "" : "(" + shortCode + ")"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
        }
    }
}
