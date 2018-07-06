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

.pragma library

var API = {}
API['helsinki'] = {}
API['helsinki'].URL = 'https://api.digitransit.fi/realtime/vehicle-positions/v1/hfp/journey/'

API['tampere'] = {}
API['tampere'].URL = 'http://data.itsfactory.fi/siriaccess/vm/json'

//sirilive instance
var _instance = null
var _http_request = null
var _request_parent = null

// Returns true if vehicle is found in the list of allowedVehicles
function showVehicle(vehicle, allowedVehicles) {
    for (var index in allowedVehicles)
    {
        var allowedVehicleCode = allowedVehicles[index].code
        // Bus lines have possibly letter in Reittiopas API but not in Siri so leaving it out
        if (allowedVehicles[index].type === "bus" && vehicle.type === "bus") {
            allowedVehicleCode = allowedVehicleCode.replace(/[A-Z]$/, '')
            vehicle.code = vehicle.code.replace(/[A-Z]$/, '')
        }
        if (allowedVehicles[index].type === vehicle.type && allowedVehicleCode === vehicle.code) {
            return true
        }
        else if (allowedVehicles[index].type === "metro" && allowedVehicles[index].type === vehicle.type ) {
            return true // Show all subways with "M" or "V" code
        }
    }
    return false
}

function SiriLive() {
    this.model = null
}

SiriLive.prototype.api_request = function() {
    _http_request = new XMLHttpRequest()
    this.model.done = false

    _request_parent = this
    _http_request.onreadystatechange = _request_parent.result_handler

    _http_request.open("GET", API[this.api_type].URL)
    _http_request.send()
}

function new_live_instance(vehicle_model, api_type) {
    if(_instance)
        delete _instance

    _instance = new LiveResult(vehicle_model, api_type)
    return _instance
}

function get_live_instance() {
    return _instance
}

LiveResult.prototype = new SiriLive()
LiveResult.prototype.constructor = LiveResult
function LiveResult(vehicle_model, api_type) {
    this.api_type = api_type
    this.model = vehicle_model
    this.api_request()
}

