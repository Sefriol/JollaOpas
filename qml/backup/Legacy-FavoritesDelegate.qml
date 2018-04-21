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

ListItem {
    id: delegateItem
    width: ListView.view.width
    contentHeight: Theme.itemSizeMedium

    Image {
        id: icon
        source: index == 0 ? "image://theme/icon-m-gps" : "image://theme/icon-m-favorite-selected"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 40 * Theme.pixelRatio
        width: height
    }

    Label {
        id: locName
        color: Theme.primaryColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.right: parent.right
        text: name
        font.pixelSize: Theme.fontSizeMedium
    }
}
