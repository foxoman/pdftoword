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
#pragma once
#include <QProcess>
#include <QVariant>

class Process : public QProcess {
    Q_OBJECT
    public:
    explicit Process (QObject* parent = Q_NULLPTR) : QProcess (parent) {
    }

    Q_INVOKABLE void start (const QString& program, const QVariantList& arguments) {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess
        for (const auto& temp : arguments) {
            args << temp.toString ();
        }

        QProcess::setProcessChannelMode (QProcess::MergedChannels);
        QProcess::start (program, args);
    }

    Q_INVOKABLE QByteArray readAll () {
        return QProcess::readAll ();
    }

    private:
    Q_DISABLE_COPY (Process)
};
