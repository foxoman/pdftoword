/*
    Pdf2Word is a GUI tool to Libreoffice CMD tool to convert pdf to Editable
   word
    'rtf', 'doc', 'docx'
    Copyright (C) <2018>  <Sultan Al-Issai> Aka ~ foxoman
    www.foxoman.net || sultan@foxoman.net

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#include <QApplication>
#include <QFontDatabase>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include "fileio.h"
#include "helper.h"
#include "process.h"

int main (int argc, char* argv[]) {
    QCoreApplication::setAttribute (Qt::AA_EnableHighDpiScaling);
    QApplication app (argc, argv);

    // Set Application Name, Version and Icon
    app.setApplicationName ("PDF to WORD Converter");
    app.setApplicationVersion (APP_VERSION);
    app.setWindowIcon (QIcon (QLatin1String (":/pdftoword.png")));

    QTranslator qtTranslator;
    qtTranslator.load ("pdftoword" + QLocale::system ().name (),
                       ":/translations/");
    app.installTranslator (&qtTranslator);

    // Load fonts
    QFontDatabase::addApplicationFont (
    QStringLiteral (":/fontawesome-webfont.ttf"));
    QFontDatabase::addApplicationFont (QStringLiteral (":/Cookie-Regular.ttf"));

    // Start QML Engine
    QQmlApplicationEngine engine;

    // Helper Class as QML Context
    Helper helper;
    engine.rootContext ()->setContextProperty ("appHelper", &helper);

    // Qt Command Line Process Class as QML Object
    qmlRegisterType<Process> ("Process", 1, 0, "Process");

    // File Read and write
    qmlRegisterType<FileIO, 1> ("FileIO", 1, 0, "FileIO");


    // Load Main QML File
    engine.load (QUrl (QLatin1String ("qrc:/main.qml")));

    if (engine.rootObjects ().isEmpty ()) {
        return -1;
    }

    return app.exec ();
}
