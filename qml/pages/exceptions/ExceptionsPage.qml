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
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    Component.onCompleted: {
        exceptionModel.reload()
    }

    XmlListModel {
        id: exceptionModel
        source: "http://www.poikkeusinfo.fi/xml/v2"
        query: "/DISRUPTIONS/DISRUPTION"
        XmlRole { name: "time"; query: "VALIDITY/@from/string()" }
        XmlRole { name: "info_fi"; query: "INFO/TEXT[1]/string()" }
        XmlRole { name: "info_sv"; query: "INFO/TEXT[2]/string()" }
        XmlRole { name: "info_en"; query: "INFO/TEXT[3]/string()" }
    }

    SilicaListView {
        id: list
        anchors.fill: parent
        model: exceptionModel
        delegate: ExceptionDelegate {}

        VerticalScrollDecorator {}

        header: PageHeader {
            title: qsTr("Traffic exception info")
        }

        PullDownMenu {
            MenuItem { text: qsTr("Update"); onClicked: exceptionModel.reload() }
        }

        ViewPlaceholder {
            anchors.centerIn: parent
            enabled: (!busyIndicator.running && exceptionModel.count == 0)
            text: qsTr("No current traffic exceptions")
        }
    }

    BusyIndicator {
        id: busyIndicator
        running: exceptionModel.status != XmlListModel.Ready
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }
}
