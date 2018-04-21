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
import "../js/UIConstants.js" as UIConstants
import "../js/theme.js" as Theme

Rectangle {
    id: header
    property alias title: title.text
    property alias title_color: title.color
    property alias background_color: header.color

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: UIConstants.DEFAULT_MARGIN

    height: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT * appWindow.scalingFactor:
                                  UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE * appWindow.scalingFactor
    z: 10
    Text {
        id: title
        color: Theme.theme[appWindow.colorscheme].COLOR_APPHEADER_FOREGROUND
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_PORTRAIT * appWindow.scalingFactor:
                                                    UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE * appWindow.scalingFactor
        anchors.topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT * appWindow.scalingFactor:
                                                 UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE * appWindow.scalingFactor
        font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scalingFactor
    }
}
