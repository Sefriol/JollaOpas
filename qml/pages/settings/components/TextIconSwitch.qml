/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import QtGraphicalEffects 1.0

MouseArea {
    id: root

    property alias text: label.text
    property alias description: tdesc.text
    property alias fdescription: fdesc.text
    property alias source : indicator.source

    property bool checked
    property bool automaticCheck: true
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin
    property real _rightPadding
    property bool down: pressed && containsMouse && !DragFilter.canceled
    property bool highlighted: down || pressTimer.running
    property bool busy

    // This is only used by ButtonGroup - if ButtonGroup is removed, this should be also:
    property int __silica_textswitch

    width: parent ? parent.width : Screen.width
    implicitHeight: Math.max(toggle.height, Math.max(tdesc.y, fdesc.y) + Math.max(tdesc.height, fdesc.height))

    Item {
        id: toggle

        width: Theme.itemSizeExtraSmall
        height: Theme.itemSizeSmall
        anchors {
            left: parent.left; leftMargin: root.leftMargin - Theme.paddingLarge
        }

        Image {
            id: indicator
            anchors.bottom: parent.bottom
            height: 64
            width: 64
            smooth: true
            anchors.horizontalCenter: parent.horizontalCenter

            opacity: checked ? 1.0 : 0.4
            Behavior on opacity {
                NumberAnimation {
                    id: indicatorOpacityAnimation
                    duration: 200
                    easing.type: Easing.InOutCubic
                }
            }
        }
        Colorize {
            visible: !root.enabled
            anchors.fill: indicator
            source: indicator
            hue: 0.0
            saturation: 0.0
            lightness: 0.0
        }
        states: State {
            when: root.busy
            PropertyChanges { target: indicator; opacity: 1.0 }
        }
        Timer {
            id: busyTimer
            property real brightness: 0.4
            property real falloffRadius: 0.075
            running: busy && Qt.application.active
            interval: 500
            repeat: true
            onRunningChanged: {
                brightness = checked ? 1.0 : 0.4
                falloffRadius = checked ? indicator.defaultFalloffRadius : 0.075
            }
            onTriggered: {
                falloffRadius = falloffRadius === 0.075 ? indicator.defaultFalloffRadius : 0.075
                brightness = brightness == 0.4 ? 1.0 : 0.4
            }
        }
    }
    Label {
        id: label
        width: parent.width - toggle.width - root.leftMargin - root.rightMargin - root._rightPadding
        opacity: root.enabled ? 1.0 : 0.4
        anchors {
            verticalCenter: toggle.verticalCenter
            // center on the first line if there are multiple lines
            verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
            left: toggle.right
        }
        wrapMode: Text.Wrap
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
    Label {
        id: tdesc
        visible: checked || !fdesc.text
        width: label.width
        height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
        opacity: root.enabled && checked ? 1.0 : 0.4
        anchors.top: label.bottom
        anchors.left: label.left
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }
    Label {
        id: fdesc
        visible: !checked
        width: label.width
        height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
        opacity: root.enabled && checked ? 1.0 : 0.4
        anchors.top: label.bottom
        anchors.left: label.left
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }
    Timer {
        id: pressTimer
        interval: Theme.minimumPressHighlightTime
    }

    onPressed: {
        root.DragFilter.begin(mouse.x, mouse.y)
        pressTimer.restart()
    }
    onCanceled: {
        root.DragFilter.end()
        pressTimer.stop()
    }
    onPreventStealingChanged: if (preventStealing) root.DragFilter.end()

    onClicked: {
        if (automaticCheck) {
            checked = !checked
        }
    }

    // for testing
    function _indicator() {
        return indicator
    }
}