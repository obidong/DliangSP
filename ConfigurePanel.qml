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
  width: 500
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
    if (path.text != "...") {
            alg.settings.setValue("export_preset_path", path.text);
		}
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
      path.reload()
      mayaPortTextInput.reload()
      rendererComboBox.reload()
      formatComboBox.reload()
    }

    AlgScrollView {
      id: scrollView
      anchors.fill: parent

      ColumnLayout {
        spacing: 18
        Layout.maximumWidth: scrollView.viewportWidth
        Layout.minimumWidth: scrollView.viewportWidth

        ColumnLayout {
          spacing: 6
          Layout.fillWidth: true

          AlgLabel {
            text: "Path to export-presets folder"
            Layout.fillWidth: true
          }

          RowLayout {
            spacing: 6
            Layout.fillWidth: true

            AlgTextInput {
              id: path
              borderActivated: true
              wrapMode: TextEdit.Wrap
              readOnly: true
              Layout.fillWidth: true

              function reload() {
                text = alg.settings.value("export_preset_path", "...")
              }

              Component.onCompleted: {
                reload()
              }
            }

            AlgButton {
              id: searchPathButton
              text: "Set path"
              onClicked: {
                // open the search path dialog
                searchPathDialog.setVisible(true)
              }
            }
          }
        }

        RowLayout {
          spacing: 6
          Layout.fillWidth: true

          AlgLabel {
            text: "Default Maya Port"
            Layout.fillWidth: true
          }

          AlgTextInput{
              Layout.fillWidth: true
              id:mayaPortTextInput
              text:"9001"
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
            Layout.fillWidth: true
          }

          AlgComboBox {
            id: rendererComboBox
            Layout.minimumWidth: 150

            model: ListModel {
              id: rendererModel
              ListElement { text: "Arnold" }
              ListElement { text: "Vray" }
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
            text: "Export format"
            Layout.fillWidth: true
          }

          AlgComboBox {
            id: formatComboBox
            Layout.minimumWidth: 150

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
                    }
                }

            }
            /*
            AlgLabel{text:"BaseColor"}
            AlgTextInput{
               id: conf_basecolor_TE
               Layout.fillWidth: true
            }
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_basecolor_TE.text=""}
            }


            AlgLabel{text:"Metallic"}
            AlgTextInput{
                id: conf_metallic_TE
                Layout.fillWidth: true

            }
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_metallic_TE.text=""}
            }

            AlgLabel{text:"Roughness"}
            AlgTextInput{
                id: conf_roughness_TE
               Layout.fillWidth: true

            }
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_roughness_TE.text=""}
            }

            AlgLabel{text:"Normal"}
            AlgTextInput{
                id: conf_normal_TE
                Layout.fillWidth: true

            }
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_normal_TE.text=""}
            }

            AlgLabel{text:"Displacement"}
            AlgTextInput{
                id: conf_displacement_TE
                Layout.fillWidth: true}
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_displacement_TE.text=""}
            }

            AlgLabel{text:"Emissive"}
            AlgTextInput{
                id: conf_emissive_TE
                Layout.fillWidth: true}
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_emissive_TE.text=""}

            }

            AlgLabel{text:"Opacity"}
            AlgTextInput{
                id: conf_opacity_TE
                Layout.fillWidth: true}
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_opacity_TE.text=""}
            }

            AlgLabel{text:"Transmissive"}
            AlgTextInput{
                id: conf_transmissive_TE
                Layout.fillWidth: true}
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_transmissive_TE.text=""}
            }

            AlgLabel{text:"Scattering"}
            AlgTextInput{
                id: conf_scattering_TE
                Layout.fillWidth: true}
            AlgToolButton{
                iconName:"icons/close.png"
                onClicked: {conf_scattering_TE.text=""}
            }
            */
          }

        }
    }
  }



  FileDialog {
    id: searchPathDialog
    title: "Choose the export preset folder..."
    selectFolder: true
    onAccepted: {
      path.text = alg.fileIO.urlToLocalFile(fileUrl.toString())
    }
    onVisibleChanged: {
      if (!visible) {
        configureDialog.requestActivate();
      }
    }
  }
}
