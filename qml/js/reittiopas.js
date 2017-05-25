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
API['helsinki'].URL = 'http://api.reittiopas.fi/hsl/prod/'
API['helsinki'].USER = 'JollaOpas'
API['helsinki'].PASS = 'J_0P4s'

API['tampere'] = {}
API['tampere'].URL = 'http://api.publictransport.tampere.fi/prod/'
API['tampere'].USER = 'JollaOpas'
API['tampere'].PASS = 'J_0P4s'

var transType = {}
transType[1] = "bus"
transType[2] = "tram"
transType[3] = "bus"
transType[4] = "bus"
transType[5] = "bus"
transType[6] = "metro"
transType[7] = "boat"
transType[8] = "bus"
transType[12] = "train"
transType[21] = "bus"
transType[22] = "bus"
transType[23] = "bus"
transType[24] = "bus"
transType[25] = "bus"
transType[36] = "bus"
transType[39] = "bus"

//route instance
var _instance = null
var _http_request = null
var _request_parent = null

function busCode(code) {
    code = code.slice(1,5).trim().replace(/^[0]+/g,"")
    return code
}

function tramCode(code) {
    code = code.slice(2,5).trim().replace(/^[0]+/g,"")
    return code
}

function trainCode(code) {
    return code[4]
}

function translate_typecode(type, code, api_type) {
    if(type == "walk")
        return { type:"walk", code:""}
    else if(transType[type] == "bus")
        if(api_type == 'helsinki')
            return { type:transType[type], code:busCode(code) }
        else
            return { type:transType[type], code:code }
    else if(transType[type] == "train")
        return { type:transType[type], code:trainCode(code) }
    else if(transType[type] == "tram")
        return { type:transType[type], code:tramCode(code) }
    else if(transType[type] == "boat")
        return { type:transType[type], code:"" }
    else if(transType[type] == "metro")
        return { type:transType[type], code:"M" }
    else
        return { type:transType[type], code:code }
}

function convTime(hslTime){
    var time = hslTime;
    // In HSL timeFormat months are 01-12 and in Javascript Date 0-11 so needed to decrease by one
    return new Date(time.slice(0,4),
                    parseInt((time.slice(4,6)-1), 10),
                    parseInt(time.slice(6,8), 10),
                    time.slice(8,10),
                    time.slice(10,12),
                    0, 0);
}

function get_time_difference_in_minutes(earlierDate,laterDate)
{
    return Math.floor((laterDate.getTime() - earlierDate.getTime())/1000/60);
}

function locTypeIdToTxt(locTypeId) {
    /* ---Input---
       Name: locTypeId
       Type: Number
       Description: Location type id of the location (1-9 and 1008 = poi, 10 = stop, 900 = address)
       ---Output---
       Type: String
       Description: Location as a matching string or invalid type string*/
    if (1 <= locTypeId <= 9 || locTypeId === 1008)
        return qsTr("Place of interest")
    else if (locTypeId === 10)
        return qsTr("Stop")
    else if (locTypeId === 900)
        return qsTr("Address")
    else return qsTr("Invalid Location Type")
}

/****************************************************************************************************/
/*                     address to location                                                          */
/****************************************************************************************************/
function get_geocode(term, api_type) {
    api_type = api_type || 'helsinki'
    var parameters = {}
    parameters.format = "xml"
    parameters.request = "geocode"
    parameters.key = term
    parameters.disable_unique_stop_names = 0
    parameters.user = API[api_type].USER
    parameters.pass = API[api_type].PASS
    parameters.epsg_in = "wgs84"
    parameters.epsg_out = "wgs84"
    var query = []
    for(var p in parameters) {
        query.push(p + "=" + parameters[p])
    }

    //console.log( API[api_type].URL + '?' + query.join('&'))
    return API[api_type].URL + '?' + query.join('&')
}

/****************************************************************************************************/
/*                     location to address                                                          */
/****************************************************************************************************/
function get_reverse_geocode(latitude, longitude, api_type) {
    api_type = api_type || 'helsinki'
    var parameters = {}
    parameters.format = "xml"
    parameters.request = 'reverse_geocode'
    parameters.coordinate = longitude + ',' + latitude
    parameters.user = API[api_type].USER
    parameters.pass = API[api_type].PASS
    parameters.epsg_in = "wgs84"
    parameters.epsg_out = "wgs84"

    var query = []
    for(var p in parameters) {
        query.push(p + "=" + parameters[p])
    }

    //console.debug( API[api_type].URL + '?' + query.join('&'))
    return API[api_type].URL + '?' + query.join('&')
}

