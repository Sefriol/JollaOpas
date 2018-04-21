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
import "../../../js/UIConstants.js" as UIConstants

Item {
    id: settings_item
    property alias mouseArea : mouseArea
    property alias setting : setting
    property alias value : value
    property alias settingModel : settingModel
    property string group : ""
    property bool showDrillDown : false
    property bool showComboBox : false

    height: UIConstants.LIST_ITEM_HEIGHT_LARGE * appWindow.scalingFactor
    width: parent.width

    ListModel {
        id: settingModel
    }

    function set_value(new_value) {
        value.text = new_value
    }

    function add_value(new_value) {
        value.text += value.text != "" ? ", " : ""
        value.text += new_value
    }

    function clear_value() {
        value.text = ""
    }

    SelectionDialog {
        id: settingDialog
        model: settingModel
    }

    Rectangle {
        height: parent.height
        width: appWindow.width
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightColor
        z: -1
        visible: mouseArea.pressed
    }
    Column {
        width: parent.width - (parent.showDrillDown ? 64 : 0)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: setting
            color: Theme.primaryColor
            font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
        Text {
            id: value
            width: parent.width
            color: Theme.secondaryColor
            font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scalingFactor
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
    }

    Image {
        source: "image://theme/icon-m-common-drilldown-arrow" + (Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: parent.showDrillDown
    }

    Image {
        source: "image://theme/meegotouch-combobox-indicator" + (Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED? "-inverted" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: parent.showComboBox
    }

    MouseArea {
        id: mouseArea
        anchors.fill: settings_item
        onClicked: settingDialog.open()
    }
}

