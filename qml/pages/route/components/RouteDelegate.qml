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
import "qrc:/colors.js" as Colors

BackgroundItem {
    id: routeDelegate
    height: type != "walk" ? Theme.itemSizeMedium : Theme.itemSizeExtraSmall
    width: parent.width

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../../stop/StopPage.qml"),{ leg_index: leg_number, leg_code: code })
    }

    Label {
        id: length_text
        text: type == "walk"? Math.floor(length/100)/10 + " km" : duration + " min"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        width: Theme.itemSizeMedium
    }

    Column {
        id: rect
        anchors.left: length_text.right
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        Rectangle {
            anchors.right: parent.right
            width: 15
            height: 5
            color: Colors.colors[type]
        }

        Rectangle {
            anchors.right: parent.right
            width: 5
            height: routeDelegate.height + Theme.paddingSmall
            color: Colors.colors[type]
        }

        Rectangle {
            anchors.right: parent.right
            width: 15
            height: 5
            color: Colors.colors[type]
        }
    }

    Column {
        id: transportColumn
        anchors.left: rect.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.paddingLarge
        width: 100

        Image {
            visible: type != "walk"
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/" + type + ".png"
            height: 50
            width: height
            smooth: true
        }

        Label {
            visible: type != "walk"
            text: code
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