/****************************************************************************************************/
/*                     Reittiopas query class                                                       */
/****************************************************************************************************/
function reittiopas() {
    this.model = null
}
reittiopas.prototype.api_request = function() {
    _http_request = new XMLHttpRequest()
    this.model.done = false

    _request_parent = this
    _http_request.onreadystatechange = _request_parent.result_handler

    this.parameters.user = API[this.api_type].USER
    this.parameters.pass = API[this.api_type].PASS
    this.parameters.epsg_in = "wgs84"
    this.parameters.epsg_out = "wgs84"

    var query = []
    for(var p in this.parameters) {
        query.push(p + "=" + this.parameters[p])
    }
    console.debug( API[this.api_type].URL + '?' + query.join('&'))
    _http_request.open("GET", API[this.api_type].URL + '?' + query.join('&'))
    _http_request.send()
}

/****************************************************************************************************/
/*                                            Route search                                          */
/****************************************************************************************************/

function new_route_instance(parameters, route_model, api_type) {
    if(_instance)
        delete _instance

    _instance = new route_search(parameters, route_model, api_type);
    return _instance
}

function get_route_instance() {
    return _instance
}

route_search.prototype = new reittiopas()
route_search.prototype.constructor = route_search
function route_search(parameters, route_model, api_type) {
    api_type = api_type || 'helsinki'
    this.last_result = []
    this.api_type = api_type
    this.model = route_model

    this.jstime = parameters.jstime

    this.last_route_index = -1

    this.from_name = parameters.from_name
    this.to_name = parameters.to_name

    this.parameters = parameters
    delete this.parameters.time

    this.parameters.date = Qt.formatDate(this.jstime, "yyyyMMdd")
    this.parameters.time = Qt.formatTime(this.jstime, "hhmm")

    this.parameters.format = "json"
    this.parameters.request = "route"
    this.parameters.show = 5
    this.parameters.lang = "fi"
    this.parameters.detail= "full"
    this.api_request()
}

route_search.prototype.parse_json = function(routes, parent) {
    for (var index in routes) {
        var output = {}
        var route = routes[index][0];
        output.length = route.length
        output.duration = Math.round(route.duration/60)
        output.start = 0
        output.finish = 0
        output.first_transport = 0
        output.last_transport = 0
        output.walk = 0
        output.legs = []

        for (var leg in route.legs) {
            var legdata = route.legs[leg]
            output.legs[leg] = {
                "type":translate_typecode(legdata.type,legdata.code, this.api_type).type,
                "code":translate_typecode(legdata.type,legdata.code, this.api_type).code,
                "shortCode":legdata.shortCode,
                "length":legdata.length,
                "duration":Math.round(legdata.duration/60),
                "from":{},
                "to":{},
                "locs":[],
                "leg_number":leg
            }
            output.legs[leg].from.name = legdata.locs[0].name?legdata.locs[0].name:""
            output.legs[leg].from.time = convTime(legdata.locs[0].depTime)
            output.legs[leg].from.shortCode = legdata.locs[0].shortCode
            output.legs[leg].from.latitude = legdata.locs[0].coord.y
            output.legs[leg].from.longitude = legdata.locs[0].coord.x

            output.legs[leg].to.name = legdata.locs[legdata.locs.length - 1].name?legdata.locs[legdata.locs.length - 1].name : ''
            output.legs[leg].to.time = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            output.legs[leg].to.shortCode = legdata.locs[legdata.locs.length - 1].shortCode
            output.legs[leg].to.latitude = legdata.locs[legdata.locs.length - 1].coord.y
            output.legs[leg].to.longitude = legdata.locs[legdata.locs.length - 1].coord.x

            for (var locindex in legdata.locs) {
                var locdata = legdata.locs[locindex]

                output.legs[leg].locs[locindex] = {
                    "name" : locdata.name,
                    "shortCode" : locdata.shortCode,
                    "latitude" : locdata.coord.y,
                    "longitude" : locdata.coord.x,
                    "arrTime" : convTime(locdata.arrTime),
                    "depTime" : convTime(locdata.depTime),
                    "time_diff" : get_time_difference_in_minutes(convTime(route.legs[0].locs[0].arrTime), convTime(locindex == 0 ? locdata.depTime : locdata.arrTime))
                }
            }
            output.legs[leg].shape = legdata.shape

            // update name and time to first and last leg - not coming automatically from Reittiopas API
            if(leg == 0) {
                output.legs[leg].from.name = parent.from_name
                output.legs[leg].locs[0].name = parent.from_name
                output.start = convTime(legdata.locs[0].depTime)
            }
            if(leg == (route.legs.length - 1)) {
                output.legs[leg].to.name = _request_parent.to_name
                output.legs[leg].locs[output.legs[leg].locs.length - 1].name = parent.to_name
                output.finish = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            }

            /* update the first and last time using any other transportation than walking */
            if(!output.first_transport && legdata.type != "walk")
                output.first_transport = convTime(legdata.locs[0].depTime)
            if(legdata.type !== "walk")
                output.last_transport = convTime(legdata.locs[legdata.locs.length - 1].arrTime)

            // amount of walk in the route
            if(legdata.type === "walk")
                output.walk += legdata.length
        }
        parent.last_result.push(output)
        parent.model.append(output)
    }
}

