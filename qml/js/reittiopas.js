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

API['digitransitgeocoding'] = {}
API['digitransitgeocoding'].URL = 'https://api.digitransit.fi/'

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
function get_geocode(term, model, api_type) {
    model.done = false;
    api_type = api_type || 'helsinki';
    var size = 10;
    var queryType = 'geocoding/v1/search';
    var boundarycircleradius = 40;
    // Search only on 40km radius from Helsinki railway station or Tampere Keskustori
    var boundarycirclelat = 60.169;
    var boundarycirclelon = 24.940;
    if (api_type === 'tampere') {
        boundarycirclelat = 61.498;
        boundarycirclelon = 23.759;
    }
    var query = "boundary.circle.lat=" + boundarycirclelat + "&boundary.circle.lon=" + boundarycirclelon
            + "&boundary.circle.radius=" + boundarycircleradius + "&size=" + size + "&text=" + term;

    //console.debug(API['digitransitgeocoding'].URL + queryType + '?' + query);
    var http_request = new XMLHttpRequest();
    http_request.open("GET", API['digitransitgeocoding'].URL + queryType + '?' + query);
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            var a = JSON.parse(http_request.responseText);
//            console.debug("js result: " + JSON.stringify(a));
            // TODO: Find a way to display no results when features array is empty
            for (var index in a.features) {
                a.features[index].properties.coord = a.features[index].geometry.coordinates[0] + "," +
                        a.features[index].geometry.coordinates[1];
                model.append(a.features[index].properties);
            }
            model.done = true;
        }
        else {
//            console.debug("Error receiving geocode");
        }
    }
    http_request.send();
}

/****************************************************************************************************/
/*                     location to address                                                          */
/****************************************************************************************************/
function get_reverse_geocode(latitude, longitude, model, api_type) {
    model.done = false;
    api_type = api_type || 'helsinki';
    var size = 1;
    var queryType = 'geocoding/v1/reverse';
    var query = "point.lat=" + latitude + "&point.lon=" + longitude + "&size=" + size;

//    console.debug(API['digitransitgeocoding'].URL + queryType + '?' + query);
    var http_request = new XMLHttpRequest();
    http_request.open("GET", API['digitransitgeocoding'].URL + queryType + '?' + query);
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            var a = JSON.parse(http_request.responseText);
//            console.debug("js result: " + JSON.stringify(a));
            // TODO: Find a way to display no results when features array is empty
            for (var index in a.features) {
                a.features[index].properties.coord = a.features[index].geometry.coordinates[0] + "," +
                        a.features[index].geometry.coordinates[1];
                model.append(a.features[index].properties);
            }
            model.done = true;
        }
        else {
//            console.debug("Error receiving geocode");
        }
    }
    http_request.send();
}

