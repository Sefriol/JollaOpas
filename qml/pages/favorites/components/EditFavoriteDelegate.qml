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
import "../../../js/helper.js" as Helper
import "../../../js/favorites.js" as Favorites

Component {
    id: favoritesManageDelegate
    BackgroundItem {
        id: rootItem
        width: parent.width
        height: (menuOpen || renameItem) ? (label.height + citylabel.height)*2 + ListView.view.contextMenu.height : label.height + citylabel.height
        property bool menuOpen: ListView.view.contextMenu != null && ListView.view.contextMenu.parent === rootItem
        property bool renameItem: false
        function rename() {
            renameItem = true
            labelTextField.forceActiveFocus()
        }

        function remove() {
            remorse.execute(rootItem, qsTr("Deleting"), function() {
                    Favorites.deleteFavorite(coord, favoritesModel)
            })

        }
        Rectangle {
            anchors.fill: parent
            opacity: (index % 2) * 0.1
            z:-1
            color: Theme.primaryColor
        }
        onPressed: {
            if(query){
                rootItem.renameItem ? labelTextField.forceActiveFocus() : false
                selectedObject = favoritesModel.get(index)
                ListView.view.selectedItem ? ListView.view.selectedItem.highlighted = false : false
                ListView.view.selectedItem = rootItem
                rootItem.highlighted = true
                favorites_page.canAccept = true
                favorites_page.accept()
            } else {
                rootItem.highlighted = true
                pressAndHold(favorites_page)
            }
        }
        onPressAndHold: {
            if (!ListView.view.contextMenu) {
                ListView.view.contextMenu = contextMenuComponent.createObject(list)
            }

            ListView.view.contextMenu.currentItem = rootItem
            ListView.view.contextMenu.show(rootItem)
        }

        Label {
            id: title
            width: parent.width/5
            text: Helper.capitalize_string(locationType)
            font.italic: true
            font.pixelSize: Theme.fontSizeSmall
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.height/4
            color: Theme.highlightColor
        }
        Label {
            visible: !(renameItem)
            id: label
            width: parent.width - title.width
            text: name
            anchors.left: title.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.bottom: title.bottom
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
            verticalAlignment: Text.AlignVCenter
        }
        TextField {
            visible: (renameItem)
            id: labelTextField
            width: parent.width - title.width
            text: name
            anchors.left: title.right
            anchors.leftMargin: -Theme.paddingLarge
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            color: Theme.primaryColor
            EnterKey.onClicked: {
                renameItem = false
                name = text
                focus = false
                Favorites.updateFavorite(text, coord, favoritesModel)
            }
        }
        Label {
            id: citytitle
            width: parent.width/5
            text: qsTr("City")
            font.italic: true
            font.pixelSize: Theme.fontSizeExtraSmall
            anchors.top: title.bottom
            anchors.topMargin: renameItem ? Theme.paddingMedium : 0
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            color: Theme.highlightColor
        }
        Label {
            id: citylabel
            width: parent.width - citytitle.width
            text: city
            anchors.top: label.bottom
            anchors.topMargin: renameItem ? Theme.paddingMedium : 0
            anchors.left: citytitle.right
            anchors.leftMargin: Theme.paddingSmall
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            verticalAlignment: Text.AlignVCenter
        }
        IconButton {
            enabled: renameItem
            visible: renameItem
            icon.source: "image://theme/icon-l-check"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            onClicked: {
                renameItem = false
                labelTextField.focus = false
                Favorites.updateFavorite(labelTextField.text, coord, favoritesModel)
            }
        }

        RemorseItem { id: remorse }
    }
}
