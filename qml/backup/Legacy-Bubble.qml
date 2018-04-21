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
import "../js/theme.js" as ThemeJS

Rectangle {
    height: 35 * Theme.pixelRatio
    width: (count_label.width + 15) * Theme.pixelRatio
    radius: 12 * Theme.pixelRatio
    smooth: true
    color: "#0d67b3"
    property int count
    Text {
        id: count_label
        text: count
        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor * Theme.pixelRatio
        color: ThemeJS.theme[appWindow.colorscheme].COLOR_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