LiveResult.prototype.result_handler = function() {
    if (_http_request.readyState == XMLHttpRequest.DONE) {
        if (_http_request.status != 200 && _http_request.status != 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var parent = _request_parent
    var vehicles = JSON.parse(_http_request.responseText)
    if(_request_parent.api_type == 'helsinki') {
        var time_stamp = vehicles[Object.keys(vehicles)[0]].VP.tst
        _request_parent.parse_hel(vehicles, parent)
        _request_parent.model.done = true
    } else {
        var time_stamp = vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].ResponseTimestamp

        _request_parent.model.timeStamp = time_stamp
        _request_parent.parse_json(vehicles, parent)
        _request_parent.model.done = true
    }

}

LiveResult.prototype.parse_json = function(vehicles, parent) {
    if (typeof parent.model.clear === "function") {
        parent.model.clear()
    }
    for (var monitoredVehicle in vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity) {
        var vehicleData = vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity[monitoredVehicle]
        var code = vehicleData.MonitoredVehicleJourney.LineRef.value
        var color = vehicleData.MonitoredVehicleJourney.DirectionRef.value === "1" ? "#08a7cc" : "#cc2d08"
        var vehicleTypeAndCode = {};
        if (parent.api_type !== 'helsinki') {
            // No JORE codes in use outside of Helsinki
            vehicleTypeAndCode = {"type": "bus", "code": code}
        }
        else {
            // Jore parsing applied from example linked in: http://dev.hsl.fi/
            if (code.match("^1019")) {code = "Ferry"; color = "#0080c8"; vehicleTypeAndCode = {"type": "ferry", "code": "Ferry"} /*Ferry*/}
            else if (code.match(/^1300/)) {code = code.substring(4,5); color = "#ee5400"; vehicleTypeAndCode = {"type": "metro", "code": code}; /*Metro*/}
            else if (code.match(/^300/)) {code = code.substring(4,5); color = "#61b700"; vehicleTypeAndCode = {"type": "train", "code": code} /*Train*/}
            else if (code.match(/^10(0|10)/)) {code = code.substring(2,5).trim().replace(/^[0]?/,""); color = "#925bc6"; vehicleTypeAndCode = {"type": "tram", "code": code} /*Tram*/}
            else if (code.match(/^(1|2|4).../)) {code = code.substring(1).replace(/^[0]?/,""); vehicleTypeAndCode = {"type": "bus", "code": code} /*Use default color for bus*/}
            else {vehicleTypeAndCode = {"type": "bus", "code": code}; /*console.debug("Unknown vehicle found.") Unknown vehicle, expect bus, use default color */ }
        }
        // Show only vehicles included in the route
        var allowedVehicles = parent.model.vehicleCodesToShowOnMap
        if (showVehicle(vehicleTypeAndCode, allowedVehicles)) {
            parent.model.append({"modelLongitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Longitude, "modelLatitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Latitude, "modelCode" : code, "modelColor" : color, "modelBearing" : vehicleData.MonitoredVehicleJourney.Bearing})
        }
    }
}

LiveResult.prototype.parse_hel = function(vehicles, parent) {
    if (typeof parent.model.clear === "function") {
        parent.model.clear()
    }
    for (var monitoredVehicle in vehicles) {
        /* MQTT Topic. SOURCE: https://digitransit.fi/en/developers/apis/4-realtime-api/vehicle-positions/
        prefix          /hfp/ is the root of the topic tree.
                        version	v1 is the current version of the HFP topic and the payload format.
        transport_mode	The type of the vehicle. One of bus, tram or train.
                        The metro, the ferries and the U-line busses are not supported.
                        Due to a bug some replacement busses for tram lines have tram as their type.
                        We are working on it.
        operator_id     The unique ID of the operator that owns the vehicle.
        vehicle_number	The vehicle number that can be seen painted on the side of the vehicle,
                        often next to the front door. Different operators may use overlapping vehicle numbers.
                        operator_id/vehicle_number uniquely identifies the vehicle.
        route_id        This matches route_id in GTFS. Due to a bug some rare “number variants” do not match GTFS properly.
        direction_id	The line direction of the trip. Matches direction_id in GTFS. Either 1 or 2.
        headsign        The destination name, e.g. Aviapolis. Note: This does NOT match trip_headsign in GTFS exactly.
        start_time      The scheduled start time of the trip, i.e. the scheduled departure time from the first stop of the trip. The format follows %H:%M in 24-hour local time, not the 30-hour overlapping operating days present in GTFS.
        next_stop       The next stop or station. Updated on each departure from or passing of a stop. EOL (end of line) after final stop. Matches stop_id in GTFS.
        geohash_level	The geohash level represents the magnitude of change in the GPS coordinates
                        since the previous message from the same vehicle. More exactly, geohash_level is equal to the minimum of the digit positions of the most significant changed digit in the latitude and the longitude since the previous message. For example, if the previous message has value (60.12345, 25.12345) for (lat, long) and the current message has value (60.12499, 25.12388), then the third digit of the fractional part is the most significant changed digit and geohash_level has value 3.
                        However, geohash_level value 0 is overloaded. geohash_level is 0 if:
                        the integer part of the latitude or the longitude has changed,
                        the previous or the current message has null for coordinates or
                        the non-location parts of the topic have changed, e.g. when a bus departs from a stop.
                        By subscribing to specific geohash levels, you can reduce the amount of traffic into the client. By only subscribing to level 0 the client gets the most important status changes. The rough percentages of messages with a specific geohash_level value out of all ongoing messages are:
                        0: 3 %
                        1: 0.09 %
                        2: 0.9 %
                        3: 8 %
                        4: 43 %
                        5: 44 %
        geohash         The latitude and the longitude of the vehicle. The digits of the integer parts are separated into their own level in the format <lat>;<long>, e.g. 60;24. The digits of the fractional parts are split and interleaved into a custom format so that e.g. (60.123, 24.789) becomes 60;24/17/28/39. This format enables subscribing to specific geographic boundaries easily.
                        If the coordinates are missing, geohash_level and geohash have the concatenated value 0////.
                        Currently only 3 digits of the fractional part are published in the topic for both the latitude and the longitude even though geohash_level currently has precision up to 5 digits of the fractional part. As a form of future proofing your subscriptions, do not rely on the amount of fractional digits present in the topic. Instead, use the wildcard # at the end of topic filters.
                        This geohash scheme is greatly simplified from the original geohash scheme.

*/
        var topicArr = monitoredVehicle.split("/").slice(1);
        var vehicleTopic = {
            prefix: topicArr[0],
            transport_mode: topicArr[2],
            operator_id: topicArr[3],
            vehicle_number: topicArr[4],
            route_id: topicArr[5],
            direction_id: topicArr[6],
            headsign: topicArr[7],
            start_time: topicArr[8],
            next_stop: topicArr[9],
            geohash_level: topicArr[10],
            geohash: topicArr[11]
        }
        var vehicleData = vehicles[monitoredVehicle].VP
        var code = vehicleData.desi
        var color = vehicleData.dir === "1" ? "#08a7cc" : "#cc2d08"
        var vehicleTypeAndCode = {};
        switch(vehicleTopic.transport_mode) {
            case "bus": /*Use default color for bus*/
                vehicleTypeAndCode = {"type": "bus", "code": code};
                break;
            case "tram": /*Tram*/
                color = "#925bc6";
                vehicleTypeAndCode = {"type": "tram", "code": code}
                break
            case "train": /*Train*/
                color = "#61b700";
                vehicleTypeAndCode = {"type": "train", "code": code}
                break
        }
        // Show only vehicles included in the route
        var allowedVehicles = parent.model.vehicleCodesToShowOnMap
        if (showVehicle(vehicleTypeAndCode, allowedVehicles)) {
            parent.model.append({"modelLongitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Longitude, "modelLatitude" : vehicleData.MonitoredVehicleJourney.VehicleLocation.Latitude, "modelCode" : code, "modelColor" : color, "modelBearing" : vehicleData.MonitoredVehicleJourney.Bearing})
        }
    }
}
