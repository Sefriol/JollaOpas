/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 2.1
import QtPositioning 5.0
import Sailfish.Silica 1.0
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "theme.js" as Theme

Page {
    id: stop_page
    property string leg_code: ""
    property int leg_index: 0
    property alias position: position

    state: (appWindow.mapVisible && appWindow.inPortrait)? "map" : "normal"

    onStateChanged: {
        if(state == "map") {
            map_loader.sourceComponent = map_component
        }
    }

    onStatusChanged: {
        if(status == Component.Ready && !stopModel.count) {
            var route = Reittiopas.get_route_instance()
            route.dump_stops(leg_index, stopModel)
            if(appWindow.mapVisible)
                map_loader.sourceComponent = map_component
        }
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
        active: appWindow.gpsEnabled
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
            title: leg_code ? qsTr("Stops for line ") + leg_code : qsTr("Walking route")
        }
    }

    Rectangle {
        id: map
        property alias map_loader : map_loader
        anchors.top: routeList.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height/2 + UIConstants.DEFAULT_MARGIN
        width: parent.width + UIConstants.DEFAULT_MARGIN * 2
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        ListModel {
            id: mapTypeModel
//            ListElement { name: "Street"; value: Map.MobileStreetMap }
//            ListElement { name: "Satellite"; value: Map.SatelliteMapDay }
//            ListElement { name: "Hybrid"; value: Map.MobileHybridMap }
//            ListElement { name: "Terrain"; value: Map.MobileTerrainMap }
//            ListElement { name: "Transit"; value: Map.MobileTransitMap }
        }
/*
// TODO:
        SelectionDialog {
            id: mapTypeSelection
            model: mapTypeModel
            delegate: SelectionDialogDelegate {}
            selectedIndex: 0
            titleText: qsTr("Map type")
            onAccepted: {
                map_loader.item.flickable_map.map.mapType = mapTypeModel.get(selectedIndex).value
            }
        }
*/
        Column {
            anchors.left: parent.left
            anchors.leftMargin: UIConstants.DEFAULT_MARGIN * appWindow.scalingFactor
            anchors.verticalCenter: parent.verticalCenter
            width: followMode.width + UIConstants.DEFAULT_MARGIN * 2
            spacing: UIConstants.DEFAULT_MARGIN
            z: 500
/*
            MapButton {
                id: mapMode
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/images/maptype.png"
                z: 500
                mouseArea.onClicked: {
                    mapTypeSelection.open()
                }
            }
            MapButton {
                id: followMode
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/images/current.png"
                z: 500
                selected: appWindow.followMode
                mouseArea.onClicked: {
                    appWindow.followMode = appWindow.followMode? false : true
                }
            }
*/
        }
        Loader {
            id: map_loader
            anchors.fill: parent
            onLoaded: {
                map_loader.item.initialize()

                // go to first stop
                map.map_loader.item.flickable_map.panToLatLong(stopModel.get(0).latitude,
                                                               stopModel.get(0).longitude)
            }
        }
    }
/*
    Component {
        id: map_component
        MapElement {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
        }
    }
*/
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
