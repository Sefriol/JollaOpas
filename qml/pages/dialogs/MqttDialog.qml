import QtQuick 2.1
import Sailfish.Silica 1.0
import MqttClient 1.0
import "../../components"

Dialog {
    id: mqttOptions
    property variant tempSubscription

    MqttClient {
        id: client
        hostname: hostnameField.text
        port: portField.text
    }

    ListModel {
        id: messageModel
    }

    function addMessage(payload)
    {
        messageModel.insert(0, {"payload" : payload})
        if (messageModel.count >= 100)
            messageModel.remove(99)
    }

    Column {
        height: parent.height/1.5
        id: form
        Row {
            Label {
                text: "Hostname:"
                enabled: !client.connected
            }

            TextField {
                id: hostnameField
    //            text: "broker.hivemq.com"
                text: "mqtt.hsl.fi"
                placeholderText: "<Enter host running MQTT broker>"
                enabled: !client.connected
            }
        }

        Row {
            Label {
                text: "Port:"
                enabled: !client.connected
            }

            TextField {
                id: portField
                text: "443"
                placeholderText: "<Port>"
                inputMethodHints: Qt.ImhDigitsOnly
                enabled: !client.connected
            }
        }

        Button {
            id: connectButton
            text: client.connected ? "Disconnect" : "Connect"
            onClicked: {
                if (client.connected)
                    client.disconnectFromHost()
                else
                    client.connectToHost()
            }
        }

        Row {
            enabled: client.connected
            width: parent.width/2
            Label {
                text: "Topic:"
            }

            TextField {
                width: parent.width/2
                id: subField
                text: "/hfp/v1/journey/ongoing/bus/#"
                placeholderText: "<Subscription topic>"
            }
        }
        Row {
            Button {
                id: subButton
                text: "Subscribe"
                onClicked: {
                    if (subField.text.length === 0)
                        return
                    tempSubscription = client.subscribe(subField.text)
                    tempSubscription.messageReceived.connect(addMessage)
                }
            }
        }
        Label {
            color: (client.connected ? Theme.highlightColor : Theme.secondaryHighlightColor)
            text: "Status: " + (client.connected ? "connected" : "disconnected")
            enabled: client.connected
        }
    }
    SilicaListView {
        id: messageView
        model: messageModel
        anchors.top:form.bottom
        Rectangle {
            color: "black"
            anchors.fill: parent;
        }
        delegate: ListItem {
            id: delegateItem
            width: ListView.view.width
            contentHeight: Theme.itemSizeMedium

            Label {
                id: locName
                color: Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                text: payload
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }
        }
    }
}
