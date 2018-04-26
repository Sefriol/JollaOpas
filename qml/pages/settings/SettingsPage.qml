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
import "qrc:/UIConstants.js" as UIConstants
import "qrc:/storage.js" as Storage
import "qrc:/theme.js" as Theme
import "./components"
import "../../components"

Page {
    SilicaFlickable {
        id: settingsContent
        anchors.fill: parent
        contentHeight: content_column.height

        VerticalScrollDecorator {}

        Component.onCompleted: {
            Storage.initialize()
            var setting = Storage.getSetting("api")
            currentApi.set_value(setting == "Unknown"?"helsinki" : setting)
            setting = Storage.getSetting("tram_disabled")
            tramSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("bus_disabled")
            busSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("uline_disabled")
            ulineSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("service_disabled")
            serviceSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("metro_disabled")
            metroSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("train_disabled")
            trainSwitch.set_value(setting == "Unknown"?"false" : setting)
            setting = Storage.getSetting("optimize")
            optimizeRoute.set_value(setting == "Unknown"?"default" : setting)
            setting = Storage.getSetting("walking_speed")
            walkingSpeed.set_value(setting == "Unknown"?"70" : setting)
            setting = Storage.getSetting("change_margin")
            changeMargin.set_value(setting == "Unknown"?"3" : Math.floor(setting))
            setting = Storage.getSetting("default_zoom_level")
            defaultZoomLevel.set_value(setting == "Unknown"?"5" : Math.floor(setting))
            setting = Storage.getSetting("search_button_disabled")
            searchButtonSwitch.set_value(setting == "Unknown"?"false" : setting)
        }

        PullDownMenu {
            MenuItem { text: qsTr("About"); onClicked: pageStack.push(Qt.resolvedUrl("../dialogs/AboutDialog.qml")) }
            MenuItem { text: qsTr("Manage favorite places"); onClicked: pageStack.push(Qt.resolvedUrl("../favorites/FavoritesPage.qml"))}
        }

        Column {
            id: content_column
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Region")
            }

            ComboBox {
                id: currentApi
                function set_value(value) {
                    var val = {"helsinki": 0, "tampere": 1}[value]
                    currentApi.currentIndex = val
                }

                label: qsTr("Active Region")
                menu: ContextMenu {
                    MenuItem {
                        text: "Helsinki"
                        onClicked: {
                            Storage.setSetting("api","helsinki")
                            appWindow.currentApi = "helsinki"
                            appWindow.coverContents = text
                            appWindow.mainPage.refreshFavoriteRoutes()
                        }
                    }
                    MenuItem {
                       text: "Tampere"
                        onClicked: {
                            Storage.setSetting("api","tampere")
                            appWindow.currentApi = "tampere"
                            appWindow.coverContents = text
                            appWindow.mainPage.refreshFavoriteRoutes()
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Route search parameters")
            }
            TextSwitch {
                id: busSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (busSwitch.checked)
                        busSwitch.description = qsTr("Route results will contain Buses")
                    else
                        busSwitch.description = qsTr("Route results will not contain Buses")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    busSwitch.checked = val
                    busSwitch.updateDescription()
                }
                text: qsTr("Bus")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("bus_disabled", (!checked).toString())
                    busSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: ulineSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (ulineSwitch.checked)
                        ulineSwitch.description = qsTr("Route results will contain U lines")
                    else
                        ulineSwitch.description = qsTr("Route results will not contain U lines")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    ulineSwitch.checked = val
                    ulineSwitch.updateDescription()
                }
                text: qsTr("U line")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("uline_disabled", (!checked).toString())
                    ulineSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: serviceSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (serviceSwitch.checked)
                        serviceSwitch.description = qsTr("Route results will contain Service lines")
                    else
                        serviceSwitch.description = qsTr("Route results will not contain Service lines")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    serviceSwitch.checked = val
                    serviceSwitch.updateDescription()
                }
                text: qsTr("Service line")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("service_disabled", (!checked).toString())
                    serviceSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: tramSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (tramSwitch.checked)
                        tramSwitch.description = qsTr("Route results will contain Trams")
                    else
                        tramSwitch.description = qsTr("Route results will not contain Trams")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    tramSwitch.checked = val
                    tramSwitch.updateDescription()
                }
                text: qsTr("Tram")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("tram_disabled", (!checked).toString())
                    tramSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: metroSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (metroSwitch.checked)
                        metroSwitch.description = qsTr("Route results will contain Metro")
                    else
                        metroSwitch.description = qsTr("Route results will not contain Metro")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    metroSwitch.checked = val
                    metroSwitch.updateDescription()
                }
                text: qsTr("Metro")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("metro_disabled", (!checked).toString())
                    metroSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: trainSwitch
                visible: appWindow.currentApi === "helsinki"
                function updateDescription() {
                    if (trainSwitch.checked)
                        trainSwitch.description = qsTr("Route results will contain Trains")
                    else
                        trainSwitch.description = qsTr("Route results will not contain Trains")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    trainSwitch.checked = val
                    trainSwitch.updateDescription()
                }
                text: qsTr("Train")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("train_disabled", (!checked).toString())
                    trainSwitch.updateDescription()
                }
            }

            Slider {
                id: changeMargin
                function set_value(value) {
                    changeMargin.value = value
                    changeMargin.updateLabel()
                }
                function updateLabel() {
                    changeMargin.label = qsTr("Change Margin") + " (" + changeMargin.value + " " + qsTr("minutes") + ")"
                }
                width: parent.width
                minimumValue: 0
                maximumValue: 10
                value: 5
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("change_margin", changeMargin.value)
                    changeMargin.updateLabel()
                }
            }

            ComboBox {
                id: optimizeRoute
                function set_value(value) {
                    var idx = {"default": 0, "fastest": 1, "least_transfers": 2, "least_walking": 3}[value]
                    optimizeRoute.currentIndex = idx
                }

                label: qsTr("Optimize Route by")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Default")
                        onClicked: Storage.setSetting('optimize','default')
                    }
                    MenuItem {
                        text: qsTr("Fastest")
                        onClicked: Storage.setSetting('optimize','fastest')
                    }
                    MenuItem {
                        text: qsTr("Least Transfers")
                        onClicked: Storage.setSetting('optimize','least_transfers')
                    }
                    MenuItem {
                        text: qsTr("Least Walking")
                        onClicked: Storage.setSetting('optimize','least_walking')
                    }
                }
            }

            ComboBox {
                id: walkingSpeed
                function set_value(value) {
                    var idx = {"70": 0, "100": 1, "120": 2, "150": 3}[value]
                    walkingSpeed.currentIndex = idx
                }

                label: qsTr("Walking speed")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Walking 70 m/min")
                        onClicked: Storage.setSetting('walking_speed','70')
                    }
                    MenuItem {
                        text: qsTr("Fast Walking 100 m/min")
                        onClicked: Storage.setSetting('walking_speed','100')
                    }
                    MenuItem {
                        text: qsTr("Very Fast Walking 120 m/min")
                        onClicked: Storage.setSetting('walking_speed','120')
                    }
                    MenuItem {
                        text: qsTr("Running 150 m/min")
                        onClicked: Storage.setSetting('walking_speed','150')
                    }
                }
            }

            SectionHeader {
                text: qsTr("Map")
            }
            Slider {
                id: defaultZoomLevel
                function set_value(value) {
                    defaultZoomLevel.value = value
                    defaultZoomLevel.updateLabel()
                }
                function updateLabel() {
                    defaultZoomLevel.label = qsTr("Default zoom level") + " (" + defaultZoomLevel.value + ")"
                }
                width: parent.width
                minimumValue: 1
                maximumValue: 10
                value: 5
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("default_zoom_level", defaultZoomLevel.value)
                    defaultZoomLevel.updateLabel()
                }
            }

            SectionHeader {
                text: qsTr("UI tweaks")
            }
            TextSwitch {
                id: searchButtonSwitch
                function updateDescription() {
                    if (searchButtonSwitch.checked)
                        searchButtonSwitch.description = qsTr("Search button is located below parameters")
                    else
                        searchButtonSwitch.description = qsTr("Search button is located in the PullDown menu")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    searchButtonSwitch.checked = val
                    searchButtonSwitch.updateDescription()
                }
                text: qsTr("Search button")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("search_button_disabled", (!checked).toString())
                    searchButtonSwitch.updateDescription()
                }
            }
        }
    }
}
