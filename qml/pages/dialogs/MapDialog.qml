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
import QtPositioning 5.3
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../../js/reittiopas.js" as Reittiopas
import "../../js/storage.js" as Storage
import "../../components"

Dialog {
    id: mapDialog
    backNavigation: false
    canNavigateForward: false
    forwardNavigation: false
    property string inputCoord
    property variant resultObject
    property string resultName

    function getCoord(coord){
        var array = coord.split(',')
        return QtPositioning.coordinate(array[1],array[0])
    }

    state: resultName ? "validated" : "error"
    states: [
        State {
            name: "error"
            PropertyChanges { target: forward; enabled: false }
            PropertyChanges { target: statusIndicator; color: "red" }
        },
        State {
            name: "validated"
            PropertyChanges { target: forward; enabled: true }
            PropertyChanges { target: statusIndicator; color: "green" }
        }
    ]
    transitions: [
        Transition {
            ColorAnimation { duration: 100 }
        }
    ]

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
            if(status == XmlListModel.Ready && source != "") {
                /* if only result, take it into use */
                if(suggestionModel.count >= 1) {
                    mapDialog.resultObject = suggestionModel.get(0)
                    mapDialog.resultName = textfield.text = suggestionModel.get(0).name.split(',', 1).toString()
                } else if (suggestionModel.count == 0) {
                    appWindow.useNotification( qsTr("Could not find the location") )
                }
            } else if (status == XmlListModel.Error) {
                appWindow.useNotification( qsTr("Could not find the location") )
            }
        }
    }

    MapElement {
        id: map
        selectedCoord:inputCoord ? mapDialog.getCoord(inputCoord)
                                 : QtPositioning.coordinate()
        anchors {
            top: parent.top
            left: parent.left
            bottom: tools.top
            right: parent.right
        }

        Component.onCompleted: {
            getLocationInitialize(inputCoord ? inputCoord : Storage.getSetting("api") === "helsinki" ? "24.9407379411,60.1687069096" : "23.7667000000,61.5000000000", inputCoord ? true : false)
            findLocation = true
            panningDelayTimer.start() // Workaround to wait for small delay before panning to ensure that all tiles are loaded correctly when panning
        }
        Timer {
            id: panningDelayTimer
            interval: 200
            repeat: false
            onTriggered: {
            }
        }
        onSelectedCoordChanged: {
            if(selectedCoord !== QtPositioning.coordinate())
                suggestionModel.source = Reittiopas.get_reverse_geocode(selectedCoord.latitude,
                                                                        selectedCoord.longitude,
                                                                        Storage.getSetting('api'))
        }
    }

    Row {
        id: tools

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        height: back.height

        IconButton {
            id: back
            icon.source: "image://theme/icon-m-back"
            onClicked: pageStack.pop()
        }
        Label {
            id: textfield
            text: resultName ? resultName : qsTr("Tap and Hold to Select")
            height: parent.height
            width: parent.width * 2/3
            horizontalAlignment: Text.AlignHCenter
            Rectangle {
                id: statusIndicator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                smooth: true
                radius: 10 * Theme.pixelRatio
                height: 20 * Theme.pixelRatio
                width: 20 * Theme.pixelRatio
                opacity: 0.6
            }
            BusyIndicator {
                id: busyIndicator
                running: suggestionModel.status === XmlListModel.Loading
                anchors.centerIn: statusIndicator
                size: BusyIndicatorSize.Small
                MouseArea {
                    id: spinnerMouseArea
                    anchors.fill: parent
                    onClicked: {
                        suggestionModel.source = ""
                    }
                }
            }
        }
        IconButton {
            id: forward
            icon.source: "image://theme/icon-m-back"
            icon.rotation: 180
            onClicked:{
                mapDialog.accept()
            }
            enabled: false
        }

    }
}
