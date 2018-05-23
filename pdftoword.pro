TARGET = pdftoword
#target.path = /usr/bin
#INSTALLS += target
TEMPLATE = app
#data.path = /usr/share/pdftoword/data
#data.files = data/*
#INSTALLS += data

#Application version
VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_BUILD = 0
VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}
QMAKE_TARGET_COMPANY = "Foxoman"
QMAKE_TARGET_PRODUCT = "PDF to WORD Converter"
QMAKE_TARGET_DESCRIPTION = "Convert pdf to editable word file"
QMAKE_TARGET_COPYRIGHT = "Foxoman @2018"
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += "VERSION_MAJOR=$$VERSION_MAJOR"\
       "VERSION_MINOR=$$VERSION_MINOR"\
       "VERSION_BUILD=$$VERSION_BUILD"

QT += quick
QT += core gui
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG += c++11 release

CONFIG += qtquickcompiler

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
    fileio.cpp
HEADERS += process.h \
    helper.h \
    fileio.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

DESTDIR = ./bin
MOC_DIR = ./build/moc
RCC_DIR = ./build/rcc
UI_DIR = ./build/ui
unix:OBJECTS_DIR = ./build/o/unix
win32:OBJECTS_DIR = ./build/o/win32
macx:OBJECTS_DIR = ./build/o/mac

lupdate_only{
SOURCES = *.qml
}

LANGUAGES = en ar

# parameters: var, prepend, append
defineReplace(prependAll) {
 for(a,$$1):result += $$2$${a}$$3
 return($$result)
}

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/translations/pdftoword, .ts)


TRANSLATIONS_FILES =

qtPrepareTool(LRELEASE, lrelease)
for(tsfile, TRANSLATIONS) {
 qmfile = $$shadowed($$tsfile)
 qmfile ~= s,.ts$,.qm,
 qmdir = $$dirname(qmfile)
 !exists($$qmdir) {
 mkpath($$qmdir)|error("Aborting.")
 }
 command = $$LRELEASE -removeidentical $$tsfile -qm $$qmfile
 system($$command)|error("Failed to run: $$command")
 TRANSLATIONS_FILES += $$qmfile
}



QMAKE_CXX = ccache g++ #use ccache to speed up compilation, install sudo apt install ccache
#QMAKE_CXXFLAGS += -g
QMAKE_CFLAGS += -j #multicore cpu

# additional flags for Windows
win32 {
    # increase system stack size (helpful for recursive programs)
    QMAKE_LFLAGS += -Wl,--stack,268435456
    LIBS += -lDbghelp
    LIBS += -lbfd
    LIBS += -limagehlp
}

# additional flags for Mac OS X
macx {
    # increase system stack size (helpful for recursive programs)
    # (this was previously disabled because it led to crashes on some systems,
    #  but it seems to be working again, so we are going to re-enable it)
    # QMAKE_LFLAGS += -Wl,-stack_size,0x4000000

    # calling cache() reduces warnings on Mac OS X systems
    cache()
    QMAKE_MAC_SDK = macosx
}

# additional flags for Linux
unix:!macx {
    unix-g++ {
        QMAKE_CXXFLAGS += -rdynamic
        QMAKE_CXXFLAGS += -Wl,--export-dynamic
    }

    QMAKE_LFLAGS += -rdynamic
    QMAKE_LFLAGS += -Wl,--export-dynamic
}

CONFIG(release, debug|release) {
    #This is a release build
    DEFINES += QT_NO_DEBUG_OUTPUT
    QMAKE_CXXFLAGS_RELEASE += -Os -mpreferred-stack-boundary=4 -finline-small-functions -momit-leaf-frame-pointer
    QMAKE_CXXFLAGS_RELEASE -= -Os
    QMAKE_CXXFLAGS_RELEASE -= -O1
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS_RELEASE *= -O3 # Faster App on Released
    QMAKE_LFLAGS_RELEASE -= -O1

    QMAKE_CFLAGS -= -O2
    QMAKE_CFLAGS -= -O1
    QMAKE_CXXFLAGS -= -O2
    QMAKE_CXXFLAGS -= -O1
    QMAKE_CFLAGS = -m64 -O3
    QMAKE_LFLAGS = -m64 -O3
    QMAKE_CXXFLAGS = -m64 -O3
} else {
    #This is a debug build
    # required if you want to see qDebug() messages
    CONFIG += debug

    QMAKE_CXXFLAGS += -g3
    #QMAKE_CXXFLAGS += -O0
    #QMAKE_CXXFLAGS += -ggdb3
    QMAKE_CXXFLAGS += -fno-inline
    QMAKE_CXXFLAGS += -fno-omit-frame-pointer
}

# This time we do not use the LIBS variable but PKGCONFIG,
# which relies on pkg-config . It is a helper tool that will
# insert the correct options into the compile command line.
# Ex. we will request pkg-config to link our project with OpenCV.
#     PKGCONFIG += opencv
# You can list all the libs managed by pkg-config with the:
#     pkg-config--list-all
# command.
linux{
    CONFIG += link_pkgconfig
    PKGCONFIG +=
}
