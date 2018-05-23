/*
    Pdf2Word is a GUI tool to Libreoffice CMD tool to convert pdf to Editable word
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
import QtQuick 2.11
import QtQuick.Controls 2.4

RoundButton {
    id: btn
    property alias fcode: btn.text
    property alias link: btn.link
    property string link: ""
    font.family: "fontAwesome"
    text: ""
    onClicked: Qt.openUrlExternally(
                   link)
    hoverEnabled: true
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: hovered
    ToolTip.text: link
    //highlighted: true
}
