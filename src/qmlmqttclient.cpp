#include <QDebug>
#include "qmlmqttclient.h"
#include "qmlmqttsubscription.h"
#include <QSslConfiguration>

QmlQmqttClient::QmlQmqttClient(QObject *parent) :
    QObject(parent)
{
}

QmlQmqttClient::~QmlQmqttClient()
{
    for (QmlQmqttSubscription *subscriber: m_subscriptions) {
        // using deleteLater seems to fix frequent crashes when destructing the client
        subscriber->deleteLater();
    }
}

void QmlQmqttClient::setHostname(const QString &h)
{
    if (m_hostname == h)
        return;
    m_hostname = h;
    m_client.reset();
}

void QmlQmqttClient::setPort(quint16 port)
{
    if (m_port == port)
        return;
    m_port = port;
}

QmlQmqttSubscription *QmlQmqttClient::subscribe(const QString &topicFilter)
{
    for (QmlQmqttSubscription *subscriber: m_subscriptions)
    {
        if (subscriber->topicFilter() == topicFilter)
            return subscriber;
    }
    QmlQmqttSubscription *subscriber = new QmlQmqttSubscription(topicFilter, this);
    connect(subscriber, &QmlQmqttSubscription::destroyed, this, &QmlQmqttClient::onDestroyed);
    m_subscriptions.append(subscriber);
    if (m_client != nullptr)
    {
        qDebug() << "Subscribing to" << topicFilter;
        m_client->subscribe(topicFilter);
    }
    return subscriber;
}

void QmlQmqttClient::unsubscribe(const QString &topicFilter)
{
    for (QmlQmqttSubscription *subscription: m_subscriptions)
    {
        if (subscription->topicFilter() == topicFilter)
        {
            // The onDestroyed function will unsubscribe the topic
            // using deleteLater seems to fix frequent crashes when destructing the client
            subscription->deleteLater();
            return;
        }
    }
    qWarning() << "No QmlQmqttSubscription object found with filter" << topicFilter;
}

void QmlQmqttClient::unsubscribe(QmlQmqttSubscription *subscription)
{
    if (!m_subscriptions.contains(subscription))
    {
        qWarning() << "Cannot unsubscribe, because QmlQmqttSubscription object is not stored here";
        return;
    }
    // The onDestroyed function will unsubscribe the topic
    // using deleteLater seems to fix frequent crashes when destructing the client
    subscription->deleteLater();
    Q_ASSERT(!m_subscriptions.contains(subscription));
}

void QmlQmqttClient::publish(const QString &topic, const QString &message)
{
    if (m_client == nullptr || !m_client->isConnectedToHost())
    {
        qWarning() << "Cannot publish because client is not connected";
    }
    m_client->publish(QMQTT::Message(0, topic, message.toUtf8()));
}

void QmlQmqttClient::connectToHost()
{
    if (m_client == nullptr)
    {
        qDebug() << "Creating MQTT connection with" << m_hostname << m_port;
        // TODO: how to provide QSslConfiguration to the client in case of SSL?

        QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
        m_client.reset(new QMQTT::Client(m_hostname, m_port, sslConfig, false));

        //m_client->setUsername(m_url.userName());
        //m_client->setPassword(m_url.password().toUtf8());
        connect(m_client.data(), &QMQTT::Client::connected, this, &QmlQmqttClient::onConnected);
        connect(m_client.data(), &QMQTT::Client::disconnected, this, &QmlQmqttClient::onDisconnected);
        connect(m_client.data(), &QMQTT::Client::received, this, &QmlQmqttClient::onMessageReceived);
    }
    m_client->setCleanSession(true);
    m_client->connectToHost();
}

void QmlQmqttClient::disconnectFromHost()
{
    if (m_client == nullptr)
        return;
    m_client->disconnectFromHost();
    emit connectedChanged();
}

void QmlQmqttClient::onConnected()
{
    for (QmlQmqttSubscription *subscriber: m_subscriptions)
        m_client->subscribe(subscriber->topicFilter());
    emit connectedChanged();
}

void QmlQmqttClient::onDisconnected()
{
    emit connectedChanged();
}

void QmlQmqttClient::onDestroyed()
{
    QmlQmqttSubscription *subscriber = static_cast<QmlQmqttSubscription *>(sender());
    if (m_client != nullptr)
        m_client->unsubscribe(subscriber->topicFilter());
    m_subscriptions.removeOne(subscriber);
}

void QmlQmqttClient::onMessageReceived(const QMQTT::Message &message)
{
    QList<QmlQmqttSubscription *> matches;
    // This may seem a little paranoia: first we collect all subscriptions which are interested
    // in the message (there may be multiple), and next we emit the signals. We do this, because
    // a slot connected to the signal may cause m_subscriptions to change, which would invalidate
    // its iterators and may crash the loop.
    for (QmlQmqttSubscription *subscriber: m_subscriptions)
    {
        if (subscriber->isMatch(message.topic()))
            matches.append(subscriber);
    }
    if (matches.isEmpty())
    {
        qWarning() << "Message receiver, but no subscriber found. Topic was:" << message.topic();
        return;
    }
    for (QmlQmqttSubscription *subscriber: matches)
    {
        // Check if the subscription is still present in the main list, because it may be removed
        // in a slot connected to QmlQmqttSubscription::messageReceived.
        if (m_subscriptions.contains(subscriber))
            emit subscriber->messageReceived(message.topic(), QString::fromUtf8(message.payload()));
    }
}
