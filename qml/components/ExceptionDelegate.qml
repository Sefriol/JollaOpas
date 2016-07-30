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
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/helper.js" as Helper

// TODO:
Component {
    id: disruptionDelegate
    Item {
        id: delegate_item
        width: parent.width
        height: column.height + UIConstants.DEFAULT_MARGIN

        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            anchors.leftMargin: UIConstants.DEFAULT_MARGIN
            Text {
                text: Qt.formatDateTime(Helper.parse_disruption_time(time), "dd.MM.yyyy - hh:mm")
                anchors.left: parent.left
                horizontalAlignment: Qt.AlignLeft
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                color: Theme.primaryColor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                text: info_fi
                horizontalAlignment: Text.AlignLeft
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scalingFactor
                color: Theme.secondaryColor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
    }
}
