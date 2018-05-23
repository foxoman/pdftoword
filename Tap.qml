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
import QtQuick.Layouts 1.3

Pane {
    id: tapName
    property alias text: tapText.text
    background: Rectangle {
        color: Qt.lighter("#171718")
        border.color: "#171718"
    }
    anchors.fill: parent
    anchors.margins: -5
    clip: true

    ScrollView {
        id: view
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.interactive: true
        ScrollBar.vertical.interactive: true

        Label {
            id: tapText
            text: ""
            //anchors.fill: parent
            onLinkActivated: Qt.openUrlExternally(link)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            lineHeight: 1.4
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            //verticalAlignment: Text.AlignVCenter
            //horizontalAlignment: Text.AlignHCenter
            style: Text.Raised
        }
    }
}
