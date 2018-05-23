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
#include <QFileInfo>
#include <QObject>

class Helper : public QObject {
    Q_OBJECT
    public:
    Q_INVOKABLE QString fileNameFromPath (const QString& filePath) const {
        return QFileInfo (filePath).fileName (); // Get the File name from Path
    }

    private:
    // Q_DISABLE_COPY (Helper)
};