route_search.prototype.result_handler = function() {
    if (_http_request.readyState === XMLHttpRequest.DONE) {
        if (_http_request.status !== 200 && _http_request.status !== 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var parent = _request_parent
    var routes = eval(_http_request.responseText)

    _request_parent.parse_json(routes, parent)
    _request_parent.model.done = true
}

route_search.prototype.get_current_route_index = function() {
    return this.last_route_index
}

route_search.prototype.dump_stops = function(index, model) {
    var route = this.last_result[this.last_route_index]
    var legdata = route.legs[index]
    for (var locindex in legdata.locs) {
        var locdata = legdata.locs[locindex]
        /* for walking add only first and last "stop" */
        if(legdata.type == "walk" && locindex !== 0 && locindex !== legdata.locs.length - 1) { }
        else {
            model.append(legdata.locs[locindex])
        }
    }
    model.done = true
}

route_search.prototype.dump_legs = function(index, model) {
    var route = this.last_result[index]

    // save used route index for dumping stops
    this.last_route_index = index

    for (var legindex in route.legs) {
        var legdata = route.legs[legindex]
        var station = {}
        station.type = "station"
        station.name = legdata.locs[0].name?legdata.locs[0].name:''
        station.time = legdata.locs[0].depTime
        station.code = ""
        station.shortCode = legdata.locs[0].shortCode
        station.length = 0
        station.duration = 0
        station.leg_number = ""
        station.locs = []
        model.append(station)

        model.append(legdata)
    }
    var last_station = {"type" : "station",
                        "name" : legdata.locs[legdata.locs.length - 1].name ? legdata.locs[legdata.locs.length - 1].name : "",
                        "time" : legdata.locs[legdata.locs.length - 1].arrTime,
                        "leg_number" : ""}

    model.append(last_station)

    model.done = true
}

location_to_address.prototype = new reittiopas
location_to_address.prototype.constructor = location_to_address
function location_to_address(latitude, longitude, model, api_type) {
    api_type = api_type || 'helsinki'
    this.model = model
    this.api_type = api_type
    this.parameters = {}
    this.parameters.request = "reverse_geocode"
    this.parameters.coordinate = longitude.replace(',','.') + ',' + latitude.replace(',','.')
    this.api_request(this.positioning_handler)
}

location_to_address.prototype.positioning_handler = function() {
    if (_http_request.readyState === XMLHttpRequest.DONE) {
        if (_http_request.status !== 200 && _http_request.status !== 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var suggestions = eval(_http_request.responseText)

    _request_parent.model.clear()
    for (var index in suggestions) {
        var output = {}
        var suggestion = suggestions[index];
        output.name = suggestion.name.split(',', 1).toString()

        output.displayname = suggestion.matchedName
        output.city = suggestion.city
        output.type = suggestion.locType
        output.coord = suggestion.coord

        _request_parent.model.append(output)
    }
    _request_parent.model.done = true
}
