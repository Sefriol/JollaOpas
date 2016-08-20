import QtQuick 2.1
import Sailfish.Silica 1.0



Item {
    id: clock
    width: clockText.width + Theme.paddingSmall
    property alias font: clockText.font
    property alias running: clockTimer.running

    //Clock logic.
    signal update()
    onUpdate: {
        clockText.text =  new Date().toLocaleTimeString("hh:mm:ss")
    }
    Timer {
        id: clockTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            clock.update()
        }
    }

    Rectangle {
        id: clockRect
        anchors.fill: parent
        color: Theme.highlightColor
        border.color: Theme.primaryColor
        border.width: 1
        opacity: 0.2

        radius: 5
        smooth: true
    }
    Label {
        id: clockText
        opacity: 1.0
        color: Theme.primaryColor
        anchors.horizontalCenter: clockRect.horizontalCenter
        anchors.verticalCenter: clockRect.verticalCenter
    }
}
