import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import AlgWidgets 2.0
import Qt.labs.folderlistmodel 1.0
import "utils.js" as Utils

Button {
  id: root
  antialiasing: true
  width: 30; height: 30
  tooltip: "Load dliang tool"
  property bool loading: false
  property var fbxPath:null
  property var exportPath:null
  property var texture_set_list:null
  property string preset_folder:alg.fileIO.open((alg.plugin_root_directory+"presets.json"), 'r').readAll()
  property var outputpath: null


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

          alg.log.info(preset_folder)

          if(alg.project.isOpen()){
              dliang_sp_tools.initParams()
          }
          dliang_sp_tools.visible = true
          dliang_sp_tools.refreshInterface()
          dliang_sp_tools.raise()
          dliang_sp_tools.requestActivate()
          texture_set_list = dliang_sp_tools.getTextureSetInfo()
      }catch(err){
          alg.log.exception(err)
      }
  }

  FileDialog  {
    id: export_preset_dialog
    width: 300
    height: 60
    visible: false
    selectFolder: true
    onAccepted:{
        preset_folder = export_preset_dialog.folder
        export_preset_LM.folder = preset_folder
        var preset_json_path = alg.plugin_root_directory+"presets.json"
        var json_file = alg.fileIO.open(preset_json_path, 'w')
        json_file.write(preset_folder)
        json_file.close()
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

    // delete later
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
    function test(){
        Utils.send_to_maya()
        }

    // functions
    function getTextureSetInfo(){
      var doc_info = alg.mapexport.documentStructure()
      var i = 0
      var texture_set_list = []
      for (i in doc_info.materials){
        texture_set_list.push(doc_info.materials[i].name)
      }
      texture_set_list.sort()
      return texture_set_list
      }
    function getPresetFolder(){
        var json_file
        try{
            var preset_file_path = alg.plugin_root_directory+"presets.json"
            json_file = alg.fileIO.open(preset_file_path, 'r')
        }catch(err){
            alg.log.exception(err)
        }
        preset_folder = json_file.readAll()
    }
    function getSelectedSets(){
      var selected_set=[]
      var i=0

      for (i in texture_sets_SV.children){
        if (texture_sets_SV.children[i].checked==true){
            selected_set.push(texture_sets_SV.children[i].text)
          }
        }
      alg.log.info(selected_set)
      }
    function selectCheckbox(state){
      var i=0
      for (i in texture_sets_SV.children){
        try{
          texture_sets_SV.children[i].checkState=state
          }catch(err){}
        }
      }
    function selectVisible(){
      // No API found for this feature - -...
      return
      }
    function setSize(){
      var i=0
      var texture_set = []
      for (i in texture_sets_SV.children){
        if (texture_sets_SV.children[i].checked==true){
          texture_set.push(texture_sets_SV.children[i].text)
          }
        }

      var size_int = parseInt(textureset_size_CB.currentText)
      var log_size = (Math.log(size_int)/Math.log(2))
      alg.texturesets.setResolution(texture_set,[log_size, log_size])
      }
    function setColor(){
      var i=0
      for (i in texture_sets_SV.children){
        if (texture_sets_SV.children[i].checked==true){
            var color_profile = set_color_profile_CB.currentText
            var texture_set = texture_sets_SV.children[i].text
            var selected_channel = set_channel_CB.currentText
            alg.texturesets.editChannel(texture_set, selected_channel, color_profile)
            }
        }
    }
    function export_tex(){
      alg.mapexport.exportDocumentMaps(
        "PBR MetalRough",
        "c:/tmp/export/pbr",
        "tiff",
       {resolution:[256,256]},
       ["1005"])
    }
    function addChannel(){
      try{
        var current_textureset = alg.texturesets.getActiveTextureSet()[0]
        var current_slot = channels_CB.currentText
        var channel_info = channel_info_CB.currentText
        var texture_label = channel_name_txt.text
        var i=0
        for (i in texture_sets_SV.children){
          if (texture_sets_SV.children[i].checked==true){
            try{
                alg.texturesets.addChannel(texture_sets_SV.children[i].text, current_slot,channel_info,texture_label)
                }catch(err){}

            }
          }
        }
      catch(err){
          alg.log.exception(err)
        }
    }
    function setPresetPath(){
        export_preset_dialog.visible = true
    }

    //Layout
    ColumnLayout{
      id: main_layout
      anchors.topMargin: 10
      anchors.rightMargin:5
      anchors.leftMargin:5
      anchors.bottomMargin:5
      anchors.fill:parent

        AlgLabel {
          id: texture_sets_label
          Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
          text: "Textures Sets"
            }

        AlgScrollView{
          id:texture_sets_SV
            //width:200
            //height:250
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            children:[
              Repeater{
                model:texture_set_list
                AlgCheckBox{
                  text:modelData
                  hoverEnabled: false
                  }
                }
              ]
          }

        AlgButton{
          id: select_all_btn
          text: "select all"
          Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
          Layout.preferredHeight:25
          Layout.fillWidth:true
          onClicked:{
            dliang_sp_tools.selectCheckbox(1)
              }
            }
        AlgButton{
          id: hide_all_btn
          text: "deselect all"
          Layout.preferredHeight:25
          Layout.fillWidth:true
          Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
          onClicked:{
            dliang_sp_tools.selectCheckbox(0)
              }
          }
        /*
        AlgButton{
          id: select_visible_btn
          text: "select visible"
          Layout.preferredHeight:25
          Layout.fillWidth:true
          onClicked:{
            dliang_sp_tools.selectVisible()
              }
            }
        */
        AlgTabBar {
            id: features_tab
            anchors.topMargin: 10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true

            AlgTabButton {
                width:children.width
                id: create_tab_btn
                text: "Create"
                activeCloseButton:null
              }
            AlgTabButton {
                id: modify_tab_btn
                text: "Modify"
                width:children.width
                activeCloseButton:null
              }
            AlgTabButton {
                id: export_tab_btn
                text: "Export"
                width:children.width
                activeCloseButton:null
              }
          }
          StackLayout{
            anchors.topMargin: 10
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            width:parent.width;
            currentIndex:features_tab.currentIndex;
            // create channel tab
            GridLayout{
                id: create_channel_layout
                anchors.topMargin: 10
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
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
                        dliang_sp_tools.addChannel()
                      }
                  }
                }
            // modify texture set tab
            GridLayout{
                id: modify_channel_layout
                anchors.topMargin: 10
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10

                AlgLabel{text: "texture size: "}
                AlgComboBox {
                  id: textureset_size_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: texture_set_size_LM
                        ListElement { text: "256" }
                        ListElement { text: "512" }
                        ListElement { text: "1024" }
                        ListElement { text: "2048" }
                        ListElement { text: "4096" }
                    }
                  }
                AlgLabel{text: "color profile: "}
                AlgComboBox {
                  id: set_channel_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: set_channel_LE
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
                AlgLabel{text: ""}
                AlgComboBox {
                  id: set_color_profile_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: set_color_profile_LE
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
                    id: modify_texutre_size_btn
                    Layout.fillWidth: true
                  text: "Adjust Texture Size"
                  Layout.preferredHeight: 30
                    onClicked:{
                      dliang_sp_tools.setSize()
                      }
                  }
                AlgButton{
                    id: modify_depth_btn
                    Layout.fillWidth: true
                  text: "Adjust Color Profile"
                  Layout.preferredHeight: 30
                    onClicked:{
                      dliang_sp_tools.setColor()
                      }
                  }
                }
            // Export textures tab
            GridLayout{
                id: export_tab_layout
                anchors.topMargin: 10
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10

                AlgLabel{text:"Export Size"}

                AlgComboBox {
                  id: export_size_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: export_size_LE
                        ListElement { text: "use default" }
                        ListElement { text: "128" }
                        ListElement { text: "256" }
                        ListElement { text: "512" }
                        ListElement { text: "1024" }
                        ListElement { text: "2048" }
                        ListElement { text: "4096" }
                        ListElement { text: "8192" }
                        ListElement { text: "16K" }
                    }
                  }

                AlgComboBox {
                  id: export_format_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: export_format_LE
                        ListElement { text: "tiff" }
                        ListElement { text: "png" }
                        ListElement { text: "jpeg" }
                        ListElement { text: "exr" }
                        ListElement { text: "bmp" }
                        ListElement { text: "tga" }
                        ListElement { text: "psd" }
                        ListElement { text: "hdr" }
                        ListElement { text: "gif" }
                    }
                  }
                AlgComboBox {
                  id: bit_depth_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: bit_depth_LE
                        ListElement { text: "8 bit" }
                        ListElement { text: "16 bit" }
                    }
                  }

                RowLayout{
                    id: preset_column_RL
                    anchors.topMargin: 10
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    Layout.fillWidth: true
                    Layout.columnSpan: 2

                    AlgLabel{text:"Export Preset"}
                    AlgComboBox {
                        id:export_presets_CB
                        Layout.fillWidth:true
                        Layout.preferredHeight:30
                        currentIndex: 0
                        FolderListModel{
                            id:export_preset_LM
                            folder: preset_folder
                            showDirs:false
                            nameFilters: ["*.spexp"]
                        }

                        model:export_preset_LM
                        textRole: 'fileName'
                    }

                    AlgButton {
                        id: preset_folder_btn
                        iconName:"icons/open_folder.png"
                        anchors.right: parent.right
                        onClicked: {
                          dliang_sp_tools.setPresetPath()
                        }
                    }
                }

                RowLayout{
                    id: output_dir_RL
                    anchors.topMargin: 10
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    Layout.fillWidth: true
                    Layout.columnSpan: 2

                    AlgLabel{text:"Output Path"}
                    AlgTextEdit{
                        id: output_dir_TE
                        Layout.fillWidth: true
                        text: "D:\\"}

                    AlgButton {
                        id: output_folder_btn
                        iconName:"icons/open_folder.png"
                        anchors.right: parent.right
                        onClicked: {

                        }
                    }
                }


                AlgButton{
                  id:export_btn
                  text: "export maps"
                  Layout.fillWidth:true
                  Layout.columnSpan:2
                  Layout.preferredHeight:30
                  onClicked:{
                    dliang_sp_tools.export_tex()
                    }
                  }

                AlgButton{
                  id:test_btn
                  text: "test btn"
                  Layout.fillWidth:true
                  Layout.columnSpan:2
                  Layout.preferredHeight:30
                  onClicked:{
                    dliang_sp_tools.test()
                    }
                  }
            }
            //
            //
            }
      }
    } //end of main layout
  } // end of button
