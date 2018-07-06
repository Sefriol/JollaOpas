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
import org.nemomobile.notifications 1.0
import "js/storage.js" as Storage
import "js/favorites.js" as Favorites
import "pages/"
import "components"

ApplicationWindow {
    id: appWindow

    property alias coverPage: coverPage
    cover:  CoverPage {
        id: coverPage
    }

    Notification {
        id: notification
        previewBody : ""
        previewSummary : ""
        onClicked : notification.close()
    }

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        Storage.initialize()
        Favorites.initialize()

        var apiValue = Storage.getSetting("api")
        if (apiValue === "Unknown") {
            var dialog = pageStack.push(Qt.resolvedUrl("pages/dialogs/StartupDialog.qml"))
            dialog.onAccepted.connect(function() {
                mainPage = pageStack.replace(Qt.resolvedUrl("pages/main/MainPage.qml"))
            })
            dialog.onRejected.connect(function() {
                mainPage = pageStack.replace(Qt.resolvedUrl("pages/main/MainPage.qml"))
            })
        }
        else {
            mainPage = pageStack.push(Qt.resolvedUrl("pages/main/MainPage.qml"))
        }
    }

    signal followModeEnabled

    property alias banner : banner
    property int scalingFactor : 1
    property bool followMode : false
    property bool mapVisible : false
    property string colorscheme : "default"
    property variant routeModel: routeModel

    ListModel{
        id:routeModel
    }

    // Pages sets the cover data to these properties and cover is instantiated every time based on these
    property string coverHeader: ''
    property string coverContents: ''
    property int coverAlignment: Text.AlignHCenter
    property string currentApi: ''
    property variant mainPage
    property ListModel itinerariesModel: itinerariesModel
    property string itinerariesJson: ""
    property int itinerariesIndex: -1
    property string fromName: ""
    property string toName: ""
    function useNotification(text){
        notification.close()
        notification.previewSummary = text
        notification.publish()
    }
    onFollowModeChanged: {
        if(followMode)
            followModeEnabled()
    }

    Label {
        id: banner
    }

    ListModel {
        id: itinerariesModel
        property bool done: false
    }
}
