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
import "../js/favorites.js" as Favorites
import "../components"

Dialog {
    id: edit_dialog
    property alias name: editTextField.text
    property string coord
    property string old_name: ""
    property variant favoritesModel

    canAccept: name.text !== ''

    onAccepted: {
        if("OK" === Favorites.updateFavorite(edit_dialog.name, edit_dialog.coord, favoritesModel)) {
            favoritesModel.clear()
            Favorites.getFavorites(favoritesModel)
        }
    }

    Column {
        anchors.fill: parent

        DialogHeader {
            acceptText: qsTr("Edit favorite place")
        }

        Label {
            text: qsTr("Edit favorite name")
            font.pixelSize: Theme.fontSizeMedium
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignCenter
            font.bold: true
            color: Theme.primaryColor
        }

        Spacing {}

        TextField {
            id: editTextField
            width: parent.width

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-m-clear"
                visible: (editTextField.activeFocus)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editTextField.text = ''
                    }
                }
            }

            Keys.onReturnPressed: {
                editTextField.focus = false
                parent.focus = true
            }
        }
    }
}
