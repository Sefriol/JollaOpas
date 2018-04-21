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

Component {
    id: routeDelegate

    BackgroundItem {
        id: delegate_item
        width: parent.width
        height: Theme.itemSizeLarge
        highlighted: true

        onClicked: {
            pageStack.pushAttached(Qt.resolvedUrl("../pages/RoutePage.qml"),
                                   {
                                       route_index: index,
                                       header: search_parameters.from_name + " - " + search_parameters.to_name,
                                       duration: duration,
                                       walking: Math.floor(walk/100)/10,
                                       start_time: start,
                                       finish_time: finish
                                   })
            pageStack.navigateForward()
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall

            Label {
                text: "(" + Qt.formatTime(start, "hh:mm") + ")"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                text: first_transport ? Qt.formatTime(first_transport, "hh:mm") : Qt.formatTime(start, "hh:mm")
                width: 75
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
            }

            Label {
                text: duration + " min"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Flow {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: repeater
                model: legs
                Column {
                    visible: repeater.count == 1 ? true : (type == "walk") ? false : true
                    Image {
                        id: transportIcon
                        source: "qrc:/images/" + type + ".png"
                        smooth: true
                        height: 50 * Theme.pixelRatio
                        width: height
                    }

                    Label {
                        text: type == "walk" ? Math.floor(length/100)/10 + ' km' : code
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primaryColor
                        anchors.horizontalCenter: transportIcon.horizontalCenter
                    }
                }
            }
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.paddingSmall
            anchors.leftMargin: Theme.paddingSmall

            Label {
                text: "(" + Qt.formatTime(finish, "hh:mm") + ")"
                anchors.right: parent.right
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                text: last_transport ? Qt.formatTime(last_transport, "hh:mm") : Qt.formatTime(finish, "hh:mm")
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
            }

            Label {
                text: qsTr("Walk")+ " " + Math.floor(walk/100)/10 + " km"
                horizontalAlignment: Qt.AlignRight
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
