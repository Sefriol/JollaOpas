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
import "../js/UIConstants.js" as UI
import "../js/translations.js" as Translations
Component {
    id: defaultDelegate

    Item {
        id: delegateItem
        property bool selected: index == selectedIndex;
        height: root.platformStyle.itemHeight
        anchors.left: parent.left
        anchors.right: parent.right

        MouseArea {
            id: delegateMouseArea
            anchors.fill: parent;
            onPressed: selectedIndex = index;
            onClicked:  accept();
        }


        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: delegateItem.selected ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
        }

        BorderImage {
            id: background
            anchors.fill: parent
            border { left: UI.CORNER_MARGINS; top: UI.CORNER_MARGINS; right: UI.CORNER_MARGINS; bottom: UI.CORNER_MARGINS }
            source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
                                                delegateItem.selected ? root.platformStyle.itemSelectedBackground :
                                                                        root.platformStyle.itemBackground
        }

        Text {
            id: itemText
            elide: Text.ElideRight
            color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.platformStyle.itemLeftMargin
            anchors.rightMargin: root.platformStyle.itemRightMargin
            text: Translations.translate(name)
            font: root.platformStyle.itemFont
        }
    }
}
