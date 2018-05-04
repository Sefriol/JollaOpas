#include "qmlmqttclient.h"
#include "libmqtt/qmqtt_routedmessage.h"
#include <QRegularExpression>
#include <QSslConfiguration>

QmlQmqttClient::QmlQmqttClient(QObject *parent) :
    QObject(parent),
    m_client(nullptr),
       m_port(1883)
{
}

QmlQmqttClient::~QmlQmqttClient()
{
    for (QmlQmqttSubscription *s : m_subscriptions)
        delete s;
}

void QmlQmqttClient::setHostname(const QString &h)
{
    if (m_hostname == h)
        return;
    m_hostname = h;
}

void QmlQmqttClient::setPort(quint16 port)
{
    if (m_port == port)
        return;
    m_port = port;
}

QmlQmqttSubscription *QmlQmqttClient::subscribe(const QString &topic)
{
    qWarning() << __func__ << topic;
//    for (QmlQmqttSubscription *sub : m_subscriptions)
//    {
//        if (sub->topic() == topic)
//            return sub;
//    }
    QmlQmqttSubscription *s = new QmlQmqttSubscription(topic, this);
    connect(s, &QmlQmqttSubscription::destroyed, this, &QmlQmqttClient::onDestroyed);
    m_subscriptions.append(s);
    if (m_client != nullptr)
        m_client->subscribe(topic,0);
    return s;
}

void QmlQmqttClient::connectToHost()
{
    updateClient();
    if (m_client == nullptr)
        return;
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
    for (QmlQmqttSubscription *sub : m_subscriptions)
    {
        qWarning() << __func__ << sub->topic();
        // TODO: maybe we need the check to which topics the client has already subscribed itself
        // during previous connection.
        //m_client->subscribe(sub->topic());
    }
    emit connectedChanged();
}

void QmlQmqttClient::onDisconnected()
{
    emit connectedChanged();
}

void QmlQmqttClient::onDestroyed()
{
    QmlQmqttSubscription *s = static_cast<QmlQmqttSubscription *>(sender());
    m_subscriptions.removeOne(s);
    delete s;
}

void QmlQmqttClient::onMessageReceived(const QMQTT::Message &message)
{
    qWarning() << __func__ << message.topic() << message.payload() << m_subscriptions.size();
    for (QmlQmqttSubscription *sub : m_subscriptions)
    {
        qWarning() << __func__ << message.topic() << sub->topic() << ((sub->topic()) == (message.topic()));
        QRegularExpression _regularExpression;
        QStringList _parameterNames;
        QHash<QString, QString> _parameters;
        // The topic in the QmlQmqttSubscription could contain wildcards (eg. a/+/b). If you want
        // to support them, you have the replace the comparison below with something a bit smarter.
        // A regular expression would do. See the RouteSubscription class in QMQTT for an example.
        QString topic = message.topic();
        QRegularExpressionMatch match = _regularExpression.match(topic);
        if (topic.contains(sub->topic().remove(QLatin1Char('#'))))
        {
            for(int i = 0, c = _parameterNames.size(); i < c; ++i) {
                QString name = _parameterNames.at(i);
                QString value = match.captured(i + 1);

                _parameters.insert(name, value);
            }
            //emit sub->messageReceived(message);
            break;
        }
    }
}

void QmlQmqttClient::updateClient()
{
    // TODO: this will always delete m_client, which is necessary only if the hostname or port
    // number have been changed.
    qWarning() << __func__ << m_hostname << m_port;
    if (m_client != nullptr)
    {
        delete m_client;
    }
    if (m_hostname.isEmpty())
    {
        m_client = nullptr;
        return;
    }
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    m_client = new QMQTT::Client(m_hostname, m_port, sslConfig, false, this);
    connect(m_client, &QMQTT::Client::connected, this, &QmlQmqttClient::onConnected);
    connect(m_client, &QMQTT::Client::disconnected, this, &QmlQmqttClient::onDisconnected);
    connect(m_client, &QMQTT::Client::received, this, &QmlQmqttClient::onMessageReceived);
}
