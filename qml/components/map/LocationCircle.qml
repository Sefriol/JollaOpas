import QtQuick 2.1
import Sailfish.Silica 1.0
Rectangle {
    id: locationCircle
    smooth: true
    radius: 10 * Theme.pixelRatio
    height: 15 * Theme.pixelRatio
    width: 15 * Theme.pixelRatio
    opacity: 0.6
    color: "red"
    BusyIndicator {
        running: true
        anchors.centerIn: statusIndicator // Place this similarly to statusIndicator
        size: BusyIndicatorSize.ExtraSmall
        color: "red"
    }
}
