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
import "qrc:/reittiopas.js" as Reittiopas
import "qrc:/storage.js" as Storage
import "./components"
import "../../components"

Page {
    property variant search_parameters

    Component.onCompleted: startSearch()

    function startSearch() {
        appWindow.itinerariesModel.clear()
        Reittiopas.get_route(search_parameters, appWindow.itinerariesModel,
                             appWindow.itinerariesJson, Storage.getSetting('api'));
    }

    function setCoverData() {
        var route = Reittiopas.get_route_instance()
        appWindow.coverAlignment = Text.AlignLeft
        appWindow.coverHeader = search_parameters.from_name
        appWindow.coverContents = ""

        for (var index = 0; index < appWindow.itinerariesModel.count; ++index) {
            var startTime = Qt.formatTime(appWindow.itinerariesModel.get(index).start, "hh:mm")
            var finishTime = Qt.formatTime(appWindow.itinerariesModel.get(index).finish, "hh:mm")
            var code = ""
            if (appWindow.itinerariesModel.get(index).legs.get(0) && appWindow.itinerariesModel.get(index).legs.get(0).type !== "walk" ) {
                code = " | L: " + appWindow.itinerariesModel.get(index).legs.get(0).code;
            }
            else if (appWindow.itinerariesModel.get(index).legs.get(1) && appWindow.itinerariesModel.get(index).legs.get(1).type !== "walk" ) {
                code = " | L: " + appWindow.itinerariesModel.get(index).legs.get(1).code;
            }
            appWindow.coverContents += startTime + "-" + finishTime + code + "\n";
        }
    }

    Connections {
        target: appWindow.itinerariesModel
        // Update cover when performing the search for the first time
        onDoneChanged: {
            if (appWindow.itinerariesModel.done) {
                setCoverData()
            }
        }
    }
    // Update cover when coming back to ResultPage from RoutePage
    onStatusChanged: {
        if (status == PageStatus.Activating && appWindow.itinerariesModel.done) {
            setCoverData()
        }
    }

    Component {
        id: footer

        ListItem {
            height: Theme.itemSizeExtraSmall
            visible: !busyIndicator.running

            onClicked: {
                /* workaround to modify qml array is to make a copy of it,
                   modify the copy and assign the copy back to the original */
                var new_parameters = search_parameters
                new_parameters.jstime.setMinutes(new_parameters.jstime.getMinutes() + 15)
                new_parameters.time = Qt.formatTime(new_parameters.jstime.getMinutes(), "hhmm")
                search_parameters = new_parameters

                startSearch()
            }

            Label {
                text: qsTr("Next") + " (" + search_parameters.jstime.toLocaleTimeString(Qt.locale(),"hh:mm") + " +15 min)"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.secondaryColor
            }
        }
    }


    SilicaListView {
        id: list
        anchors.fill: parent
        model: appWindow.itinerariesModel
        footer: footer
        delegate: ResultDelegate {}
        spacing: 10 * Theme.pixelRatio
        interactive: !busyIndicator.running
        header: Column {
            width: parent.width
            Clock {
                running: Qt.application.active
                height: 60
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ListItem {
                height: Theme.itemSizeExtraSmall
                visible: !busyIndicator.running

                onClicked: {
                    /* workaround to modify qml array is to make a copy of it,
                       modify the copy and assign the copy back to the original */
                    var new_parameters = search_parameters
                    new_parameters.jstime.setMinutes(new_parameters.jstime.getMinutes() - 15)
                    new_parameters.time = Qt.formatTime(new_parameters.jstime.getMinutes(), "hhmm")
                    search_parameters = new_parameters

                    startSearch()
                }

                Label {
                    text: qsTr("Previous") + " (" + search_parameters.jstime.toLocaleTimeString(Qt.locale(),"hh:mm") +" -15 min)"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor
                }
            }
            Spacing{id: headerSpacing; height: 10}
            ListItem {
                height: from_label.height
                visible: !busyIndicator.running

                Label {
                    id:from_label
                    width: parent.width
                    text: search_parameters.from_name
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }
                Label {
                    id:to_label
                    width: parent.width
                    text: search_parameters.to_name
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.WordWrap
                }
            }
        }

        ViewPlaceholder {
            anchors.centerIn: parent
            visible: (!busyIndicator.running && appWindow.itinerariesModel.count == 0)
            text: qsTr("No results")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Map")
                onClicked: { pageStack.push(Qt.resolvedUrl("ResultMapPage.qml")) }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        running: !appWindow.itinerariesModel.done
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}
