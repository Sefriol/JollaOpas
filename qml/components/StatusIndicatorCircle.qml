import QtQuick 2.1
import Sailfish.Silica 1.0
Rectangle {
    id: statusIndicator
    smooth: true
    radius: 10 * Theme.pixelRatio
    height: 20 * Theme.pixelRatio
    width: 20 * Theme.pixelRatio
    opacity: 0.6
    property variant validateState
    property variant sufficientState
    property variant busyState
    property bool tinyIndicator


    state: validateState ? "validated" : sufficientState ? "sufficient" : "error"
    states: [
        State {
            name: "error"
            PropertyChanges { target: statusIndicator; color: "red" }
        },
        State {
            name: "sufficient"
            PropertyChanges { target: statusIndicator; color: "yellow" }
        },
        State {
            name: "validated"
            PropertyChanges { target: statusIndicator; color: "green" }
        }
    ]
    transitions: [
        Transition {
            ColorAnimation { duration: 100 }
        }
    ]
    BusyIndicator {
        id: busyIndicator
        running: busyState ? busyState : false
        anchors.centerIn: statusIndicator // Place this similarly to statusIndicator
        size: tinyIndicator ? BusyIndicatorSize.ExtraSmall : BusyIndicatorSize.Small
    }
}
