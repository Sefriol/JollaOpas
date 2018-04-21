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
import "../js/favorites.js" as Favorites
import "../js/helper.js" as Helper
import "../components"

Dialog {
    id: favorites_page
    property bool query: false
    canAccept: false
    canNavigateForward: query
    forwardNavigation: query
    property variant selectedObject
    property bool selectedItem: false
    Component.onCompleted: {
        Favorites.getFavorites(favoritesModel)
    }
    ListModel {
        id: favoritesModel
    }
    SilicaListView {
        id: list
        anchors.fill: parent
        property Item contextMenu
        property Item selectedItem
        model: favoritesModel
        delegate: EditFavoriteDelegate {}
        VerticalScrollDecorator {}

        header: header

        ViewPlaceholder {
            enabled: list.count == 0
            text: qsTr("No saved favorite places")
        }
        Component {
            id: contextMenuComponent
            ContextMenu {
                id: menu
                property Item currentItem
                MenuItem {
                    text: qsTr("Rename")
                    onClicked: menu.currentItem.rename()
                }
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: menu.currentItem.remove()
                }
            }
        }
    }

    Component {
        id: header
        PageHeader {
            title: query ? qsTr("Select") : qsTr("Manage favorite places")
            Rectangle {
                anchors.fill: parent
                opacity: 0.1
                z:-1
                color: Theme.primaryColor
            }
        }
    }
}
