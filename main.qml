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
import QtQuick.Window 2.4
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import Process 1.0
import FileIO 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 280
    height: 350
    title: qsTr("Pdf to Word Converter")

    // Disable ApplicationWindow Scaling
    maximumWidth: 280
    maximumHeight: 350
    minimumHeight: 350
    minimumWidth: 280

    // Always start the app window in the middle of the desktop screen
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    property string fileUrl: "" // Pdf File Path
    property string fileName: "" // Pdf File name
    property string officeBin: "" // LibreOffice Main bin per platform
    // Documents Folder in OS
    property url docFolder: StandardPaths.writableLocation(
                                StandardPaths.DocumentsLocation)
    property string wordType: "docx" // rtf, doc, docx
    property bool terminated: false

    Component.onCompleted: {
        //console.log(docFolder)
        // Setup LibreOffice Main Bin based on OS
        if (Qt.platform.os === "linux") {
            // Linux
            officeBin = "soffice"
        }

        if (Qt.platform.os === "osx") {
            // MacOS
            officeBin = "/Applications/LibreOffice.app/Contents/MacOS/soffice"
        }
    }

    // Command Line Process Interface from C++
    Process {
        id: process
        property string output: ""

        onStarted: {
            stack.clean()
            stack.push(convertPage)
            terminated = false
        }

        onFinished: {
            if (terminated === true) {
                stack.clean()
                stack.push(welcomePage)
                notify.send(qsTr("Conversion Terminated"))
            } else {
                stack.clean()
                stack.push(donePage)
                notify.send(qsTr("Your PDF has been converted"))
            }
        }

        onReadyRead: {
            output = process.readAll()
            //console.log(output)
        }
    }

    /** Notify in Linux ***/
    // FIXME: need to setup notification support in other platform
    Process {
        id: notify

        function send(msg) {
            notify.start("notify-send", [qsTr("PDf to Word"), msg])
        }
    }

    // File Dialog to Select PDF File
    FileDialog {
        id: openDialog
        title: qsTr("Please choose a pdf file")
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        onAccepted: {
            // Get the File path and Name
            fileUrl = file.toString().replace("file://", "")
            fileName = appHelper.fileNameFromPath(file.toString())
            // Push the Confirmation Screen
            stack.clean()
            stack.push(confirmPage)
        }
        nameFilters: ["Pdf files (*.pdf)"]
        // Always choose the Documents Folder based on OS
        folder: docFolder
    }

    // Main Toolbar
    header: ToolBar {
        id: headbar
        height: 35

        // Fix a bug with white line in top of the ToolBar using fusion theme
        Rectangle {
            x: -10
            height: 1
            width: root.width + 10
            color: "#2a2b2c"
        }

        RowLayout {
            anchors.fill: parent

            // Back Button
            ToolButton {
                id: backBtn
                enabled: true
                font.family: "fontAwesome"
                text: {
                    if (stack.currentItem.objectName === "welcomePage") {
                        ""
                    } else {
                        "\uf053"
                    }
                }
                onClicked: {
                    aboutBtn.enabled = true
                    backBtn.enabled = false
                    stack.clean() // Go Back
                }
                font.bold: true
                font.pixelSize: headbar.height / 3
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Back")
            }

            RowLayout {
                Layout.fillWidth: true
                width: headbar.width
                Label {
                    text: "Pdf"
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    font.pixelSize: headbar.height
                    color: Qt.lighter("red")
                    font.bold: true
                    font.family: "Cookie"
                    style: Text.Raised
                }
                Label {
                    text: "to"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    //Layout.fillWidth: true
                    font.pixelSize: headbar.height
                    color: Qt.lighter("gray")
                    font.bold: true
                    font.family: "Cookie"
                    style: Text.Raised
                }
                Label {
                    text: "Word"
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    font.pixelSize: headbar.height
                    color: Qt.lighter("blue")
                    font.bold: true
                    font.family: "Cookie"
                    style: Text.Raised
                }
            }

            // About and Settings page
            ToolButton {
                id: aboutBtn
                font.family: "fontAwesome"
                onClicked: {
                    stack.clean()
                    stack.push(aboutPage)
                }
                font.bold: true

                // Disable it in About Page and keept it enabled in others
                enabled: (stack.currentItem.objectName === "aboutPage") ? false : true
                text: {
                    if (stack.currentItem.objectName === "aboutPage") {
                        ""
                    } else {
                        "\uf013"
                    }
                }

                font.pixelSize: headbar.height / 3
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("About Pdf to Word")
            }
        }
    }

    // Stack veiw to hold the pages view in the screen
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: welcomePage

        function clean() {
            if (stack.depth == 1) {
                return
            }
            // check if target page already is on the stack
            var targetIsUninitialized = false
            if (!stack.get(stack.depth - 2)) {
                targetIsUninitialized = true
            }
            var page = pop()
            if (targetIsUninitialized) {
                stack.currentItem.init()
            }
            // do cleanup from previous page
            //page.cleanup()
        } // popOnePage
    }

    // Welcome Page
    Component {
        id: welcomePage

        Item {
            objectName: "welcomePage"
            Component.onCompleted: {
                aboutBtn.enabled = true
                backBtn.enabled = false
            }
            Item {
                id: welcomePan
                anchors.fill: parent
                anchors.margins: 20

                // Drop Mouse Area
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !dropArea.enabled
                    onContainsMouseChanged: dropArea.enabled = true
                }

                // Drop Area
                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    onEntered: {
                        // Ensure at least one file is supported before accepted the drag
                        // Loop through Multiple Drop Items and select the first valid one
                        for (var i = 0; i < drag.urls.length; i++) {
                            if (validateFileExtension(drag.urls[i])) {
                                fileUrl = drag.urls[i].toString().replace(
                                            "file://", "")
                                fileName = appHelper.fileNameFromPath(
                                            drag.urls[i].toString())
                                // If all ok accsept the drop
                                drag.accepted = true
                                pdficon.color = Qt.lighter("green") // Show green icon
                                pdficon.text = "\uf1c1" // Chaneg the file icon to pdf icon
                                break
                            } else {
                                // Back to default state
                                pdficon.color = "red"
                                pdficon.text = "\uf15b"
                                dropArea.enabled = false
                            }
                        }
                    }

                    onExited: {
                        pdficon.color = "#B2B2B2"
                        pdficon.text = "\uf15b"
                    }

                    onDropped: {
                        pdficon.color = "#B2B2B2"
                        pdficon.text = "\uf15b"
                        stack.clean()
                        stack.push(confirmPage) // Go to confirmPage
                    }

                    // Only pdf
                    function validateFileExtension(filePath) {
                        return filePath.split('.').pop() === "pdf"
                    }
                }

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Welcome to \"Pdf to Word\" Converter\nConvert PDF to editable Word files")
                        Layout.alignment: Qt.AlignHCenter
                        font.bold: true
                        style: Text.Raised
                    }
                    Item {
                        height: 10
                    }

                    // pdf icon
                    Label {
                        id: pdficon
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf15b"
                        font.pixelSize: 80
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                        Behavior on color {
                            ColorAnimation {
                                duration: 1000
                            }
                        }
                    }

                    Item {
                        height: 4
                    }

                    // UP Icon
                    Label {
                        id: upIcon
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf0a6"
                        font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Drag and Drop Here")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        style: Text.Raised
                    }

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Or select a pdf file using your system file browser")
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }

                    // Down Icon
                    Label {
                        id: downIcon
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf0a7"
                        font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }

                    // Select Pdf File Button
                    RoundButton {
                        text: "\uf1c1"
                        font.family: "fontAwesome"
                        highlighted: true
                        onClicked: openDialog.open()
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        //anchors.bottom: welcomePan.bottom
                        anchors.bottomMargin: 1
                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Select a pdf file")
                    }
                }
            }
        }
    }

    // Confirm page
    Component {
        id: confirmPage
        Item {
            objectName: "confirmPage"
            Component.onCompleted: {
                aboutBtn.enabled = true
                backBtn.enabled = true
            }

            Item {
                id: confirmPan
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent
                    // pdf icon
                    Label {
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf1c1"
                        font.pixelSize: 80
                        Layout.alignment: Qt.AlignHCenter
                        color: Qt.lighter("red")
                        style: Text.Raised
                    }
                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Selected PDF File:")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        style: Text.Raised
                    }
                    // file name
                    Label {
                        width: confirmPan.width
                        text: fileName
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: Qt.lighter("red")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        padding: 6
                        horizontalAlignment: Text.AlignHCenter
                        font.italic: true
                        style: Text.Raised
                    }

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("To be converted to: ")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        style: Text.Raised
                    }
                    ButtonGroup {
                        id: radioGroup
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter

                        RadioButton {
                            checked: true
                            text: qsTr("docx")
                            ButtonGroup.group: radioGroup
                            onCheckedChanged: wordType = text
                        }

                        RadioButton {
                            text: qsTr("doc")
                            ButtonGroup.group: radioGroup
                            onCheckedChanged: wordType = text
                        }

                        RadioButton {
                            text: qsTr("rtf")
                            ButtonGroup.group: radioGroup
                            onCheckedChanged: wordType = text
                        }
                    }

                    Item {
                        height: 10
                    }
                    // convert button
                    Button {
                        text: qsTr("Convert")
                        highlighted: true
                        Layout.alignment: Qt.AlignHCenter
                        //anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        onClicked: process.start(
                                       officeBin,
                                       ["--infilter=writer_pdf_import", "--convert-to", wordType, fileUrl, "--outdir", docFolder, "--headless", "--invisible", "--norestore"])
                    }
                }
            }
        }
    }

    // Convert page
    Component {
        id: convertPage
        Item {
            objectName: "convertPage"
            Component.onCompleted: {
                aboutBtn.enabled = false
                backBtn.enabled = false
            }
            Item {
                id: convertPan
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent

                    BlockLoader {
                        Layout.alignment: Qt.AlignHCenter
                        width: 80
                        height: 50
                    }

                    Item {
                        height: 10
                    }

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Converting PDF to WORD")
                        Layout.alignment: Qt.AlignHCenter
                        font.bold: true
                        font.pixelSize: 14
                        style: Text.Raised
                    }

                    // file name
                    Label {
                        width: convertPan.width
                        text: fileName
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: Qt.lighter("red")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        padding: 6
                        horizontalAlignment: Text.AlignHCenter
                        font.italic: true
                        style: Text.Raised
                    }

                    Label {
                        width: convertPan.width
                        text: qsTr("Kindly wait or cancel using the bellow button")
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        padding: 6
                        horizontalAlignment: Text.AlignHCenter
                        style: Text.Raised
                    }
                    Label {
                        id: downIcon
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf0a7"
                        font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }
                    Item {
                        height: 10
                    }
                    // Cancel button
                    Button {
                        text: qsTr("Cancel")
                        highlighted: true
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            process.kill()
                            terminated = true
                        }
                        //anchors.bottom: convertPan.bottom
                        anchors.bottomMargin: 8
                    }
                }
            }
        }
    }

    // Done Page
    Component {
        id: donePage
        Item {
            objectName: "donePage"
            Component.onCompleted: {
                aboutBtn.enabled = true
                backBtn.enabled = true
            }

            Item {
                id: donePan
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Your PDF has been converted")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        style: Text.Raised
                        color: Qt.lighter("green")
                    }

                    // Word Icon
                    Label {
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf1c2"
                        font.pixelSize: 80
                        Layout.alignment: Qt.AlignHCenter
                        color: Qt.lighter("blue")
                        style: Text.Raised
                    }

                    Label {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Generated File: ")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 14
                        font.bold: true
                        style: Text.Raised
                    }

                    // Generated file name
                    Label {
                        text: fileName.replace(".pdf", "." + wordType)
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.italic: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        style: Text.Raised
                        color: Qt.lighter("blue")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        padding: 6
                    }

                    Label {
                        width: donePan.width
                        text: qsTr("Find your generated file in ~Documents\nor open in the default word application")
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        padding: 6
                        horizontalAlignment: Text.AlignHCenter
                        style: Text.Raised
                    }
                    Label {
                        id: downIcon
                        font.family: "fontAwesome"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "\uf0a7"
                        font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }
                    Item {
                        height: 4
                    }
                    // Open genereated file button
                    Button {
                        id: openbtn
                        text: qsTr("Open Generated File")
                        highlighted: true
                        //anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: Qt.openUrlExternally(
                                       docFolder + "/" + fileName.replace(
                                           ".pdf", "." + wordType))
                    }
                }
            }
        }
    }

    // About Page
    Component {
        id: aboutPage
        Item {
            objectName: "aboutPage"
            FileIO {
                id: logFile
                source: ":/change.log"
                onError: console.log(msg)
            }

            FileIO {
                id: translators
                source: ":/translations/translators.log"
                onError: console.log(msg)
            }

            Component.onCompleted: {
                aboutBtn.enabled = false
                backBtn.enabled = true
                logTap.text = logFile.read()
                transTap.text = translators.read()
            }
            Item {
                id: aboutPan
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        text: qsTr("<b>Version:</b> 1.0.0")
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                        style: Text.Raised
                    }

                    // Logo image
                    Image {
                        id: logo
                        source: "pdftoword.png"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 72
                        mipmap: true
                    }

                    TabBar {
                        id: bar
                        width: parent.width

                        TabButton {
                            text: qsTr("About:")
                            width: implicitWidth
                        }

                        TabButton {
                            text: qsTr("License:")
                            width: implicitWidth
                        }

                        TabButton {
                            text: qsTr("Changelog:")
                            width: implicitWidth
                        }

                        TabButton {
                            text: qsTr("Translators:")
                            width: implicitWidth
                        }
                    }

                    StackLayout {
                        width: parent.width
                        currentIndex: bar.currentIndex
                        Tap {
                            id: aboutTap
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: "Pdf to Word is a GUI tool to Libreoffice CMD tool<br /> to convert pdf to Editable word
'rtf', 'doc', 'docx'<br />
" + "<b>Developed By:</b> Sultan Al Isaiee<br /><b><i>foxoman</i></b> @ 2018<br /
>" + "<b>Buy Me a Coffee:</b> <a href=\"https://www.buymeacoffee.com/foxoman\">www.buymeacoffee.com/foxoman</a><br
/>" + "<b>Email:</b> <a href=\"mailto:sultan@foxoman.net\">sultan@foxoman.net</a>"
                        }

                        Tap {
                            id: liTap
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: "GNU GENERAL PUBLIC LICENSE <b>"
                                  + "<a href=\"https://www.gnu.org/licenses/gpl.txt\">GPL-3</a></b><br />"
                        }

                        Tap {
                            id: logTap
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: ""
                        }
                        Tap {
                            id: transTap
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: ""
                        }
                    }

                    Item {
                        height: 4
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        spacing: 12

                        // Google Plus Icon
                        LinkButton {
                            fcode: "\uf0d5"
                            link: "https://plus.google.com/u/0/+SultanAlIsaiee"
                        }

                        // Twitter Icon
                        LinkButton {
                            fcode: "\uf099"
                            link: "https://twitter.com/foxoman"
                        }

                        // Medium Icon
                        LinkButton {
                            fcode: "\uf23a"
                            link: "https://medium.com/@foxoman"
                        }

                        // Github Icon
                        LinkButton {
                            fcode: "\uf09b"
                            link: "https://github.com/foxoman"
                        }
                    }
                    Item {
                        height: 4
                    }
                }
            }
        }
    }
}
