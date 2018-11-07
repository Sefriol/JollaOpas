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
            + '){itineraries{walkDistance,duration,startTime,endTime,legs{mode route{shortName,gtfsId} duration startTime endTime from{lat lon name stop{code name}},intermediateStops{lat lon code name},to{lat lon name stop{code name}},distance, legGeometry{points}}}}}';

//    console.debug(query);
    var http_request = new XMLHttpRequest();
    http_request.open("POST", API['digitransitgeocoding'].URL + queryType);
    http_request.setRequestHeader("Content-Type", "application/graphql");
    http_request.setRequestHeader("Accept", "*/*")
    http_request.onreadystatechange = function() {
        if (http_request.readyState === XMLHttpRequest.DONE) {
            itineraries_json = JSON.parse(http_request.responseText);
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
                        "orgcode": legdata.route ? legdata.route.gtfsId : "",
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

function topic2object(topic_str){
    /*
    MQTT Topic objectifier.
    SOURCE: https://digitransit.fi/en/developers/apis/4-realtime-api/vehicle-positions/

    prefix          /hfp/ is the root of the topic tree.
    version         v1 is the current version of the HFP topic and the payload format.
    temporal_type	The type of the journey, ongoing or upcoming. ongoing describes the current situation. upcoming refers to the next expected journey of the same vehicle. upcoming messages are broadcasted shortly before the start of the next journey. One use of upcoming is to show the relevant vehicle to your users even before the driver has signed on to the journey that your users are interested in. upcoming is not working properly yet, though.
    transport_mode	The type of the vehicle. One of bus, tram or train. The metro, the ferries and the U-line busses are not supported. Due to a bug some replacement busses for tram lines have tram as their type. We are working on it.
    operator_id     The unique ID of the operator that owns the vehicle.
    vehicle_number	The vehicle number that can be seen painted on the side of the vehicle, often next to the front door. Different operators may use overlapping vehicle numbers. operator_id/vehicle_number uniquely identifies the vehicle.
    route_id        This matches route_id in GTFS. Due to a bug some rare “number variants” do not match GTFS properly. We are working on it.
    direction_id	The line direction of the trip. Matches direction_id in GTFS. Either 1 or 2.
    headsign        The destination name, e.g. Aviapolis. Note: This does NOT match trip_headsign in GTFS exactly.
    start_time      The scheduled start time of the trip, i.e. the scheduled departure time from the first stop of the trip. The format follows %H:%M in 24-hour local time, not the 30-hour overlapping operating days present in GTFS.
    next_stop       The next stop or station. Updated on each departure from or passing of a stop. EOL (end of line) after final stop. Matches stop_id in GTFS.
    geohash_level	The geohash level represents the magnitude of change in the GPS coordinates since the previous message from the same vehicle. More exactly, geohash_level is equal to the minimum of the digit positions of the most significant changed digit in the latitude and the longitude since the previous message. For example, if the previous message has value (60.12345, 25.12345) for (lat, long) and the current message has value (60.12499, 25.12388), then the third digit of the fractional part is the most significant changed digit and geohash_level has value 3.
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
                    This geohash scheme is greatly simplified from the original geohash scheme.*/
    var topicArr = topic_str.split("/").slice(1);
    return {
        prefix: topicArr[0],
        version: topicArr[1],
        temporal_type: topicArr[3],
        transport_mode: topicArr[4],
        operator_id: topicArr[5],
        vehicle_number: topicArr[6],
        route_id: topicArr[7],
        direction_id: topicArr[8],
        headsign: topicArr[9],
        start_time: topicArr[10],
        next_stop: topicArr[11],
        geohash_level: topicArr[12],
        geohash: topicArr[13],
    }
}
