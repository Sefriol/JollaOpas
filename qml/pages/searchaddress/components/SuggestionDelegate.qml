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
import "qrc:/helper.js" as Helper

ListItem {
    id: suggestionDelegate
    width: ListView.view.width
    contentHeight: Theme.itemSizeMedium
    Label {
        id: locName
        elide: Text.ElideRight
        color: Theme.primaryColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: locType.left
        text: name + " " + housenumber
        font.pixelSize: Theme.fontSizeMedium
    }
    Label {
        text: Helper.capitalize_string(locationType)
        anchors.bottom: parent.bottom
        font.italic: true
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        color: suggestionDelegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
    }

    Label {
        id: locType
        elide: Text.ElideRight
        color: Theme.secondaryColor
        horizontalAlignment: Text.AlignRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        text: city
        font.pixelSize: Theme.fontSizeSmall
    }
}