/****************************************************************************************************/
/*                     Reittiopas query class                                                       */
/****************************************************************************************************/
function get_route(parameters, itineraries_model, itineraries_json, api_type) {
    itineraries_model.done = false;
    api_type = api_type || 'helsinki';
    var size = 5;
    var queryType = 'routing/v1/routers/hsl/index/graphql';
    if (api_type === 'tampere') {
        queryType = 'routing/v1/routers/finland/index/graphql';
    }

//    console.debug(JSON.stringify(parameters));
    var graphqlFromLon = parameters.from.split(',', 2)[0]
    var graphqlFromLat = parameters.from.split(',', 2)[1]
    var graphqlToLon = parameters.to.split(',', 2)[0]
    var graphqlToLat = parameters.to.split(',', 2)[1]
    var graphqlDate = Qt.formatDate(parameters.jstime, "yyyy-MM-dd");
    var graphqlTime = Qt.formatTime(parameters.jstime, "hh:mm:ss");
    var graphqlTransferTime = parameters.change_margin * 60;
    var graphqlNumberOfItinaries = 5;
    var graphqlWalkSpeed = parameters.walk_speed / 60;
    var graphqlArriveBy = ""
    var graphqlExtra = ""
    switch(parameters.optimize){
        case 'default':
            break;
        case 'fastest':
            break;
        case 'least_transfers':
            break;
        case 'least_walking':
            break;
    }

    if (parameters.arriveBy) {
        graphqlArriveBy = " arriveBy: true "
    }
    var query = '{plan(from:{lat:' + graphqlFromLat + ',lon:' + graphqlFromLon + '},to:{lat:'
            + graphqlToLat + ',lon:' + graphqlToLon + '},date:"' + graphqlDate + '",time:"'
            + graphqlTime + '",numItineraries:' + graphqlNumberOfItinaries
            + ',modes:"' + parameters.modes + '",minTransferTime:'
            + graphqlTransferTime + ',walkSpeed:' + graphqlWalkSpeed + graphqlArriveBy
            + '){itineraries{walkDistance,duration,startTime,endTime,legs{mode route{shortName} duration startTime endTime from{lat lon name stop{code name}},intermediateStops{lat lon code name},to{lat lon name stop{code name}},distance, legGeometry{points}}}}}';

//    console.debug(query);
    var http_request = new XMLHttpRequest();
    http_request.open("POST", API['digitransitgeocoding'].URL + queryType);
    http_request.setRequestHeader("Content-Type", "application/graphql");
    http_request.setRequestHeader("Accept", "*/*")
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            itineraries_json = JSON.parse(http_request.responseText);
//            console.debug("Query json result: " + JSON.stringify(itineraries_json));
            for (var index in itineraries_json.data.plan.itineraries) {
                var output = {}
                var route = itineraries_json.data.plan.itineraries[index]
                output.length = 0
                output.duration = Math.round(route.duration/60)
                output.start = new Date(route.startTime)
                output.finish = new Date(route.endTime)
                output.first_transport = 0
                output.last_transport = 0
                output.walk = route.walkDistance
                output.legs = []
                for (var leg in route.legs) {
                    var legdata = route.legs[leg]
                    output.legs[leg] = {
                        "type": legdata.mode.toLowerCase(),
                        "code": legdata.route ? legdata.route.shortName : "",
                        "shortCode": legdata.from.stop ? legdata.from.stop.name : "",
                        "length": legdata.distance,
                        "polyline": legdata.legGeometry.points,
                        "duration": Math.round(legdata.duration/60),
                        "from": {},
                        "to": {},
                        "locs": [],
                        "leg_number": leg
                    }
                    output.legs[leg].from.name = legdata.from.name ? legdata.from.name : ""
                    output.legs[leg].from.time = new Date(legdata.startTime)
                    output.legs[leg].from.shortCode = legdata.from.stop ? legdata.from.stop.code : ""
                    output.legs[leg].from.latitude = legdata.from.lat
                    output.legs[leg].from.longitude = legdata.from.lon
                    output.legs[leg].to.name = legdata.to.name ? legdata.to.name : ""
                    output.legs[leg].to.time = new Date(legdata.endTime)
                    output.legs[leg].to.shortCode = legdata.to.stop ? legdata.to.stop.code : ""
                    output.legs[leg].to.latitude = legdata.to.lat
                    output.legs[leg].to.longitude = legdata.to.lon
                    for (var stopindex in legdata.intermediateStops) {
                        var locdata = legdata.intermediateStops[stopindex]
                        // TODO: Investigate if it's easily possible to retrieve stop times
                        // from digitransit graphql API
                        output.legs[leg].locs[stopindex] = {
                            "name" : locdata.name,
                            "shortCode" : locdata.code,
                            "latitude" : locdata.lat,
                            "longitude" : locdata.lon,
                            "arrTime" : 0,
                            "depTime" : 0,
                            "time_diff": 0
                        }
                    }
                    /* update the first and last time using any other transportation than walking */
                    if(!output.first_transport && legdata.mode !== "WALK") {
                        output.first_transport = new Date(legdata.startTime)
                    }
                    if(legdata.mode !== "WALK") {
                        output.last_transport = output.legs[leg].to.time
                    }
                }
                itineraries_model.append(output);
            }
            itineraries_model.done = true;
        }
        else {
//            console.debug("Error receiving route query");
        }
    }
    http_request.send(query);
}

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
