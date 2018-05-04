#ifndef QML_QMQTT_CLIENT_H
#define QML_QMQTT_CLIENT_H

#include <QObject>
#include <QString>
#include <QVector>
#include "../libmqtt/qmqtt.h"
#include "libmqtt/qmqtt_routedmessage.h"
#include <QRegularExpression>
class QmlQmqttSubscription;

class QmlQmqttClient : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString hostname READ hostname WRITE setHostname NOTIFY hostnameChanged)
  Q_PROPERTY(quint16 port READ port WRITE setPort NOTIFY portChanged)
  Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
public:
  explicit QmlQmqttClient(QObject *parent = nullptr);

  ~QmlQmqttClient();

  QString hostname() const
  {
    return m_hostname;
  }

  void setHostname(const QString &h);

  quint16 port() const
  {
    return m_port;
  }

  void setPort(quint16 port);

  bool connected() const
  {
    return m_client != nullptr && m_client->isConnectedToHost();
  }

  Q_INVOKABLE QmlQmqttSubscription *subscribe(const QString &topic);

  Q_INVOKABLE void connectToHost();

  Q_INVOKABLE void disconnectFromHost();

signals:
  void hostnameChanged();

  void portChanged();

  void connectedChanged();

private slots:
  void onConnected();

  void onDisconnected();

  void onDestroyed();

  void onMessageReceived(const QMQTT::Message &message);

private:
  void updateClient();

  QVector<QmlQmqttSubscription *> m_subscriptions;
  QString m_hostname;
  QMQTT::Client *m_client;
  quint16 m_port;
};

class QmlQmqttSubscription : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString topic READ topic)
public:
  QmlQmqttSubscription(const QString &route, QmlQmqttClient *parent) :
    QObject(parent),
    m_topic(route)
  {
      QRegularExpression parameterNamesRegExp(QStringLiteral("\\:([a-zA-Z0-9]+)")); // note how names must not contain dashes or underscores

      // Remove paramter names to get the actual topic "route"
      QString topic = route;
      topic.remove(parameterNamesRegExp);

      // Remove the MQTT wildcards to get a regular expression, which matches the parameters
      QString parameterRegExp = route;
      parameterRegExp
              .remove(QLatin1Char('+'))
              .replace(parameterNamesRegExp, QStringLiteral("([a-zA-Z0-9_-]+)")) // note how parameter values may contain dashes or underscores
              .remove(QLatin1Char('#'))
              .replace(QLatin1String("$"), QLatin1String("\\$"));

      // Extract the parameter names
      QRegularExpressionMatchIterator it = parameterNamesRegExp.globalMatch(route);
      QStringList names;
      while(it.hasNext()) {
          QRegularExpressionMatch match = it.next();
          QString parameterName = match.captured(1);
          names << parameterName;
      }

      m_topic = topic;
      m_parameterNames = names;
      m_regularExpression = QRegularExpression(parameterRegExp);
  }

  QString topic() const
  {
    return m_topic;
  }

signals:
  void messageReceived(const QString &msg);
  void messageReceived(const QHash<QString, QString> &msg);

private:
  QString m_topic;
  bool route = false;
  QRegularExpression m_regularExpression;
  QStringList m_parameterNames;
};

#endif // QML_QMQTT_CLIENT_H
