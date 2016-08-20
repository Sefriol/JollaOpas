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
import "../js/storage.js" as Storage
import "../js/helper.js" as Helper
import "../js/favorites.js" as Favorites
import "../components"

Page {
    id: mainPage
    /* Current location acquired with GPS */
    property string currentCoord: ''
    property string currentName: ''

    /* Values entered in "To" field */
    property string toCoord: ''
    property string toName: ''

    /* Values entered in "From" field */
    property string fromCoord: ''
    property string fromName: ''
    property bool searchButtonDisabled: false

    property bool endpointsValid: (toCoord.length > 0 && (fromCoord.length > 0 || currentCoord.length > 0))

    property date myTime

    onEndpointsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting_route" && endpointsValid) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            appWindow.coverAlignment = Text.AlignHCenter
            appWindow.coverHeader = 'JollaOpas'
            appWindow.coverContents = appWindow.currentApi.charAt(0).toUpperCase() + appWindow.currentApi.slice(1)

            searchButtonDisabled = Storage.getSetting("search_button_disabled") == "true" ? true : false

            // Prevent the keyboard to popup instantly when swithcing back to mainPage
            mainPage.forceActiveFocus()
        }
    }

    function refreshFavoriteRoutes() {
            favoriteRoutesModel.clear()
            Favorites.getFavoriteRoutes('normal', appWindow.currentApi, favoriteRoutesModel)
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        content_column.setTimeNow()

        /* Update new destination to "to" */
        to.updateLocation(name, 0, coord)

        /* Remove user input location and use gps location */
        from.clear()

        /* use current location if available - otherwise wait for it */
        if(currentCoord != "") {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
        else {
            state = "waiting_route"
        }
    }

    Component.onCompleted: {
        content_column.setTimeNow()
        appWindow.currentApi = Storage.getSetting("api")
        refreshFavoriteRoutes()
    }

    states: [
        State {
            name: "normal"
        },
        State {
            name: "waiting_route"
        }
    ]

    state: "normal"

    function setRouteParameters(parameters) {
        var walking_speed = Storage.getSetting("walking_speed")
        var optimize = Storage.getSetting("optimize")
        var change_margin = Storage.getSetting("change_margin")
        var currentDate = new Date()

        parameters.from_name = fromName ? fromName : currentName
        parameters.from = fromCoord ? fromCoord : currentCoord
        parameters.to_name = toName
        parameters.to = toCoord
        parameters.time = myTime

        parameters.timetype = timeTypeSwitch.departure ? "departure" : "arrival"
        parameters.walk_speed = walking_speed == "Unknown"?"70":walking_speed
        parameters.optimize = optimize == "Unknown"?"default":optimize
        parameters.change_margin = change_margin == "Unknown"?"3":Math.floor(change_margin)

        if (appWindow.currentApi === "helsinki") {
            if(Storage.getSetting("train_disabled") === "true")
                parameters.mode_cost_12 = -1 // commuter trains
            if(Storage.getSetting("bus_disabled") === "true") {
                parameters.mode_cost_1 = -1 // Helsinki internal bus lines
                parameters.mode_cost_3 = -1 // Espoo internal bus lines
                parameters.mode_cost_4 = -1 // Vantaa internal bus lines
                parameters.mode_cost_5 = -1 // regional bus lines
                parameters.mode_cost_22 = -1 // Helsinki night buses
                parameters.mode_cost_25 = -1 // region night buses
                parameters.mode_cost_36 = -1 // Kirkkonummi internal bus lines
                parameters.mode_cost_39 = -1 // Kerava internal bus lines
            }
            if(Storage.getSetting("uline_disabled") === "true")
                parameters.mode_cost_8 = -1 // U-lines
            if(Storage.getSetting("service_disabled") === "true") {
                parameters.mode_cost_21 = -1 // Helsinki service lines
                parameters.mode_cost_23 = -1 // Espoo service lines
                parameters.mode_cost_24 = -1 // Vantaa service lines
            }
            if(Storage.getSetting("metro_disabled") === "true")
                parameters.mode_cost_6 = -1 // metro
            if(Storage.getSetting("tram_disabled") === "true")
                parameters.mode_cost_2 = -1 // trams
        }
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: mainPage.state == "normal" ? 0.0 : 0.7

        Behavior on opacity {
            PropertyAnimation { duration: 200 }
        }

        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state != "normal"
            onClicked: mainPage.state = "normal"
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: 260
        running: mainPage.state != "normal"
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }
    CustomBottomDrawer {
        id: drawer
        anchors.fill: parent
        Component.onCompleted: startPoint = drawerheaderitem.y - ((Screen.height > 960) ? 0 : drawerheaderitem.height)
        background: SilicaListView {
            id: favoriteRouteList
            anchors.fill: parent
            width: parent.width
            model: favoriteRoutesModel
            delegate: BackgroundItem {
                id: rootItemDelegate
                enabled: drawer.open
                width: ListView.view.width
                height: menuOpen ? Theme.itemSizeSmall + favoriteRouteList.contextMenu.height : Theme.itemSizeSmall

                property bool menuOpen: favoriteRouteList.contextMenu != null && favoriteRouteList.contextMenu.parent === rootItemDelegate

                function addToCover() {
                    Favorites.addFavoriteRoute('cover', appWindow.currentApi, modelFromCoord, modelFromName, modelToCoord, modelToName)
                    appWindow.useNotification( qsTr("Favorite route added to cover action.") )
                }

                function remove() {
                    remorse.execute(rootItemDelegate, qsTr("Deleting"), function() {
                        Favorites.deleteFavoriteRoute(modelRouteIndex, appWindow.currentApi, favoriteRoutesModel)
                    })
                }

                onClicked:{
                    var parameters = {}
                    setRouteParameters(parameters)
                    parameters.from_name = modelFromName
                    parameters.from = modelFromCoord
                    parameters.to_name = modelToName
                    parameters.to = modelToCoord
                    drawer.open = false
                    pageStack.pushAttached(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                    pageStack.navigateForward()
                }

                onPressAndHold: {
                    if (!favoriteRouteList.contextMenu) {
                        favoriteRouteList.contextMenu = contextMenuComponent.createObject(favoriteRouteList)
                    }

                    favoriteRouteList.contextMenu.currentItem = rootItemDelegate
                    favoriteRouteList.contextMenu.show(rootItemDelegate)
                }
                Label {
                    id: label
                    text: modelFromName + " - " + modelToName + " "
                    height: Theme.itemSizeSmall
                    width: parent.width - reverseFavoriteRouteButton.width
                    color: Theme.primaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                IconButton {
                    id: reverseFavoriteRouteButton
                    anchors.right: parent.right
                    icon.source: "image://theme/icon-m-shuffle"
                    onClicked:{
                        var parameters = {}
                        setRouteParameters(parameters)
                        parameters.from_name = modelToName
                        parameters.from = modelToCoord
                        parameters.to_name = modelFromName
                        parameters.to = modelFromCoord
                        pageStack.pushAttached(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                        pageStack.navigateForward()
                    }
                }
                RemorseItem { id: remorse }
            }
            property Item contextMenu

            ViewPlaceholder {
                enabled: favoriteRouteList.count == 0
                // Not perfect, but shows the text on Jolla Phone, Jolla Tablet and Fairphone2 (was -300)
                verticalOffset: (favoriteRouteList.height - mainPage.height) * 0.5
                text: qsTr("No saved favorite routes")
            }
            Label {
                text: qsTr("Press to expand")
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                visible: !drawer.open
            }
            Item {
                id: headeritem
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                height: (favoriteRouteHeader.height + Theme.fontSizeSmall) * Theme.pixelRatio
                SpaceSeparator {
                    id: favoriteRouteHeader
                    type: qsTr("Favourites")
                }
            }
            MouseArea {
                enabled: !drawer.open
                anchors.fill: favoriteRouteList
                onClicked: drawer.open = favoriteRouteList.count == 0 ? false : true
            }
            VerticalScrollDecorator {}
            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: menu
                    property Item currentItem
                    MenuItem {
                        text: qsTr("Add to Cover")
                        onClicked: menu.currentItem.addToCover()
                    }

                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: menu.currentItem.remove()
                    }
                }
            }
        }
        SilicaFlickable {
            id: formContainer
            anchors.fill: parent
            contentHeight: parent.height

            PullDownMenu {
                enabled: !drawer.open
                MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
                MenuItem { text: qsTr("Exception info"); visible: appWindow.currentApi === "helsinki"; onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
                MenuItem {
                    enabled: endpointsValid
                    text: qsTr("Add as favorite route");
                    onClicked: {
                        var fromNameToAdd = fromName ? fromName : currentName
                        var fromCoordToAdd = fromCoord ? fromCoord : currentCoord
                        var res = Favorites.addFavoriteRoute('normal', appWindow.currentApi, fromCoordToAdd, fromNameToAdd, toCoord, toName, favoriteRoutesModel)
                        if (res === "OK") {
                            appWindow.useNotification( qsTr("Favorite route added") )
                        }
                    }
                }
                MenuItem {text: qsTr("Get return route"); onClicked: {Helper.switch_locations(from,to)}}
                //MenuItem {text: qsTr("Check Schema"); onClicked: {Favorites.checkSchema(Favorites.getDatabase(),"favorites")}}
                MenuItem {
                    visible: searchButtonDisabled
                    enabled: endpointsValid
                    text: qsTr("Search");
                    onClicked: {
                        var parameters = {}
                        setRouteParameters(parameters)
                        pageStack.pushAttached(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                        pageStack.navigateForward()
                    }
                }
            }

            Spacing { id: topSpacing; anchors.top: parent.top; height: (Theme.fontSizeSmall + 5) * Theme.pixelRatio }
            MouseArea {
                enabled: drawer.open
                anchors.fill: content_column
                onClicked: drawer.open = false
            }
            Column {
                id: content_column
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: topSpacing.bottom
                enabled: !drawer.opened

                property bool dateNow
                property bool customDate
                function setTimeNow() {
                    myTime = new Date()
                    timeSwitch.storedDate = myTime
                    dateSwitch.storedDate = myTime
                    customDate = dateSwitch.customDate = false
                    dateNow = dateSwitch.dateToday = true
                }
                Item {
                    width: parent.width
                    height: from.height + to.height
                    LocationEntry {
                        id: from
                        type: qsTr("From")
                        isFrom: true
                        onLocationDone: {
                            fromName = name
                            fromCoord = coord
                        }
                        onCurrentLocationDone: {
                            currentName = name
                            currentCoord = coord
                        }
                        onLocationError: {
                            /* error in getting current position, cancel the wait */
                            mainPage.state = "normal"
                        }
                    }

                    Spacing { id: location_spacing; anchors.top: from.bottom; height: 5 }

                    LocationEntry {
                        id: to
                        type: qsTr("To")
                        onLocationDone: {
                            toName = name
                            toCoord = coord
                        }
                        anchors.top: location_spacing.bottom
                    }

                }
                Spacing { id: when_spacing; height: 10 }
                SpaceSeparator {
                    type: qsTr("When")
                }

                TimeTypeSwitch {
                    id: timeTypeSwitch
                }
                TimeSwitch {
                    id: timeSwitch
                    onStoredDateChanged: {
                        myTime = dateSwitch.storedDate = timeSwitch.storedDate
                    }
                }
                DateSwitch {
                    id: dateSwitch
                    dateToday: dateNow
                    onHandleSwitchesCheckedState: {
                        content_column.dateNow = dateSwitch.dateToday = dateNow
                        content_column.customDate = dateSwitch.customDate = customDate
                    }
                    onStoredDateChanged: {
                        myTime = timeSwitch.storedDate = dateSwitch.storedDate
                    }
                }

                Button {
                    visible: !searchButtonDisabled
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: endpointsValid
                    text: qsTr("Search")
                    onClicked: {
                        var parameters = {}
                        setRouteParameters(parameters)
                        pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                    }
                }
            }

            Spacing { id: favorites_spacing; anchors.top: content_column.bottom; height: (Theme.fontSizeSmall + 5) * Theme.pixelRatio }


            Item {
                id: drawerheaderitem
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: favorites_spacing.bottom
                height: (favoriteRouteHeader.height + Theme.fontSizeSmall) * Theme.pixelRatio
                Label {
                    text: qsTr("Favourites")
                    color: Theme.highlightColor
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: Text.AlignRight
                }
            }
            ListModel {
                id: favoriteRoutesModel
            }
        }
    }
}
