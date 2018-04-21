import QtQuick 2.1
import Sailfish.Silica 1.0


Row {
    property alias dateToday: dateButton.dateToday
    property alias customDate: dateButton.customDate
    property alias storedDate: dateButton.storedDate
    signal handleSwitchesCheckedState(bool dateNow, bool customDate)
    width: parent.width
    BackgroundItem {
        width: parent.width / 2
        onClicked: {
            handleSwitchesCheckedState(!dateToday, false)
            storedDate = dateToday == false ? new Date(new Date().getFullYear(),
                                                   new Date().getMonth(),
                                                   new Date().getDate() + 1,
                                                   storedDate.getHours()? storedDate.getHours() : 0,
                                                   storedDate.getMinutes()? storedDate.getMinutes() : 0)
                                        : new Date(new Date().getFullYear(),
                                                   new Date().getMonth(),
                                                   new Date().getDate(),
                                                   storedDate.getHours()? storedDate.getHours() : 0,
                                                   storedDate.getMinutes()? storedDate.getMinutes() : 0)

        }
        Label {
            id: typeLabel
            text: qsTr("Date")
            color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -todayLabel.height/1.5
            anchors.horizontalCenter: parent.right
            font.pixelSize: Theme.fontSizeTiny
            x: Theme.horizontalPageMargin
        }
        Label {
            id: todayLabel
            text: qsTr("Today")
            width: parent.width/2
            color: dateToday && !customDate ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: tomorrowLabel.left
            anchors.rightMargin: 5
            horizontalAlignment: Text.AlignRight
        }

        Label {
            id: tomorrowLabel
            text: qsTr("Tomorrow")
            width: parent.width/2
            color: !dateToday && !customDate ? Theme.highlightColor : Theme.secondaryHighlightColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            horizontalAlignment: Text.AlignRight
        }
    }
    DateButton {
        id: dateButton
        anchors.verticalCenter: parent.verticalCenter
        onClicked: handleSwitchesCheckedState(false, true)
    }
}
