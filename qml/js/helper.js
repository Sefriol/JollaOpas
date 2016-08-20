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

var stations = []
var current_station = 0

var objects = []

function push_to_objects(item) {
    if(item)
        objects.push(item)
}

function set_group_objects(group) {
    group.objects = objects
}

function clear_objects() {
    objects = []
    stations = []
    current_station = 0
}

function add_station(station) {
    if(station)
        stations.push(station)
}

function next_station() {
    return stations[++current_station%stations.length]
}

function previous_station() {
    return stations[--current_station%stations.length]
}

function first_station() {
    current_station = 0
    return stations[current_station]
}

function switch_locations(from, to) {
    var tempObj = JSON.parse(JSON.stringify(from.destinationObject))
    var templo = from.destination_name
    var tempcoord = from.destination_coord

    from.clear()
    from.updateLocation(to.destinationObject)
    to.clear()
    to.updateLocation(tempObj)
}

function parse_disruption_time(time) {
        var newtime = time;
        return new Date(newtime.slice(0,4),
                        parseInt(newtime.slice(5,7),10) - 1,
                        newtime.slice(8,10),
                        newtime.slice(11,13),
                        newtime.slice(14,16),
                        00, 00);
}

function meter_to_kilometer(distance) {

}

function capitalize_string(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

// @param dateStamp or dateObj
// @return string dateStamp formatted as hh:mm
function prettyTime(dateParam) {
    var returnString

    // default value
    returnString = ""



    // handle bad values
    if (typeof dateParam === 'undefined') return returnString

    // Get the hour and minute numbers from string
    if (typeof dateParam === 'string') {
        if (dateParam.length > 8) {
            returnString = dateParam.substring(8,10) + ":" + dateParam.substring(10,12)
        }
    }

    // parse dateObj
    else {
        returnString = Qt.formatDateTime(dateParam, "hhmm")
    }
    return returnString
}

// @param int amount of seconds
// @return h:mm:ss or just mm:ss from se
function prettyTimeFromSeconds(seconds) {
    var prefix = ""
    var hoursString = ""
    if (isNaN(seconds)) {
        return ""
    }  else {

        // handle negative times: add prefix to the output and do the calculation with positive number
        if (seconds < 0) {
            prefix = "-"
            seconds = -1*seconds
        }

        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds - 3600*hours)/ 60)
        var remainingSeconds = seconds - 60*minutes - 3600*hours

        // if the time is over an hour ago, add hours and zeropadding to the minute
        if (hours > 0) {
            hoursString = hours + ":"
            minutes = ('0' + minutes.toString()).slice(-2)
        }
    }
    return prefix + hoursString + minutes + ":" + ('0' + remainingSeconds.toString()).slice(-2)
}

// get two dates and return their difference in seconds
// if parameter is null, current time is used
function timestampDifferenceInSeconds(arrDate, depDate) {

    if (arrDate === null) {
        var arrDateObject = new Date()
    } else {
        var arrDateObject = new Date(arrDate)
    }

    if (depDate === null) {
        var depDateObject = new Date()
    } else {
        var depDateObject = new Date(depDate)
    }
    var seconds = Math.round((depDateObject-arrDateObject)/1000);
    return seconds
}
