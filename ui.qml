import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import AlgWidgets 1.0

Button {
  id: root
  antialiasing: true
  width: 30; height: 30
  tooltip: "Load dliang tool"
  property bool loading: false
  property var fbxPath:null
  property var exportPath:null
  style: ButtonStyle {
    background: Rectangle {
      width: control.width; height: control.height
      color: "transparent"
      Image {
        source: control.hovered && !control.loading ? "icons/load_tool_on.png" : "icons/load_tool_off.png"
        fillMode: Image.PreserveAspectFit
        width: control.width; height: control.height
        mipmap: true
        opacity: control.loading ? 0.5 : 1
      }
    }
  }

  onClicked: {
      try{
          if(alg.project.isOpen()){
              dliang_sp_tools.initParams()
          }
          dliang_sp_tools.visible = true
          dliang_sp_tools.refreshInterface()
          dliang_sp_tools.raise()
          dliang_sp_tools.requestActivate()

      }catch(err){
          alg.log.exception(err)
      }
  }

  AlgWindow{
    id: dliang_sp_tools
    title: "Dliang SP Tool Kit"
    visible: false
    width: 250
    height: 400
    minimumWidth: 300
    minimumHeight: 400

    flags: Qt.Window
      | Qt.WindowTitleHint
      | Qt.WindowSystemMenuHint
      | Qt.WindowMinMaxButtonsHint
      | Qt.WindowCloseButtonHint // close button


    function initParams(){
        return
    }
    function refreshInterface() {
      try {
        if (!dliang_sp_tools.visible) {
          return
        }
      } catch(err) {
        alg.log.exception(err)
      }
    }

    function getExt(ext){
      if(ext == "jpeg"){
        return "jpg"
      }else if (ext == "pbmraw"){
        return "pbm"
      }else if (ext == "pgmraw"){
        return "pgm"
      }else if (ext == "ppmraw"){
        return "ppm"
      }else if (ext == "targa"){
        return "tga"
      }else if (ext == "tiff"){
        return "tif"
      }else if (ext == "wbmp"){
        return "wap"
      }else if (ext == "jpeg-xr"){
        return "jxr"
      }else{
        return ext
      }
    }


    function getParams(){
          return {
          out_path : p_output,
        udims : check_udims.checked &&  combo_software.currentText != "Blender" &&  combo_software.currentText != "Cinema 4D"? 1: 0,
        sw : combo_software.currentText,
        houpath: txt_houpath.text,
        port : txt_port.text,
        rndr : combo_renderer.currentText,
        res :parseInt(combo_resolution.currentText),
        ext : getExt( combo_format.currentText),
        main_bit : parseInt(combo_main_bitdepth.currentText),
        normal_bit : parseInt(combo_normal_bitdepth.currentText),
        height_bit : parseInt(combo_height_bitdepth.currentText),
        packed :  check_packed.checked ? 1: 0,
        normal : combo_normal.currentText == "Open GL" ? 1: 0
        }
      }


ColumnLayout{
    id: main_layout
    anchors.topMargin: 10
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top

    GridLayout{
      id: create_channel_layout
      anchors.topMargin: 10
      columns: 2
      columnSpacing: 10

      Rectangle{
          Layout.fillWidth: true
          Layout.columnSpan: 2
              color: "#ffffff"
              height: 1
          }

      AlgLabel {
        id: channel_name_label
              text: " channel name:"
      }
      AlgTextInput{
        id:channel_name_txt
        Layout.fillWidth: true
        text: ""
      }
      AlgLabel {
        id: use_slot_label
              text: " use slot:"
      }
      AlgComboBox {
        id: channels_CB
        Layout.fillWidth: true
        model: ListModel {
              id: channels_LE

              ListElement { text: "ambientOcclusion" }
              ListElement { text: "anisotropylevel" }
              ListElement { text: "anisotropyangle" }
              ListElement { text: "basecolor" }
              ListElement { text: "blendingmask" }
              ListElement { text: "diffuse" }
              ListElement { text: "displacement" }
              ListElement { text: "emissive" }
              ListElement { text: "glossiness" }
              ListElement { text: "height" }
              ListElement { text: "ior" }
              ListElement { text: "metallic" }
              ListElement { text: "normal" }
              ListElement { text: "opacity" }
              ListElement { text: "reflection" }
              ListElement { text: "roughness" }
              ListElement { text: "scattering" }
              ListElement { text: "specular" }
              ListElement { text: "specularlevel" }
              ListElement { text: "transmissive" }
              ListElement { text: "user0" }
              ListElement { text: "user1" }
              ListElement { text: "user2" }
              ListElement { text: "user3" }
              ListElement { text: "user4" }
              ListElement { text: "user5" }
              ListElement { text: "user6" }
              ListElement { text: "user7" }


        }
      }
      AlgLabel {
        id: channel_info_label
              text: " channel info:"
      }
      AlgComboBox {
        id: channel_info_CB
        Layout.fillWidth: true
        model: ListModel {
              id: channel_info_LE

              ListElement { text: "sRGB8" }
              ListElement { text: "L8" }
              ListElement { text: "RGB8" }
              ListElement { text: "L16" }
              ListElement { text: "RGB16" }
              ListElement { text: "L16F" }
              ListElement { text: "RGB16F" }
              ListElement { text: "L32F" }
              ListElement { text: "RGB32F" }
        }
      }
      AlgButton{
          id: create_channel_button
          Layout.fillWidth: true
          Layout.columnSpan: 2
        text: "Create Channel"
        Layout.preferredHeight: 30
          onClicked:{
              try{
                var current_textureset = alg.texturesets.getActiveTextureSet()[0]
                var current_slot = channels_CB.currentText
                var channel_info = channel_info_CB.currentText
                var texture_label = channel_name_txt.text
                alg.texturesets.addChannel(current_textureset, current_slot,channel_info,texture_label)

              }catch(err){
                  alg.log.exception(err)
              }
          }
      }
    }


    GridLayout{
      id: set_channel_layout
      columns: 2
          columnSpacing: 10
          //anchors.horizontalCenter: parent.horizontalCenter
          //anchors.top: parent.top
          //anchors.topMargin: 50

      //------ UDIMS ------
      AlgLabel {
        id: lbl_udims
              text: "UDIMs:"
              visible: combo_software.currentText != "Blender" && combo_software.currentText != "Cinema 4D" ? 1:0
      }
      AlgCheckBox {
        id: check_udims
        checked: false
              visible: combo_software.currentText != "Blender" && combo_software.currentText != "Cinema 4D"? 1:0
              onCheckedChanged:{
                  if(alg.project.isOpen()){
                      alg.project.settings.setValue("hh_udims", check_udims.checked)
                  }
              }
      }



      //------ TARGET SOFTWARE ------
        AlgLabel {
          id: lbl_software
              text: "Software:"
        }
        AlgComboBox {
          id: combo_software
              model: ListModel {
                      id: modelSW
                      ListElement { text: "Blender" }
            ListElement { text: "Cinema 4D" }
                      ListElement { text: "Houdini" }
                      ListElement { text: "Maya" }
                      ListElement { text: "Modo" }
                      ListElement { text: "3DS Max" }
              }
              onCurrentTextChanged:{
                  if(alg.project.isOpen()){
                      alg.project.settings.setValue("hh_software",  combo_software.currentText)
                  }
              }
        }


    //------ Houdini Path -----test
    AlgLabel {
      id:lbl_houpath
      text: "Houdini Path:"
      visible: combo_software.currentText == "Houdini"? 1:0
    }
    AlgTextInput{
      id:txt_houpath
      text: "shop/"
      Layout.preferredWidth: 125
      visible: combo_software.currentText == "Houdini"? 1:0
      onTextChanged:{
        if(alg.project.isOpen()){
          alg.project.settings.setValue("hh_houpath",  txt_houpath.text)
        }
      }
    }


      //------ CONNECTION PORT ------
        AlgLabel {
          id: lbl_port
              text: "Port:"
              visible: combo_software.currentText != "Blender" && combo_software.currentText != "Cinema 4D"? 1:0
        }
          AlgTextInput{
              id:txt_port
              text: combo_software.currentText == "Houdini"?"18811":"8080"
              Layout.preferredWidth: 125
              visible: combo_software.currentText != "Blender" && combo_software.currentText != "Cinema 4D"? 1:0
              onTextChanged:{
                  if(alg.project.isOpen()){
                      alg.project.settings.setValue("hh_port",  txt_port.text)
                  }
              }
          }


      //------ RENDERER TARGET ------
        AlgLabel {
          id: lbl_renderer
              text: "Renderer:"
        }
        AlgComboBox {
          id: combo_renderer
        property var c4d_rndr: ListModel {
            id: mod_render_c4d
            ListElement { text: "ARNOLD" }
            ListElement { text: "REDSHIFT" }
        }
              property var modo_rndr: ListModel {
                      id: mod_render_modo
                      ListElement { text: "MODO" }
                      ListElement { text: "UE4" }
                      ListElement { text: "UNITY" }
              }
              property var maya_rndr: ListModel {
                      id: mod_render_maya
                      ListElement { text: "ARNOLD" }
                      ListElement { text: "REDSHIFT" }
            ListElement { text: "RENDERMAN" }
                      ListElement { text: "VRAY" }
              }
              property var blender_rndr: ListModel {
                      id: mod_render_blender
                      ListElement { text: "2.79" }
                      ListElement { text: "2.80" }
              }
              property var max_rndr: ListModel {
                      id: mod_render_max
            ListElement { text: "ARNOLD" }
                      ListElement { text: "CORONA" }
                      ListElement { text: "REDSHIFT" }
            ListElement { text: "VRAY" }
              }
              property var houdini_rndr: ListModel {
                      id: mod_render_houdini
            ListElement { text: "ARNOLD" }
                      ListElement { text: "REDSHIFT" }
            ListElement { text: "RENDERMAN" }
              }
              model: combo_software.currentText == "Cinema 4D" ? mod_render_c4d:combo_software.currentText == "Modo" ? mod_render_modo: combo_software.currentText == "Maya" ? mod_render_maya : combo_software.currentText == "3DS Max" ? mod_render_max : combo_software.currentText == "Houdini" ? mod_render_houdini : mod_render_blender
              onCurrentTextChanged:{
                  if(alg.project.isOpen()){
                      alg.project.settings.setValue("hh_renderer",  combo_renderer.currentText)
                  }
              }
        }

      Rectangle{
        Layout.fillWidth: true
              Layout.columnSpan: 2
        color: "#ffffff"
        height: 1
      }


      //------ RESOLUTION ------
        AlgLabel {
          id: lbl_resolution
              text: "Resolution:"
        }
        AlgComboBox {
          id: combo_resolution
              model: ListModel {
                          id: mod_resolution
                          ListElement { text: "128" }
                          ListElement { text: "256" }
                          ListElement { text: "512" }
                          ListElement { text: "1024" }
                          ListElement { text: "2048" }
                          ListElement { text: "4096" }
                          ListElement { text: "8192" }
              }
              onCurrentTextChanged:{
                  if(alg.project.isOpen()){
                      alg.project.settings.setValue("hh_resolution",  combo_resolution.currentText)
                  }
              }
        }

      //------ FORMAT ------
      AlgLabel {
        id: lbl_format
        text: "Format:"
      }
      AlgComboBox {
        id: combo_format
        model: ListModel {
              id: mod_format
              ListElement { text: "bmp" } //bmp
              ListElement { text: "ico" } //ico
              ListElement { text: "jpeg" } //jpg
              ListElement { text: "jng" } //jng
              ListElement { text: "pbm" } //pbm
              ListElement { text: "pbmraw" } //pbm
              ListElement { text: "pgm" } //pgm
              ListElement { text: "pgmraw" } //pgm
              ListElement { text: "png" } //png
              ListElement { text: "ppm" } //ppm
              ListElement { text: "ppmraw" } //ppm
              ListElement { text: "targa" } //tga
              ListElement { text: "tiff" } //tif
              ListElement { text: "wbmp" } //wap
              ListElement { text: "xpm" } //xpm
              ListElement { text: "gif" } //gif
              ListElement { text: "hdr" } //hdr
              ListElement { text: "exr" } //exr
              ListElement { text: "j2k" } //j2k
              ListElement { text: "jp2" } //jp2
              ListElement { text: "pfm" } //pfm
              ListElement { text: "webp" } //webp
              ListElement { text: "jpeg-xr" } //jxr
              ListElement { text: "psd" } //psd
        }
        onCurrentTextChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_format",   combo_format.currentText)
          }
        }
      }


      //------ NORMAL FORMAT ------
      AlgLabel {
        id:lbl_normal
        text: "Normal Format:"
      }
      AlgComboBox {
        id:combo_normal
        model: ListModel {
            id: modelNormal
            ListElement { text: "Open GL" }
            ListElement { text: "Direct X" }
        }
        onCurrentTextChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_normal",  combo_normal.currentText)
          }
        }
      }

      //------ PACKED ------
      AlgLabel {
        id: lbl_packed
        text: "Packed Textures:"
      }
      AlgCheckBox {
        id: check_packed
        checked: true
        onCheckedChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_packed",  check_packed.checked)
          }
        }
      }

      Rectangle{
        Layout.fillWidth: true
              Layout.columnSpan: 2
        color: "#ffffff"
        height: 1
      }


      //------ MAIN BITDEPTH ------
      AlgLabel {
        id:lbl_main_bitdepth
        text: "Main Bitdepth:"
      }
      AlgComboBox {
        id: combo_main_bitdepth

        property var main_8_depth: ListModel {
            id: mod_main_8_depth
            ListElement { text: "8" }
        }
        property var main_8_16_depth: ListModel {
            id: mod_main_8_16_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
        }
        property var main_8_16_32_depth: ListModel {
            id: mod_main_8_16_32_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
            ListElement { text: "32" }
        }

        property var main_32_depth: ListModel {
            id: mod_main_32_depth
            ListElement { text: "32" }
        }

        model:
          combo_format.currentText == "bmp" ||
          combo_format.currentText == "ico" ||
          combo_format.currentText == "jpeg" ||
          combo_format.currentText == "jng" ||
          combo_format.currentText == "targa" ||
          combo_format.currentText == "wbmp" ||
          combo_format.currentText == "xpm" ||
          combo_format.currentText == "gif" ||
          combo_format.currentText == "webp" ? main_8_depth

          :combo_format.currentText == "pbm" ||
          combo_format.currentText == "pbmraw" ||
          combo_format.currentText == "pgm" ||
          combo_format.currentText == "pgmraw" ||
          combo_format.currentText == "png" ||
          combo_format.currentText == "ppm" ||
          combo_format.currentText == "ppmraw" ||
          combo_format.currentText == "j2k" ||
          combo_format.currentText == "jp2" ||
          combo_format.currentText == "psd" ? main_8_16_depth

          :combo_format.currentText == "tiff" ||
          combo_format.currentText == "jpeg-xr"? main_8_16_32_depth

          :combo_format.currentText == "hdr" ||
          combo_format.currentText == "exr" ||
          combo_format.currentText == "pfm"? main_32_depth
          :main_8_depth
        onCurrentTextChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_main_bitdepth",   combo_main_bitdepth.currentText)
          }
        }
      }


      //------ NORMAL BITDEPTH ------
      AlgLabel {
        id:lbl_normal_bitdepth
        text: "Normal Bitdepth:"
      }
      AlgComboBox {
        id: combo_normal_bitdepth

        property var normal_8_depth: ListModel {
            id: mod_normal_8_depth
            ListElement { text: "8" }
        }
        property var normal_8_16_depth: ListModel {
            id: mod_normal_8_16_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
        }
        property var normal_8_16_32_depth: ListModel {
            id: mod_normal_8_16_32_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
            ListElement { text: "32" }
        }

        property var normal_32_depth: ListModel {
            id: mod_normal_32_depth
            ListElement { text: "32" }
        }

        model:
          combo_format.currentText == "bmp" ||
          combo_format.currentText == "ico" ||
          combo_format.currentText == "jpeg" ||
          combo_format.currentText == "jng" ||
          combo_format.currentText == "targa" ||
          combo_format.currentText == "wbmp" ||
          combo_format.currentText == "xpm" ||
          combo_format.currentText == "gif" ||
          combo_format.currentText == "webp" ? normal_8_depth

          :combo_format.currentText == "pbm" ||
          combo_format.currentText == "pbmraw" ||
          combo_format.currentText == "pgm" ||
          combo_format.currentText == "pgmraw" ||
          combo_format.currentText == "png" ||
          combo_format.currentText == "ppm" ||
          combo_format.currentText == "ppmraw" ||
          combo_format.currentText == "j2k" ||
          combo_format.currentText == "jp2" ||
          combo_format.currentText == "psd" ? normal_8_16_depth

          :combo_format.currentText == "tiff" ||
          combo_format.currentText == "jpeg-xr"? normal_8_16_32_depth

          :combo_format.currentText == "hdr" ||
          combo_format.currentText == "exr" ||
          combo_format.currentText == "pfm"? normal_32_depth
          :normal_8_depth
        onCurrentTextChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_normal_bitdepth",   combo_normal_bitdepth.currentText)
          }
        }
      }



      //------ HEIGHT BITDEPTH ------
      AlgLabel {
        id:lbl_height_bitdepth
        text: "Height Bitdepth:"
      }
      AlgComboBox {
        id: combo_height_bitdepth

        property var height_8_depth: ListModel {
            id: mod_height_8_depth
            ListElement { text: "8" }
        }
        property var height_8_16_depth: ListModel {
            id: mod_height_8_16_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
        }
        property var height_8_16_32_depth: ListModel {
            id: mod_height_8_16_32_depth
            ListElement { text: "8" }
            ListElement { text: "16" }
            ListElement { text: "32" }
        }

        property var height_32_depth: ListModel {
            id: mod_height_32_depth
            ListElement { text: "32" }
        }

        model:
          combo_format.currentText == "bmp" ||
          combo_format.currentText == "ico" ||
          combo_format.currentText == "jpeg" ||
          combo_format.currentText == "jng" ||
          combo_format.currentText == "targa" ||
          combo_format.currentText == "wbmp" ||
          combo_format.currentText == "xpm" ||
          combo_format.currentText == "gif" ||
          combo_format.currentText == "webp" ? height_8_depth

          :combo_format.currentText == "pbm" ||
          combo_format.currentText == "pbmraw" ||
          combo_format.currentText == "pgm" ||
          combo_format.currentText == "pgmraw" ||
          combo_format.currentText == "png" ||
          combo_format.currentText == "ppm" ||
          combo_format.currentText == "ppmraw" ||
          combo_format.currentText == "j2k" ||
          combo_format.currentText == "jp2" ||
          combo_format.currentText == "psd" ? height_8_16_depth

          :combo_format.currentText == "tiff" ||
          combo_format.currentText == "jpeg-xr"? height_8_16_32_depth

          :combo_format.currentText == "hdr" ||
          combo_format.currentText == "exr" ||
          combo_format.currentText == "pfm"? height_32_depth
          :height_8_depth
        onCurrentTextChanged:{
          if(alg.project.isOpen()){
            alg.project.settings.setValue("hh_height_bitdepth",   combo_height_bitdepth.currentText)
          }
        }
      }

      //------ ACTION BUTTONS ------
      Rectangle{
        Layout.fillWidth: true
          Layout.columnSpan: 2
        color: "#ffffff"
        height: 1
      }

      AlgButton{
          id: btnSendAll
        text: "Send All"

          onClicked:{
              try{
            initParams()
            Utils.sendData(getParams(),false)
              }catch(err){
                  alg.log.exception(err)
              }
          }
      }

      AlgButton{
          id: btnSendCurrent
        text: "Send Current"

          onClicked:{
              try{
            initParams()
            Utils.sendData(getParams(),true)
              }catch(err){
                  alg.log.exception(err)
              }
          }
      }

    }
}

    FileDialog {
              id: file_path
              title: "Please select the export location..."
              selectFolder:true
              onAccepted: {
                  lbl_path.text = alg.fileIO.urlToLocalFile(fileUrl.toString())
                  alg.project.settings.setValue("hh_output_path", alg.fileIO.urlToLocalFile(fileUrl.toString()));
              }
      }

  }

}
