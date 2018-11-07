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
API['tampere'] = {}
API['tampere'].URL = 'http://data.itsfactory.fi/siriaccess/vm/json'

//sirilive instance
var _instance = null
var _http_request = null
var _request_parent = null

// Returns true if vehicle is found in the list of allowedVehicles
function showVehicle(vehicle, allowedVehicles) {
    for (var index in allowedVehicles) {
        var allowedVehicleCode = allowedVehicles[index].code
        // Bus lines have possibly letter in Reittiopas API but not in Siri so leaving it out
        if (allowedVehicles[index].type === "bus" && vehicle.type === "bus") {
            allowedVehicleCode = allowedVehicleCode.replace(/[A-Z]$/, '')
            vehicle.code = vehicle.code.replace(/[A-Z]$/, '')
        }
        if (allowedVehicles[index].type === vehicle.type && allowedVehicleCode === vehicle.code) {
            return true
        }
        else if (allowedVehicles[index].type === "metro" && allowedVehicles[index].type === vehicle.type) {
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
    var time_stamp = vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].ResponseTimestamp

    _request_parent.model.timeStamp = time_stamp
    _request_parent.parse_json(vehicles, parent)
    _request_parent.model.done = true
}

LiveResult.prototype.parse_json = function(vehicles, parent) {
    if (typeof parent.model.clear === "function") {
        parent.model.clear()
    }
    for (var monitoredVehicle in vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity) {
        var vehicleData = vehicles.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity[monitoredVehicle]
        var code = vehicleData.MonitoredVehicleJourney.LineRef.value
        var color = vehicleData.dir === "1" ? "#08a7cc" : "#cc2d08"
        var vehicleTypeAndCode = {};
        // Siri API is used only for Tampere now and trams are not in Tampere yet, so always
        // default to bus
        vehicleTypeAndCode = { "type": "bus", "code": code }
        // Show only vehicles included in the route
        var allowedVehicles = parent.model.vehicleCodesToShowOnMap
        if (showVehicle(vehicleTypeAndCode, allowedVehicles)) {
            parent.model.append({ "modelLongitude": vehicleData.MonitoredVehicleJourney.VehicleLocation.Longitude, "modelLatitude": vehicleData.MonitoredVehicleJourney.VehicleLocation.Latitude, "modelCode": code, "modelColor": color, "modelBearing": vehicleData.MonitoredVehicleJourney.Bearing })
        }
    }
}