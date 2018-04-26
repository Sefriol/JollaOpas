TARGET=harbour-jollaopas
include(version.pri)
include(common.pri)
QT            += qml quick
CONFIG        += link_pkgconfig
CONFIG        += sailfishapp
PKGCONFIG     += qdeclarative5-boostable



QML_IMPORT_PATH = qml

OTHER_FILES += \
    qml/js/qmldir \
    qml/pages/qmldir \
    qml/pages/qmldir \
    qml/js/*.js \
    qml/pages/*.qml \
    qml/pages/*/*/.qml \
    qml/pages/*/*/*/.qml \
    qml/components/*/*.qml \
    qml/components/*.qml \
    qml/pages/dialogs/AboutDialog.qml.in \
    qml/main.qml \
    harbour-jollaopas.desktop \
    rpm/harbour-jollaopas.yaml \
    rpm/harbour-jollaopas.spec \
    appicons/86x86/apps/harbour-jollaopas.png \
    appicons/108x108/apps/harbour-jollaopas.png \
    appicons/128x128/apps/harbour-jollaopas.png \
    appicons/256x256/apps/harbour-jollaopas.png


appicons.files = appicons/*
appicons.path = /usr/share/icons/hicolor

INSTALLS += appicons

localization.files = localization
localization.path = /usr/share/$${TARGET}

INSTALLS += localization

lupdate_only{
SOURCES += \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/pages/dialogs/AboutDialog.qml.in \
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
configure($${PWD}/qml/pages/dialogs/AboutDialog.qml.in)

desktop.files = harbour-jollaopas.desktop

DISTFILES += \
#    qml/components/SpaceSeparator.qml \
#    qml/components/DateSwitch.qml \
#    qml/pages/LocationMapPage.qml \
#    qml/pages/SearchAddressPage.qml \
#    qml/components/StatusIndicatorCircle.qml \
#    qml/components/LocationCircle.qml
#    qml/components/CoverTime.qml \
#    qml/components/CustomBottomDrawer.qml \
#    qml/components/Clock.qml \
#    qml/components/qmldir \
#    qml/pages/qmldir \
#    qml/js/qmldir \
#    qml/pages/settings/components/TextIconSwitch.qml \
#    qml/pages/TestPage.qml
