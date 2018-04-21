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
import "../../js/UIConstants.js" as UIConstants
import "../../js/storage.js" as Storage
import "../../js/favorites.js" as Favorites
import "../../js/helper.js" as Helper
import "./components"
import "../../components"
import "../"

CoverBackground {
    id: appCover
    states: [
        State {
            name: "empty"
            when: routeModel.count === 0
        },
        State {
            name: "active"
            when: routeModel.count > 0 && coverView.currentIndex != -1
            PropertyChanges {target: routeDataColumn; visible: true }
            PropertyChanges {target: defaultCoverActions; enabled: false }
            PropertyChanges {target: routeCoverAction; enabled: true }
            PropertyChanges {target: differenceTimer; running: true }
            PropertyChanges {target: lineImage; source: "qrc:/images/" + routeModel.get(coverView.currentIndex).type + ".png"}
            PropertyChanges {target: lineNumber; text: routeModel.get(coverView.currentIndex).code? routeModel.get(coverView.currentIndex).code : routeModel.get(coverView.currentIndex).length + " km"}
        }
    ]
    Column {
        id: routeDataColumn
        width: parent.width-12
        anchors.left: appCover.left
        anchors.leftMargin: 6
        spacing: 0
        visible: false

        Row {
            id: routeIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                color: Theme.secondaryColor
                border.color: Theme.primaryColor
                border.width: 1
                opacity:0.2

                radius: 5
                smooth: true

                height: indicatorRepeater.height
                width: indicatorRepeater.width

                anchors {
                    verticalCenter: routeIndicator.verticalCenter
                }
            }
            Repeater {
                id:indicatorRepeater
                model:routeModel
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: Rectangle {
                    anchors {
                        verticalCenter: routeIndicator.verticalCenter
                    }
                    height: routeIcon.height
                    width: routeIcon.width
                    color: "transparent"
                    Rectangle {
                        color: Theme.secondaryColor
                        border.color: Theme.primaryColor
                        border.width: 1
                        opacity:(coverView.currentIndex == index ? 1 : 0.2)

                        radius: 5
                        smooth: true

                        height: routeIcon.height
                        width: routeIcon.width

                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Image {
                        id: routeIcon
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        height: coverView.count > 5 ? 240/coverView.count : 48
                        source: type !== "logo" ? "qrc:/images/" + type + ".png" : "qrc:logo" // fix this later "qrc:images/"+ size + "/" + type +  ".png"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Rectangle {
            id: routeWindow
            clip: true  // this is needed so that only one leg is shown in the cover
            width: parent.width

            height: 130
            color: "transparent"

            ListView {
                id: coverView
                model: routeModel
                width: parent.width
                interactive: false

                onCurrentIndexChanged: {
                    clockTick()
                    updateLineImage(coverView.currentIndex)
                }

                anchors.left: parent.left
                anchors.top: parent.top

                delegate: Column {
                    id: waypointColumn
                    width: appCover.width
                    Row {
                        width: parent.width
                        spacing: 10
                        CoverTime {
                            schedTime: Helper.prettyTime(routeModel.get(index).time)
                            realTime: appWindow.routeModel.get(index).time
                            realTimeAcc: "min"
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Label {
                        id: stopName
                        text: routeModel.get(index).name
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        Row {
            width: parent.width
            Image {
                id: lineImage
                fillMode: Image.PreserveAspectFit
                smooth: true
                width: parent.width * 1/3
                anchors.verticalCenter: lineNumber.verticalCenter
                anchors.verticalCenterOffset: timeLeftLabel.height/2
            }
            Label {
                id: lineNumber
                width: parent.width * 2/3
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                Label {
                    id: timeLeftLabel
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignHCenter
                    anchors.top: lineNumber.bottom
                    anchors.horizontalCenter: lineNumber.horizontalCenter
                }
            }
        }

    }
    CoverActionList {
        id: defaultCoverActions
        enabled: true
        CoverAction {
            iconSource: "image://theme/icon-cover-favorite"
            onTriggered: {
                startCoverSearch("straight")
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-shuffle"
            onTriggered: {
                startCoverSearch("reverse")
            }
        }
    }
    CoverActionList {
        id: routeCoverAction
        enabled: false
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                coverView.currentIndex >= coverView.count - 1 ? coverView.currentIndex = 0 : coverView.incrementCurrentIndex()
            }
        }
    }
    Timer {
        id: differenceTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            clockTick()
        }
    }
    // update the clocks on the cover
    signal clockTick()
    onClockTick: {
        var model = routeModel.get(coverView.currentIndex)
        if(!model) return
        var stopTime = model.time
        timeLeftLabel.text = Helper.prettyTimeFromSeconds(Helper.timestampDifferenceInSeconds(null, stopTime))
    }

    signal updateLineImage(int index)
    onUpdateLineImage: {
        var model = routeModel.get(index)
        lineImage.source = "qrc:/images/" + model.type + ".png"
        lineNumber.text = model.code ? model.code : model.length + " km"
    }
    function startCoverSearch(direction) {
        pageStack.clear()
        appWindow.activate()
        var coverRoutesItem = []
        var res = Favorites.getFavoriteRoutes('cover', Storage.getSetting("api"), coverRoutesItem)
        if (res == "Unknown") {
            appWindow.mainPage = pageStack.push(Qt.resolvedUrl("../main/MainPage.qml"))
            appWindow.useNotification( qsTr("Please save a route and add it to cover action by long-press.") )
        }
        else {
            var parameters = {}
            var walking_speed = Storage.getSetting("walking_speed")
            var optimize = Storage.getSetting("optimize")
            var change_margin = Storage.getSetting("change_margin")

            parameters.from_name = direction == "straight" ? coverRoutesItem.modelFromName : coverRoutesItem.modelToName
            parameters.from = direction == "straight" ? coverRoutesItem.modelFromCoord : coverRoutesItem.modelToCoord
            parameters.to_name = direction == "straight" ? coverRoutesItem.modelToName : coverRoutesItem.modelFromName
            parameters.to = direction == "straight" ? coverRoutesItem.modelToCoord : coverRoutesItem.modelFromCoord

            parameters.time = new Date()
            parameters.timetype = "departure"
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
            appWindow.mainPage = pageStack.push(Qt.resolvedUrl("../main/MainPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("../result/ResultPage.qml"), { search_parameters: parameters })
        }
    }
}
