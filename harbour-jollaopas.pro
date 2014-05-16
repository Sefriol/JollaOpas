TARGET=harbour-jollaopas
include(version.pri)
include(common.pri)
QT            += qml quick 
CONFIG        += link_pkgconfig
CONFIG        += sailfishapp
PKGCONFIG     += qdeclarative5-boostable



QML_IMPORT_PATH = qml

OTHER_FILES += \
    qml/js/*.js \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/pages/AboutDialog.qml.in \
    qml/main.qml \
    harbour-jollaopas.desktop \
    rpm/harbour-jollaopas.yaml \
    rpm/harbour-jollaopas.spec


localization.files = localization
localization.path = /usr/share/$${TARGET}

INSTALLS += localization

lupdate_only{
SOURCES += \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/pages/AboutDialog.qml.in \
    qml/main.qml

TRANSLATIONS += \
    localization/fi.ts
}

RESOURCES += \
    jollaopas.qrc

SOURCES += src/main.cpp

INCLUDEPATH += \
    src 


include(version.pri)
include(common.pri)
configure($${PWD}/qml/pages/AboutDialog.qml.in)

icon.files = harbour-jollaopas.png
desktop.files = harbour-jollaopas.desktop
