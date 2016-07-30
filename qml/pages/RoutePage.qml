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
import "../js/reittiopas.js" as Reittiopas
import "../components"

Page {
    property int route_index
    property string from_name
    property string to_name
    property string header
    property string duration
    property string walking
    property string start_time
    property string finish_time
    property string routeDetails: ""

    Component.onCompleted: {
        var route = Reittiopas.get_route_instance()
        route.dump_legs(route_index, routeModel)
        from_name = route.from_name
        to_name = route.to_name
    }

    ListModel {
        id: routeModel
        property bool done: false

        // Parse routeDetails for cover and clipboard usage,
        // could possibly be done in reittiopas.js when parsing json data
        onDoneChanged: {
            if (done) {
                for (var i = 0; i < routeModel.count; ++i) {
                    var leg = routeModel.get(i)
                    var type = leg.type
                    if (type === 'station') {
                        var shortCodeText = typeof(leg.shortCode) === "undefined" ? "" : "(" + leg.shortCode + ")"
                        routeDetails += (Qt.formatTime(leg.time, "hh:mm") + " " + leg.name + shortCodeText + "\n")
                    }
                    else if (type === 'walk') {
                        routeDetails += (qsTr("Walking") + ", " + Math.floor(leg.length/100)/10 + " " + qsTr("km") + "\n")
                    }
                    else {
                        if (type === 'bus')
                            routeDetails += qsTr("Bus")
                        else if (type === 'train')
                            routeDetails += qsTr("Train")
                        else if (type === 'metro')
                            routeDetails += qsTr("Metro")
                        else if (type === 'ferry')
                            routeDetails += qsTr("Ferry")
                        else if (type === 'tram')
                            routeDetails += qsTr("Tram")
                        else
                            routeDetails += ""
                        routeDetails += (" " + leg.code + ", " + leg.duration + " " + qsTr("min") + "\n")
                    }
                }
                appWindow.coverAlignment = Text.AlignLeft
                appWindow.coverHeader = start_time.slice(11,16) + " - " + finish_time.slice(11,16)
                appWindow.coverContents = routeDetails
            }
        }
    }

    Component {
        id: delegate
        Loader {
            width: parent.width
            source: type == "station" ?  "../components/RouteStationDelegate.qml" : "../components/RouteDelegate.qml"
        }
    }

    SilicaListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: delegate
        interactive: !busyIndicator.visible

        VerticalScrollDecorator {}

        header: Column {
            width: parent.width
            PageHeader {
                title: qsTr("%1 minutes").arg(duration)
            }

            Label {
                width: parent.width
                text: qsTr("Walking %1 km").arg(walking)
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingSmall
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: header
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingSmall
                wrapMode: Text.WordWrap
            }
        }

        ViewPlaceholder {
            enabled: (!busyIndicator.visible && routeModel.count == 0)
            text: qsTr("No results")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy details to Clipboard")
                onClicked: {
                    Clipboard.text = routeDetails
                    appWindow.useNotification( qsTr("Route details copied to Clipboard") )
                }
            }
            MenuItem {
                text: qsTr("Map")
                onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    // Added InfoBanner here as a workaround to display it correctly above all other UI elements, fixing the z-order from the one in main.qml isn't trivial
//    InfoBanner {
//        id: infoBanner
//        z: 1
//    }
//    function appWindow.useNotification((message) {
//        infoBanner.displayError(message)
//    }
}
