/*
 * This file was generated by qdbusxml2cpp version 0.7
 * Command line was: qdbusxml2cpp com.juknousi.meegopas.xml -a meegopasadaptor -c MeegopasAdaptor -l Route -i route.h
 *
 * qdbusxml2cpp is Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#ifndef MEEGOPASADAPTOR_H_1336347858
#define MEEGOPASADAPTOR_H_1336347858

#include <QtCore/QObject>
#include <QtDBus/QtDBus>
#include "route.h"
class QByteArray;
template<class T> class QList;
template<class Key, class Value> class QMap;
class QString;
class QStringList;
class QVariant;

/*
 * Adaptor class for interface com.juknousi.meegopas
 */
class MeegopasAdaptor: public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.juknousi.meegopas")
    Q_CLASSINFO("D-Bus Introspection", ""
"  <interface name=\"com.juknousi.meegopas\">\n"
"    <method name=\"route\">\n"
"      <arg direction=\"in\" type=\"s\" name=\"name\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"coord\"/>\n"
"    </method>\n"
"    <method name=\"cycling\">\n"
"      <arg direction=\"in\" type=\"s\" name=\"name\"/>\n"
"      <arg direction=\"in\" type=\"s\" name=\"coord\"/>\n"
"    </method>\n"
"  </interface>\n"
        "")
public:
    MeegopasAdaptor(Route *parent);
    virtual ~MeegopasAdaptor();

    inline Route *parent() const
    { return static_cast<Route *>(QObject::parent()); }

public: // PROPERTIES
public Q_SLOTS: // METHODS
    void cycling(const QString &name, const QString &coord);
    void route(const QString &name, const QString &coord);
Q_SIGNALS: // SIGNALS
};

#endif