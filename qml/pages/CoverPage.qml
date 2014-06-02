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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/UIConstants.js" as UIConstants
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites

CoverBackground {
    Label {
        id: label
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: UIConstants.DEFAULT_MARGIN / 2
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: appWindow.coverLine1 + "\n" + appWindow.coverLine2 + "\n" + appWindow.coverLine3 + "\n" + appWindow.coverLine4 + "\n" + appWindow.coverLine5 + "\n" + appWindow.coverLine6
        wrapMode: Text.WordWrap
    }

    CoverActionList {
        id: coverAction

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

    function startCoverSearch(direction) {
        pageStack.clear()
        appWindow.activate()
        var coverRoutesItem = []
        var res = Favorites.getFavoriteRoutes('cover', Storage.getSetting("api"), coverRoutesItem)
        if (res == "Unknown") {
            var page = pageStack.push(Qt.resolvedUrl("MainPage.qml"))
            page.displayPopupMessage( qsTr("Please save a route and add it to cover action by long-press.") )
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

            pageStack.push(Qt.resolvedUrl("MainPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
    }
}
