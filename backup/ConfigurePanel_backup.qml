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
