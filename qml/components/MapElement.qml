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
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "../js/reittiopas.js" as Reittiopas
import "../js/sirilive.js" as Sirilive
import "../js/storage.js" as Storage
import "../js/UIConstants.js" as UIConstants
import "../js/helper.js" as Helper
import "../js/theme.js" as Theme

Item {
    id: map_element
    property bool positioningActive : true
    property alias flickable_map : flickable_map
    property bool findLocation: false
    property variant selectedCoord
    Connections {
        target: Qt.application
        onActiveChanged:
            if(Qt.application.active) { vehicleUpdateTimer.start() }
            else { vehicleUpdateTimer.stop() }
    }

    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }

    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }

    function first_station() {
        flickable_map.panToCoordinate(Helper.first_station())
    }

    function removeAll() {
        flickable_map.map.removeMapObject(root_group)
    }

    function receiveVehicleLocation() {
        Sirilive.new_live_instance(vehicleModel, Storage.getSetting('api'))

        var epochTime = vehicleModel.timeStamp

        if (!epochTime) {
            flickable_map.timeStamp.text = qsTr(" Backend error ")
            return
        }

        var timeDifference = Date.now() - epochTime
        timeDifference /= 1000  // Convert milliseconds to seconds

        if (timeDifference > 0 && timeDifference < 60) {
            flickable_map.timeStamp.text = qsTr(" Updated ") + Math.round(timeDifference) + qsTr(" s ago ")
        }
        else {
            var updatedDate = new Date(0)

            if (updatedDate.getTimezoneOffset() < 180) {
                var dayLightSavingTime = 0
                dayLightSavingTime = parseInt(epochTime)
                dayLightSavingTime += 3600000
                epochTime = dayLightSavingTime.toString()
            }

            updatedDate.setMilliseconds(epochTime)
            flickable_map.timeStamp.text =
                    qsTr(" Updated ") + Qt.formatDateTime(updatedDate, "d.M. hh:mm:ss ")
        }
    }

    ListModel {
        id: stationModel
    }

    ListModel {
        id: stationTextModel
    }

    ListModel {
        id: stopModel
    }

    ListModel {
        id: vehicleModel
        property bool done: false
        property string timeStamp: ""
        property var vehicleCodesToShowOnMap: []
    }

    Timer {
        id: vehicleUpdateTimer
        interval: 2000
        repeat: true
        onTriggered: {
            receiveVehicleLocation()
        }
    }

    FlickableMap {
        id: flickable_map
        property alias start_point: startPoint
        property alias end_point: endPoint
        property alias timeStamp: timeStamp

        anchors.fill: parent

        // TODO: ?
        MapItemView {
            id: stationView
            model: stationModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Image {
                    smooth: true
                    height: 30
                    width: 30
                    source: "qrc:/images/stop.png"
                }
                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 45
            }
        }

        // TODO: ?
        MapItemView {
            id: stationTextView
            model: stationTextModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Text {
                    // TODO: width and height?
                    font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                    text: name
                }
                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 48
            }
        }

        // This is the yellow squares representing stops
        MapItemView {
            id: stopView
            model: stopModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Image {
                    smooth: true
                    height: 20
                    width: 20
                    source: "qrc:/images/station.png"
                }

                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 45
            }
        }

        // This is the vehicles moving on map
        MapItemView {
            id: vehicleView
            model: vehicleModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(modelLatitude, modelLongitude)
                sourceItem:
                    Rectangle {
                    color: modelColor
                    radius: width * 0.5
                    border.color: 'black'
                    border.width: 2
                    width: 50
                    height: 50
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 20
                        font.bold: true
                        text: modelCode
                    }
                    Image {
                        source: "qrc:/images/bearing_indicator.png"
                        enabled: typeof modelBearing !== "undefined"
                        height: 10
                        width: 20
                        visible: (typeof modelBearing !== "undefined") && (modelBearing != 0)
                        x: 15; y: -7.5
                        transform: Rotation {
                            origin.x: 10; origin.y: 32.5;
                            angle: typeof modelBearing === "undefined" ? 0 : modelBearing
                        }
                    }
                }

                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 48
            }
        }

        // Trip start
        MapQuickItem {
            id: startPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/start.png"
                height: 50
                width: 50
            }

            anchorPoint.y: sourceItem.height - 5
            anchorPoint.x: sourceItem.width / 2
            z: 50
        }

        // Trip end
        MapQuickItem {
            id: endPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/finish.png"
                height: 50
                width: 50
            }

            anchorPoint.y: sourceItem.height - 5
            anchorPoint.x: sourceItem.width / 2
            z: 50
        }

        MapQuickItem {
            id: timeStamp
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            z: 100
            property alias text: timeStampText.text

            sourceItem:
                Rectangle {
                height: timeStampText.height
                width: timeStampText.width
                color: "grey"
                radius: 10
                opacity: 0.7
                Text {
                    id: timeStampText
                    anchors.centerIn: parent
                    font.bold: true
                    text: ""
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressAndHold:{
                if(map_element.findLocation){
                    var coord = flickable_map.screenToCoordinate(mouseX,mouseY)
                    selectedCoord = coord
                } else {
                    flickable_map.panToCoordinate(current_position.coordinate)
                }
            }
            onDoubleClicked: flickable_map.zoomLevel += 1
        }
    }

    // Route
    Component {
        id: polyline_component

        MapPolyline {
            line.width: 8 * appWindow.scalingFactor
            z: 30
            smooth: true
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 200
        active: Qt.application.active
        onPositionChanged: {
            if(appWindow.followMode) {
                flickable_map.panToCoordinate(current_position.coordinate)
            }
        }
    }

    Connections {
        target: appWindow
        onFollowModeEnabled: {
            flickable_map.panToCoordinate(positionSource.position.coordinate)
        }
    }

    Binding {
        target: current_position
        property: "coordinate"
        value: positionSource.position.coordinate
    }

    MapQuickItem {
        id: current_position
        sourceItem: Image {
            smooth: true
            source: "qrc:/images/position.png"
            width: 30
            height: 30
        }

        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid && positionSource.position.horizontalAccuracy > 0 && positionSource.position.horizontalAccuracy < 100
        anchorPoint.y: sourceItem.height / 2
        anchorPoint.x: sourceItem.width / 2
        z: 51

        Behavior on coordinate {
            CoordinateAnimation {
                duration: 500
                easing.type: Easing.Linear
            }
        }
    }

    Binding {
        target: press_position
        property: "coordinate"
        value: selectedCoord
    }

    MapQuickItem {
        id: press_position
        sourceItem: LocationCircle {
            id: statusIndicator
        }
        anchorPoint.y: sourceItem.height / 2
        anchorPoint.x: sourceItem.width / 2
        z: 51

        Behavior on coordinate {
            CoordinateAnimation {
                duration: 500
                easing.type: Easing.Linear
            }
        }
    }
//    MapGroup {
//        id: root_group
//    }

    Component {
        id: coord_component

        Location {
            id: coord
        }
    }

    Component {
        id: stop

        MapQuickItem {
            id: stop_circle
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/station.png"
                height: 20 * appWindow.scalingFactor
                width: 20 * appWindow.scalingFactor
            }
            anchorPoint.y: sourceItem.height / 2
            anchorPoint.x: sourceItem.width / 2
            z: 45
        }
    }
/*
    Component {
        id: endpoint
        MapQuickItem {
            sourceItem: Image {
                smooth: true
                height: 50 * appWindow.scalingFactor
                width: 50 * appWindow.scalingFactor
            }
            anchorPoint.y: sourceItem.height - 5
            anchorPoint.x: sourceItem.width / 2
            z: 50
        }
    }
*/
/*
    Component {
        id: group

        MapGroup {
            id: stop_group
            property alias station_text : station_text
            property alias station : station
            property alias route : route

            MapText {
                id: station_text
                smooth: true
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                offset.x: -(width/2)
                offset.y: 18
                z: 48
            }

            MapImage {
                id: station
                sourceItem: Image {
                    smooth: true
                    source: "qrc:/images/stop.png"
                    height: 30 * appWindow.scalingFactor
                    width: 30 * appWindow.scalingFactor
                }
// TODO:
//                offset.y: sourceItem.height / 2
//                offset.x: sourceItem.width / 2
                z: 45
            }
            MapPolyline {
                id: route
                smooth: true
                border.width: 8 * appWindow.scalingFactor
                z: 30
            }
        }
    }
*/
    function getLocationInitialize(coord, input){
        var array = coord.split(',')
        flickable_map.panToCoordinate(QtPositioning.coordinate(array[1],array[0]))
        flickable_map.addMapItem(press_position)
        //Helper.clear_objects()
    }

    function initialize(multipleRoutes) {
        flickable_map.addMapItem(current_position)

        vehicleUpdateTimer.start()

        Helper.clear_objects()
        var current_route = Reittiopas.get_route_instance()
        vehicleModel.vehicleCodesToShowOnMap = []

        // Add startPoint to the map
        add_station2(current_route.last_result[0].legs[0].from, current_route.last_result[0].legs[0].from.name)
        flickable_map.start_point.coordinate.longitude = current_route.last_result[0].legs[0].from.longitude
        flickable_map.start_point.coordinate.latitude = current_route.last_result[0].legs[0].from.latitude


        // Add all the routes and vehicles to the map, ResultMapPage shows content for all the 5 routes,
        // last 4 with thinner line
        if (multipleRoutes === true) {
            for (var result in current_route.last_result) {
                add_route_to_map(current_route.last_result[result], result)
            }
        }
        else {
            var index = current_route.get_current_route_index()
            // Passing index == 0 prints with normal line width
            add_route_to_map(current_route.last_result[index], 0)
        }

        // Add endPoint to the map
        add_station2(current_route.last_result[0].legs[current_route.last_result[0].legs.length - 1].to,
                     current_route.last_result[0].legs[current_route.last_result[0].legs.length - 1].to.name)
        flickable_map.end_point.coordinate.longitude =
                current_route.last_result[0].legs[current_route.last_result[0].legs.length - 1].to.longitude
        flickable_map.end_point.coordinate.latitude =
                current_route.last_result[0].legs[current_route.last_result[0].legs.length - 1].to.latitude
    }

    function add_route_to_map(route, index) {
        for (var leg in route.legs) {

            var paths = []
            add_station2(route.legs[leg].to,
                         route.legs[leg].to.name)

            for(var shapeindex in route.legs[leg].shape) {
                var shapedata = route.legs[leg].shape[shapeindex]
                paths.push({"longitude": shapedata.x, "latitude": shapedata.y})
            }

            var p = polyline_component.createObject(flickable_map)
            p.line.color =
                    Theme.theme['general'].TRANSPORT_COLORS[route.legs[leg].type]
            p.path = paths

            // Print all 4 later route options with thinner line
            if (index > 0) {
                p.line.width *= 0.5;
            }

            flickable_map.addMapItem(p)

            if (route.legs[leg].type !== "walk") {
                vehicleModel.vehicleCodesToShowOnMap.push(
                            {"type": route.legs[leg].type,
                                "code": route.legs[leg].code})
            }
            if(route.legs[leg].type !== "walk") {
                for(var stopindex in route.legs[leg].locs) {
                    var loc = route.legs[leg].locs[stopindex]

                    if(stopindex !== 0 && stopindex !== route.legs[leg].locs.length - 1)
                        add_stop2(loc.latitude, loc.longitude)
                }
            }
        }
    }

    function add_station2(coord, name) {
        if (name != "") {
            // Append to name model
            stationModel.append({"lng": coord.longitude, "lat": coord.latitude, "name": name})
        }

        // Add the normal point for the station
        stationModel.append({"lng": coord.longitude, "lat": coord.latitude})
        Helper.add_station(coord)
    }

    function add_station(coord, name, map_group) {
        map_group.station_text.coordinate = coord
        map_group.station_text.text = name?name:""
        map_group.station.coordinate = coord

        Helper.add_station(coord)
    }

    function add_stop2(latitude, longitude) {
        stopModel.append({"lng": longitude, "lat": latitude})
    }

    function add_stop(latitude, longitude) {
        var stop_object = stop.createObject(appWindow)
        if(!stop_object) {
            console.debug("creating object failed")
            return
        }
        var coord = coord_component.createObject(appWindow)
        coord.latitude = latitude
        coord.longitude = longitude
        stop_object.coordinate = coord
        Helper.push_to_objects(stop_object)
    }
}
