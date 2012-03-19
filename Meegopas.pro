# Add more folders to ship with the application, here
harmattan_qml.source = qml/harmattan
harmattan_qml.target = qml
symbian_qml.source = qml/symbian
symbian_qml.target = qml
common_qml.source = qml/common
common_qml.target = qml
images.source = images
loc.source = i18n
DEPLOYMENTFOLDERS = common_qml images loc

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = qml/common qml/symbian qml/harmattan qml

symbian {
    TARGET.UID3 = 0x2004bf5e
    # DEPLOYMENTFOLDERS += symbian_qml
    # Smart Installer package's UID
    # This UID is from the protected range and therefore the package will
    # fail to install if self-signed. By default qmake uses the unprotected
    # range value if unprotected UID is defined for the application and
    # 0x2002CCCF value if protected UID is given to the application
    # DEPLOYMENT.installer_header = 0x2002CCCF
    DEPLOYMENT.installer_header = 0x2002CCCF

    VERSION = 1.2.0

    # Allow network access on Symbian
    TARGET.CAPABILITY += NetworkServices Location

    vendorinfo = "%{\"JukkaNousiainen\"}" ":\"JukkaNousiainen\""

    my_deployment.pkg_prerules = vendorinfo
    my_deployment.pkg_prerules += "(0x200346de), 1, 1, 0, {\"Qt Quick components for Symbian\"}"

    DEPLOYMENT += my_deployment

    CONFIG += qt-components

    RESOURCES += \
        symbian.qrc
}

contains(MEEGO_EDITION, harmattan) {
    # add harmattan specific qml
    DEPLOYMENTFOLDERS += harmattan_qml

    # Speed up launching on MeeGo/Harmattan when using applauncherd daemon
    CONFIG += qdeclarative-boostable

    # for MLocale
    CONFIG += meegotouch

    # D-Bus service
    dbusservice.path = /usr/share/dbus-1/services
    dbusservice.files = com.juknousi.meegopas.service
    dbusinterface.path = /usr/share/dbus-1/interfaces
    dbusinterface.files = com.juknousi.meegopas.xml
    INSTALLS += dbusservice dbusinterface

    # splash screen
    splash.files = splash.png splash-l.png
    splash.path = /usr/share/$${TARGET}/
    INSTALLS += splash

    OTHER_FILES += \
        qtc_packaging/debian_harmattan/rules \
        qtc_packaging/debian_harmattan/README \
        qtc_packaging/debian_harmattan/manifest.aegis \
        qtc_packaging/debian_harmattan/copyright \
        qtc_packaging/debian_harmattan/control \
        qtc_packaging/debian_harmattan/compat \
        qtc_packaging/debian_harmattan/changelog

    RESOURCES += \
        harmattan.qrc
}

simulator {
    DEPLOYMENTFOLDERS += symbian_qml

    RESOURCES += \
        symbian.qrc
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += location systeminfo

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += src/main.cpp \
    src/shortcut.cpp \
    src/route.cpp \
    src/meegopasadaptor.cpp

HEADERS += \
    include/shortcut.h \
    include/route.h \
    include/meegopasadaptor.h

INCLUDEPATH += src \
    include

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

TRANSLATIONS += meegopas_fi_FI.ts \
                meegopas_ru_RU.ts



OTHER_FILES += \
    com.juknousi.meegopas.service \
    com.juknousi.meegopas.xml \
    Meegopas_harmattan.desktop










