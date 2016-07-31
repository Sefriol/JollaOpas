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
import QtPositioning 5.3
import QtQuick.XmlListModel 2.0
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites

Column {
    property alias type : label.type
    property string font
    property string lineHeightMode
    property string lineHeight
    property alias textfield : textfield.text

    property alias current_name : statusIndicator.validateState
    property string current_coord : ''

    property alias positionBusy: statusIndicator.busyState
    property alias gpsLoading: statusIndicator.sufficientState
    gpsLoading: false
    positionBusy:false

    Location {
        id: previousCoord

        coordinate: QtPositioning.coordinate(0, 0)
    }

    property string destination_name : ''
    property string destination_coord : ''
    property variant destinationObject

    property bool isFrom : false

    property bool destination_valid : (suggestionModel.count > 0)
    property bool isFavorite : false
    property bool disable_favorites : false

    height: firstRow.height * 2
    width: parent.width

    signal locationDone(string name, string coord)
    signal currentLocationDone(string name, string coord)
    signal locationError()

    Component.onCompleted: {
        Favorites.initialize()
    }

    function favoritesUpdateLocation(object){
        tempStorageModel.clear()
        tempStorageModel.append(object)
        updateLocation(tempStorageModel.get(0))
    }

    function updateLocation(object) {
        suggestionModel.source = ""
        var address = object.name.split(',', 1).toString()
        var housenumber = object.housenumber
        if(housenumber && address.slice(address.length - housenumber.length) != housenumber)
            address += " " + housenumber

        destination_name = address
        destination_coord = object.coord
        destinationObject = object
        textfield.text = address
        isFavorite = Favorites.favoritExists(object.coord)
        locationDone(address, object.coord)
    }

    function updateCurrentLocation(object) {
        currentLocationModel.source = ""
        var address = object.name

        if(object.housenumber && address.slice(address.length - object.housenumber.length) != object.housenumber)
            address += " " + object.housenumber

        current_name = address
        current_coord = object.coord

        textfield.placeholderText = address
        isFavorite = Favorites.favoritExists(suggestionModel.get(0).coord)
        currentLocationDone(address, coord)
    }

    Timer {
        id: gpsTimer
        running: isFrom
        onTriggered: getCurrentCoord()
        triggeredOnStart: true
        interval: 200
        repeat: true
    }

    function positionValid(position) {
        if(position.latitudeValid && position.longitudeValid)
            return true
        else
            return false
    }

    function getCurrentCoord() {
        /* wait until position is accurate enough */
        if(positionValid(positionSource.position)){
            if(positionSource.position.horizontalAccuracy > 0 && positionSource.position.horizontalAccuracy < 100) {
                gpsTimer.stop()
                previousCoord.coordinate.latitude = positionSource.position.coordinate.latitude
                previousCoord.coordinate.longitude = positionSource.position.coordinate.longitude
                return Reittiopas.get_reverse_geocode(previousCoord.coordinate.latitude.toString(),
                                                      previousCoord.coordinate.longitude.toString(),
                                                            Storage.getSetting('api'))
            } else {
                /* poll again in 200ms */
                gpsTimer.start()
            }
        } else {
            return false
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: Qt.application.active
        onPositionChanged: {
            /* if we have moved >250 meters from the previous place, update current location */
            if(previousCoord.coordinate.latitude != 0 &&
                    previousCoord.coordinate.longitude != 0 &&
                    position.coordinate.distanceTo(previousCoord) > 250) {
                getCurrentCoord() ? gpsTimer.start() : currentLocationModel.source = getCurrentCoord()
            }
        }
    }

    XmlListModel {
        id: currentLocationModel
        query: "/response/node"
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "city"; query: "city/string()" }
        XmlRole { name: "coord"; query: "coords/string()" }
        XmlRole { name: "shortCode"; query: "shortCode/string()" }
        XmlRole { name: "housenumber"; query: "details/houseNumber/string()" }

        onStatusChanged: {
            if(status == XmlListModel.Ready && source != "") {
                /* if only result, take it into use */
                if(currentLocationModel.count > 0) {
                    updateCurrentLocation(currentLocationModel.get(0))
                }
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
            if(status == XmlListModel.Ready && source != "") {
                /* if only result, take it into use */
                if(suggestionModel.count == 1) {
                    positionBusy: false
                    updateLocation(suggestionModel.get(0))
                } else if (suggestionModel.count == 0) {
                    appWindow.useNotification( qsTr("No results") )
                } else {
                    /* just update the first result to main page */
                    isFavorite = Favorites.favoritExists(suggestionModel.get(0).coord)
                    locationDone(suggestionModel.get(0).name.split(',', 1).toString(),suggestionModel.get(0).coord)
                }
            } else if (status == XmlListModel.Error) {
                selected_favorite = -1
                isFavorite = false
                suggestionModel.source = ""
                locationDone("", 0, "")
                locationError()
                appWindow.useNotification( qsTr("Could not find location") )
            }
        }
    }

    ListModel {
        id: favoritesModel
    }

    ListModel {
        id: tempStorageModel
    }
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
    SpaceSeparator {
        id: label
    }

    BackgroundItem {
        id: firstRow
        width: parent.width
        height: textfield.height < (textfield.height/2 + textfield.height/1.5 +sourceLabel.height) ? (textfield.height/2 + textfield.height/1.5 +sourceLabel.height) : textfield.height
        onClicked: {
            var searchdialog = pageStack.push(Qt.resolvedUrl("../pages/SearchAddressPage.qml"))
            searchdialog.searchType = "source"
            searchdialog.accepted.connect(function() {
                updateLocation(searchdialog.selectObject)
            })
        }
        Label {
            id: textfield
            text: qsTr("Select")
            color: Theme.highlightColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade

            onTextChanged: {

            }
            Label {
                id: sourceLabel
                text: qsTr("Location")
                color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -parent.height/1.5
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeTiny
            }
        }
    }
    Item {
        id: secondRow
        width: parent.width
        height: gpsButton.height
        Label {
            id: gpsButtonLabel
            text: qsTr("GPS")
            color: gpsButton.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height - Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            font.pixelSize: Theme.fontSizeTiny
            x: Theme.horizontalPageMargin
        }
        IconButton {
            id: gpsButton
            icon.source: "image://theme/icon-m-gps"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            onClicked: {
                positionBusy: true
                if (positionValid(positionSource.position)) {
                    gpsLoading = true
                    var sourceOrFalse = getCurrentCoord()
                    if (sourceOrFalse){
                        suggestionModel.source = sourceOrFalse
                    } else {
                        positionBusy: false
                        appWindow.useNotification(qsTr("Positioning service not available"))
                    }
                }
                else {
                    positionBusy: false
                    appWindow.useNotification(qsTr("Positioning service not available"))
                }
            }
            StatusIndicatorCircle {
                id: statusIndicator
                radius: 5 * Theme.pixelRatio
                height: 10 * Theme.pixelRatio
                width: 10 * Theme.pixelRatio
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Label {
            text: qsTr("Favorite")
            color: favoritePicker.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: gpsButtonLabel.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeTiny
            x: Theme.horizontalPageMargin
        }
        IconButton {
            id: favoritePicker
            enabled: !disable_favorites
            visible: !disable_favorites
            icon.source: !isFavorite ? "image://theme/icon-m-favorite" : "image://theme/icon-m-favorite-selected"
            icon.height: gpsButton.icon.height
            anchors.top: gpsButton.top
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                var favoriteDialog = pageStack.push(Qt.resolvedUrl("../pages/FavoritesPage.qml"))
                favoriteDialog.query = true
                favoriteDialog.accepted.connect(function() {
                    favoritesUpdateLocation(favoriteDialog.selectedObject)
                })
            }
            onPressAndHold: {
                if(destination_coord) {
                    enabled: false
                    if(Favorites.favoritExists(destination_coord)){
                        Favorites.deleteFavorite(destination_coord, favoritesModel)
                        isFavorite = false
                        appWindow.useNotification( qsTr("Location removed from favorite places") )
                    } else if(("OK" === Favorites.addFavorite(destination_name, destinationObject.coord, destinationObject.city, destinationObject.locationType))) {
                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)
                        isFavorite = true
                        appWindow.useNotification( qsTr("Location added to favorite places") )
                    } else {
                        appWindow.useNotification( qsTr("Adding a location raised a database error") )
                    }

                }
                enabled: true
            }
        }
        Label {
            text: qsTr("Map")
            color: mapButton.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: gpsButtonLabel.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: parent.width/4
            font.pixelSize: Theme.fontSizeTiny
            x: Theme.horizontalPageMargin
        }
        IconButton {
            id: mapButton
            icon.source: "image://theme/icon-m-location"
            icon.height: gpsButton.icon.height
            anchors.top: gpsButton.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: parent.width/4
            onClicked: {
                onClicked: { var mapDialog = pageStack.push(Qt.resolvedUrl("../pages/LocationMapPage.qml"), {inputCoord:destination_coord,resultName:destination_name})
                    mapDialog.accepted.connect(function() {
                        updateLocation(mapDialog.resultObject)
                    })
                }
            }
        }
    }
}
