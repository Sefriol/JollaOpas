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
import QtQuick.XmlListModel 2.0
import "../../js/UIConstants.js" as UIConstants
import "../../js/reittiopas.js" as Reittiopas
import "../../js/storage.js" as Storage
import "../../js/favorites.js" as Favorites
import "../../components"

Dialog {
    id: search_page
    property string emptystr
    property alias selectName : statusIndicator.validateState
    property alias validDestination : statusIndicator.sufficientState
    property variant selectObject
    property string searchType
    property alias statusIndicatorState: statusIndicator.busyState
    PageHeader { id: header ; title: searchType == "source" ? qsTr("Departure") : qsTr("Destination") }
    Timer {
        id: suggestionTimer
        interval: 1200
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            if(textfield.acceptableInput) {
                suggestionModel.source = Reittiopas.get_geocode(textfield.text, Storage.getSetting('api'))
            }
        }
    }
    XmlListModel {
        id: suggestionModel
        query: "/response/node"
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "city"; query: "city/string()" }
        XmlRole { name: "coord"; query: "coords/string()" }
        XmlRole { name: "shortCode"; query: "shortCode/string()" }
        XmlRole { name: "housenumber"; query: "details/houseNumber/string()" }
        XmlRole { name: "locationType"; query: "locType/string()" }

        onStatusChanged: {
            statusIndicatorState = suggestionModel.status === XmlListModel.Loading
            if(status == XmlListModel.Ready && source != "") {
                /* if only result, take it into use */
                validDestination = (suggestionModel.count > 0)
                if(suggestionModel.count == 1) {
                    selectName = suggestionModel.get(0).name.split(',', 1).toString()
                    selectObject = suggestionModel.get(0)
                    search_page.accept()
                } else if (suggestionModel.count == 0) {
                    selectName = emptystr
                    selectObject = null
                    appWindow.useNotification( qsTr("No results") )
                } else {
                    selectName = emptystr
                    selectObject = null
                }
            } else if (status == XmlListModel.Error) {
                suggestionModel.source = ""
                appWindow.useNotification( qsTr("Could not find location") )
            }
        }
    }
    Column {
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: header.bottom
        Item {
            property variant model
            property variant delegate

            id: firstRow
            width: parent.width
            height: textfield.height
            Searchfield {
                id: textfield
                anchors.left: parent.left
                anchors.right: parent.right
                placeholderText: qsTr("Type a location")
                focus: true
                onTextChanged: {
                    if(text != selectName) {
                        suggestionModel.source = emptystr
                        selectName = emptystr
                        selectObject = null
                        if(acceptableInput)
                            suggestionTimer.restart()
                        else
                            suggestionTimer.stop()
                    }
                }
                StatusIndicatorCircle {
                    id: statusIndicator
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -8
                }
                Keys.onReturnPressed: {
                    textfield.focus = false
                    parent.focus = true
                }
            }
        }
        SilicaListView {
            width: parent.width
            height: Screen.height
            id: view
            model:suggestionModel
            delegate: SuggestionDelegate {
                onClicked: {
                    selectName = name
                    selectObject = suggestionModel.get(index)
                    search_page.accept()
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
