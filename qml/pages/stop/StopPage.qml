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
import Sailfish.Silica 1.0
import "qrc:/UIConstants.js" as UIConstants
import "qrc:/reittiopas.js" as Reittiopas
import "./components"
import "../../components"

Page {
    id: stop_page
    property string leg_code: ""
    property int leg_index: 0
    property alias position: position
    backNavigation: !appWindow.mapVisible ? true : appWindow.followMode ? true : false
    state: appWindow.mapVisible ? "map" : "normal"

    onStateChanged: {
        if(state == "map") {
            map_loader.sourceComponent = map_component
        }
    }

    Component.onCompleted: {
        var route = Reittiopas.get_route_instance()
        route.dump_stops(leg_index, stopModel)

        if(appWindow.mapVisible)
            map_loader.sourceComponent = map_component
    }

/*
// TODO:
    ToolBarLayout {
        id: stopTools
        ToolIcon { iconId: "toolbar-back"; onClicked: {
                menu.close()
                appWindow.mapVisible = false
                pageStack.pop()
            }
        }
        ToolButtonRow {
            ToolButton {
                id: mapButton
                text: qsTr("Map")
                checkable: true
                onClicked: {
                    appWindow.mapVisible = appWindow.mapVisible? false : true
                }
                Binding { target: mapButton; property: "checked"; value: appWindow.mapVisible }
            }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (menu.status == DialogStatus.Closed) ? menu.open() : menu.close()
        }
    }
*/
    PositionSource {
        id: position
        updateInterval: 500
        active: Qt.application.active
    }

    ListModel {
        id: stopModel
        property bool done: false // used by reittiopas.js
    }

    SilicaListView {
        id: routeList
        clip: true
        anchors.top: parent.top
        height: parent.height/2 // TODO:
        width: parent.width
        model: stopModel
        // TODO: I have no idea what is going on but I really cannot understand why currentIndex
        // is not working :/
        property int currentStop: -1
        delegate: StopDelegate {
            highlight: routeList.currentStop == index
            onNear: {
                routeList.currentStop = index
            }
        }

        interactive: !busyIndicator.running
        highlightFollowsCurrentItem: true
        currentIndex: -1
        header: PageHeader {
            title: leg_code ? qsTr("Stops for line") + " " + leg_code : qsTr("Walking route")
        }
        VerticalScrollDecorator {}
    }

    Rectangle {
        id: map
        property alias map_loader : map_loader
        anchors.top: routeList.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height/2
        width: parent.width
        color: Theme.secondaryColor

        Loader {
            id: map_loader
            anchors.fill: parent
            onLoaded: {
                map_loader.item.initialize(false)

                // go to first stop
                map.map_loader.item.flickable_map.panToLatLong(stopModel.get(0).latitude,
                                                               stopModel.get(0).longitude)
            }
        }
    }

    Component {
        id: map_component
        MapElement {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
            MapButton {
                anchors.top: parent.top
                anchors.right: parent.right
                source: "image://theme/icon-m-close"
                onClicked: {
                    appWindow.mapVisible = false
                }
            }
        }
    }

    states: [
        State {
            name: "map"
            PropertyChanges { target: map; opacity: 1.0 }
            PropertyChanges { target: routeList; height: parent.height/2 }
        },
        State {
            name: "normal"
            PropertyChanges { target: map; opacity: 0.0 }
            PropertyChanges { target: routeList; height: parent.height }
        }
    ]
    transitions: Transition {
        NumberAnimation { properties: "height"; duration: 500; easing.type: Easing.OutCubic }
        NumberAnimation { properties: "opacity"; duration: 500; }
    }

    BusyIndicator {
        id: busyIndicator
        running: !stopModel.done
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}
