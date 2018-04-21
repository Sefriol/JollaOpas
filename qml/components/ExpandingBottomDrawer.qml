/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Andrew den Exter <andrew.den.exter@jollamobile.com>
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

import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: root

    property bool open
    property bool opened: open || menuProgressAnimation.running

    property real backgroundSize: open ? height / 2 : startPoint

    property alias backgroundItem: backgroundItem
    property alias background: backgroundItem.children

    property alias foregroundItem: foregroundItem
    property alias foreground: foregroundItem.children

    default property alias data: foregroundItem.data

    property bool hideOnMinimize: false
    property bool hideEvent: !Qt.application.active && hideOnMinimize
    property alias custHeight: root.height
    property double startPoint
    onHideEventChanged: {
        if (hideEvent) {
            open = false
            _completeAnimations()
        }
    }
    Behavior on backgroundSize {
        NumberAnimation {
            id: menuProgressAnimation
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    function _completeAnimations() {
        menuProgressAnimation.complete()
        backgroundOpacityAnimation.complete()
    }

    function show(immediate) {
        open = true
        if (immediate) {
            _completeAnimations()
        }
    }

    function hide(immediate) {
        open = false
        if (immediate) {
            _completeAnimations()
        }
    }

    Item {
        id: backgroundClip
        clip: true
        anchors {
            left: root.left
            top: foregroundItem.bottom
            right: root.right
            bottom: root.bottom
        }
        Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba (0, 0, 0, 0); }
                GradientStop { position: 1.0; color: Theme.highlightDimmerColor; }
            }
            anchors.fill: backgroundClip;

        }
        Item {
            id: backgroundItem
            x: 0
            width: root.width
            height: root.backgroundSize
        }
    }

    Rectangle {
        id: dimmerRect
        anchors.fill: foregroundItem
        color: Theme.highlightDimmerColor
        z:1000
        // The dimmed rectangle provides a seam between the background and foreground.  It shouldn't
        // pop in instantly but should be distinct for the majority of the animation so the animation
        // easing is cubic instead of the normal quad.
        opacity: root.open ? 0.5 : 0.0
        Behavior on opacity {
            NumberAnimation {
                id: backgroundOpacityAnimation
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }

    Item {
        id: foregroundItem
        clip: true

        anchors {
            fill: parent
            leftMargin: 0
            topMargin: 0
            rightMargin: 0
            bottomMargin: root.backgroundSize
        }
    }
}
