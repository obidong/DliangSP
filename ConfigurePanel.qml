// Substance Painter Toolkit 1.0
// Copyright (C) 2019 Liang Dong


import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import AlgWidgets 2.0

AlgDialog {
  id: configureDialog
  visible: false
  title: "configure"
  width: 350
  height: 250
  minimumWidth: 300
  minimumHeight: 250
  property var channel_identifier:[
    "ambientOcclusion",
    "anisotropylevel",
    "anisotropyangle",
    "basecolor",
    "blendingmask",
    "diffuse",
    "displacement",
    "emissive",
    "glossiness",
    "height",
    "ior",
    "metallic",
    "normal",
    "opacity",
    "reflection",
    "roughness",
    "scattering",
    "specular",
    "specularlevel",
    "transmissive",
    "user0",
    "user1",
    "user2",
    "user3",
    "user4",
    "user5",
    "user6",
    "user7"  ]
  function reload() {
    content.reload()
  }

  onAccepted: {
        alg.settings.setValue("default_maya_port", mayaPortTextInput.text);

        var renderer_index = rendererComboBox.currentIndex
        alg.settings.setValue("renderer", rendererModel.get(renderer_index).text);

        var format_index = formatComboBox.currentIndex
        alg.settings.setValue("format", formatModel.get(format_index).text);

        for (var i in channel_identifier){
        alg.settings.setValue(channel_identifier[i], channel_identifier_repeater.itemAt(i).children[1].text)
        }
  }

  Rectangle {
    id: content
    parent: contentItem
    anchors.fill: parent
    anchors.margins: 12
    color: "transparent"
    clip: true

    function reload() {
      mayaPortTextInput.reload()
      rendererComboBox.reload()
      formatComboBox.reload()
    }

    AlgScrollView {
      id: scrollView
      anchors.fill: parent

      ColumnLayout {
        spacing: 6
        Layout.maximumWidth: scrollView.viewportWidth
        Layout.minimumWidth: scrollView.viewportWidth

        RowLayout {
          spacing: 6
          Layout.fillWidth: true

          AlgLabel {
            text: "Default Maya Port"
            Layout.minimumWidth: 100
          }

          AlgTextInput{
              Layout.fillWidth: true
              id:mayaPortTextInput
              text:"9001"
              Layout.alignment: Qt.AlignLeft
            function reload() {
              text = alg.settings.value("default_maya_port", "9001");
            }

            Component.onCompleted: {
              reload()
            }
          }
        }

        RowLayout {
          spacing: 6
          Layout.fillWidth: true

          AlgLabel {
            text: "Default Renderer"
            Layout.minimumWidth: 100
          }

          AlgComboBox {
            id: rendererComboBox
            Layout.minimumWidth: 150
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            model: ListModel {
              id: rendererModel
              ListElement { text: "Arnold" }
              ListElement { text: "VRay" }
              ListElement { text: "Renderman_PxrDisney" }
              ListElement { text: "RedShift" }
            }
            function reload() {
              var format = alg.settings.value("renderer", "Arnold");
              for (var i = 0; i < rendererModel.count; ++i) {
                var current = rendererModel.get(i);
                if (format === current.text) {
                  currentIndex = i;
                  break
                }
              }
            }
            Component.onCompleted: {
              reload()
            }
          }
        }

        RowLayout {
          spacing: 6
          Layout.fillWidth: true

          AlgLabel {
            text: "Default Extension"
            Layout.minimumWidth: 100
          }

          AlgComboBox {
            id: formatComboBox
            Layout.minimumWidth: 150
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            model: ListModel {
              id: formatModel
              ListElement { text: "tif" }
              ListElement { text: "png" }
              ListElement { text: "jpg" }
              ListElement { text: "exr" }
              ListElement { text: "bmp" }
              ListElement { text: "tga" }
              ListElement { text: "psd" }
              ListElement { text: "hdr" }
              ListElement { text: "gif" }
            }
            function reload() {
              var format = alg.settings.value("format", "tif");
              for (var i = 0; i < formatModel.count; ++i) {
                var current = formatModel.get(i);
                if (format === current.text) {
                  currentIndex = i;
                  break
                }
              }
            }
            Component.onCompleted: {
              reload()
            }
          }
        }

        GridLayout{
            columns: 3
            Layout.minimumWidth: scrollView.width-15
            columnSpacing: 3
            rowSpacing: 3
            RowLayout{
                Layout.columnSpan: 3
                AlgLabel{
                    text:"Channels"
                    font.weight: Font.Bold
                    Layout.minimumWidth: 100
                }
                AlgLabel{text:"$channel"
                Layout.minimumWidth: 200
                Layout.fillWidth: true
                font.weight: Font.Bold
                }
            }
            Rectangle{
                height:2
                Layout.fillWidth: true
                Layout.columnSpan: 3
                radius:1
                color:"#d6d6d6"
            }
            Repeater{
                id: channel_identifier_repeater
                model: channel_identifier
                RowLayout{
                    Layout.columnSpan: 3
                    AlgLabel{text:modelData
                    Layout.minimumWidth: 100}
                    AlgTextInput{
                        Layout.minimumWidth: 200
                        text:alg.settings.value(modelData)
                        Layout.fillWidth: true
                        tooltip:"$channel will be replaced by the this strings in file name when exporting the specified channel."

                    }
                }
            }
          }

        }
    }
  }
}
