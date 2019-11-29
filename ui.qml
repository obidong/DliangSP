import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0
import QtQuick.Controls.Styles 1.4
import AlgWidgets 2.0
import Qt.labs.folderlistmodel 1.0
import QtQuick.Controls 2.0

AlgButton {
  id: root
  antialiasing: true
  width: 30; height: 30
  tooltip: "Load dliang tool"

  property var legal_strings: {
    "BaseColor":["aseColor","iffuse","Dif","dif","lebedo"],
    "Roughness":["oughness","spcrgh","Spcrgh"],
    "Normal":["ormal","nml","nor"],
    "Metallic":["etallic","etalness","metal","Metal"],
    "Displacement":["isplacement","dsp","Dsp","disp","Disp","Height","height"],
    "Emissive":["Emissive","emissive","emission","Emission"],
    "Opacity":["pacity"],
    "Scattering":["cattering"],
    "Transmissive":["ransmissive","ransparen"]
  }
  property bool loading: false
  property var fbxPath:null
  property var exportPath:null
  property var texture_set_list:null
  property string preset_folder:alg.fileIO.open((alg.plugin_root_directory+"presets.json"), 'r').readAll()
  property string plugin_folder: alg.plugin_root_directory
  property var project_tex_output_format: ""
  property string project_tex_output_path: ""
  property var project_output_textureset:[]
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


    background: Rectangle {
      width: root.width; height: root.height
      color: "transparent"
      Image {
        source: root.hovered && !root.loading ? "icons/load_tool_on.png" : "icons/load_tool_off.png"
        fillMode: Image.PreserveAspectFit
        width: root.width; height: root.height
        mipmap: true
        opacity: root.loading ? 0.5 : 1
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
    height: 700
    minimumWidth: 300
    minimumHeight: 400
    flags: Qt.Window
      | Qt.WindowTitleHint
      | Qt.WindowSystemMenuHint
      | Qt.WindowMinMaxButtonsHint
      | Qt.WindowCloseButtonHint // close button

    // basic functions
    function initParams(){
        // refresh output path
        if(alg.project.settings.contains("output_path")){
          project_tex_output_path = alg.project.settings.value("output_path")
        }else{
          project_tex_output_path =  "D:\\Please_Select_Output_Path"
        }
        // refresh output format
        if(alg.project.settings.contains("output_format")){
          project_tex_output_format = alg.project.settings.value("output_format")
        }else{
          project_tex_output_format =  "tiff"
        }
        export_format_LE.get(0).text = project_tex_output_format

        material_name_TE.text = alg.project.name()+"_mat"
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
        // get parameters from UI
        // save project settings based on UI element selections

        // output texture sets
        project_output_textureset = dliang_sp_tools.getSelectedSets()

        // output texture folder
        project_tex_output_path = output_dir_TE.text
        alg.project.settings.setValue("output_path", project_tex_output_path)

        // output format
        project_tex_output_format = export_format_CB.currentText
        alg.project.settings.setValue("output_format", export_format_CB.currentText)

        // output preset
        var out_preset = export_presets_CB.currentText.split(".")[0]

        // resolution
        var out_res
        out_res = export_size_CB.currentText
        if (out_res == "use original"){
            out_res=null
        }else{
            out_res=parseInt(out_res)
        }

        // output texture depth
        var out_depth
        if(bit_depth_CB.currentText == "8 bit"){
            out_depth = 8
        }
        else{
            out_depth = 16
        }

        // port
        var port = port_TE.text

        return [out_preset, project_tex_output_path, project_tex_output_format, out_res, out_depth, project_output_textureset, port]
      }

    function test(){
        var mystr = ("\""+alg.plugin_root_directory+"connect_maya.bat\"")
        alg.log.info(mystr)
        alg.subprocess.check_output( ["python.exe", "connect_maya.py","mymy"])
        }
    function test_script(){
        alg.log.info("=== start testing ===")
        alg.log.info(project_tex_output_path)
    }

    // utils functions
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
        return selected_set
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
      var texture_set = dliang_sp_tools.getSelectedSets()
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
            try{
                alg.texturesets.editChannel(texture_set, selected_channel, color_profile)
            }catch(err){
                alg.log.exception(err)
              }
            }
        }
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

    function analyzingProject(){
        alg.log.info(" === Analyzing Export Presets === ")
        var params = getParams()

        var mesh_url = alg.project.lastImportedMeshUrl()
        var file_name = mesh_url.substring(mesh_url.lastIndexOf("/")+1).split(".")[0]
        var project_name = alg.project.name()

        /*
        0. out_preset,
        1. project_tex_output_path
        2. project_tex_output_format
        3. out_res
        4. out_depth
        5. project_output_textureset
        6. port
        */

        var export_log=alg.mapexport.getPathsExportDocumentMaps(params[0], params[1], params[2],params[5])
        var keys = []
        for(var textureset in export_log){
            for(var p in export_log[textureset]){
                keys.push(p)
            }
        }

        var unique_keys = keys.filter(function(elem, index, self) {
            return index === self.indexOf(elem);
        })

        // fill preset tokens
        for (var index in unique_keys){
            var token = unique_keys[index]
            if (dliang_sp_tools.filterPreset(token,"BaseColor")){
                basecolor_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Roughness")){
                roughness_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Metallic")){
                metallic_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Normal")){
                normal_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Displacement")){
                displacement_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Emissive")){
                emissive_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Opacity")){
                opacity_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Transmissive")){
                transmissive_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }else if(dliang_sp_tools.filterPreset(token,"Scattering")){
                scattering_TE.text = token.replace("$project",project_name).replace("$mesh",file_name).replace("$textureSet","1001")
            }
        }

    }
    function prepForSync(){
        basecolor_TE.text=""
        metallic_TE.text=""
        roughness_TE.text=""
        normal_TE.text=""
        displacement_TE.text=""
        emissive_TE.text = ""
        opacity_TE.text=""
        transmissive_TE.text=""
        scattering_TE.text=""

        dliang_sp_tools.analyzingProject()
        // init


    }
    function syncToMaya(export_log){

        var port = port_TE.text
        var materialName = material_name_TE.text
        var renderer = renderer_CBB.currentText
        var channel_info ={}
        var file_ext = export_format_CB.currentText.replace('"','\"')

        if(renderer=="Arnold"){
            channel_info.baseColor=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
            channel_info.specularRoughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
            channel_info.metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
            channel_info.normalCamera=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
            channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
            channel_info.emission=(["outAlpha", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
            channel_info.opacity=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
            channel_info.transmissionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
            channel_info.subsurface=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
        }
        alg.log.info(channel_info)
        channel_info=(JSON.stringify(channel_info).replace('"','\"'))
        alg.subprocess.check_output( ["python.exe", "connect_maya.py", port, materialName, channel_info, renderer,file_ext])


    }

    function exportTex(){
        alg.log.info(" === exporting textures === ")
        var params = getParams()
        /*
        0. out_preset,
        1. project_tex_output_path
        2. project_tex_output_format
        3. out_res
        4. out_depth
        5. project_output_textureset
        6. port
        */

        if (params[3]==null){
            alg.log.info("use document size for export")
            var export_log=alg.mapexport.getPathsExportDocumentMaps(params[0], params[1], params[2],params[5])
            //var export_log=alg.mapexport.exportDocumentMaps(params[0], params[1], params[2], {bitDepth:params[4]}, params[5])
        }else{
            var export_log=alg.mapexport.getPathsExportDocumentMaps(params[0], params[1], params[2],params[5])
            //var export_log = alg.mapexport.exportDocumentMaps(params[0], params[1], params[2], {resolution:[params[3],params[3]], bitDepth:params[4]}, params[5])
        }

        // export to maya
        if (enable_connection_CB.checked){
            alg.log.info("=== connecting to Maya ===")
            dliang_sp_tools.syncToMaya()
            }
        else{
            return
        }
    }
    function filterPreset(token,identifier){
        for(var i in legal_strings[identifier]){
            if(token.includes(legal_strings[identifier][i])){
                alg.log.info(token)
                return true}
        }
        return false
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
            AlgTabButton {
                id: advanced_tab_btn
                text: "Advanced"
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
                  model:
                      ListModel {
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
                AlgLabel{text: "color profile: "}
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
                  id: export_format_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: export_format_LE
                        ListElement { text: "" }
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
                  id: export_size_CB
                  Layout.fillWidth: true
                  model: ListModel {
                        id: export_size_LE
                        ListElement { text: "use original" }
                        ListElement { text: "128" }
                        ListElement { text: "256" }
                        ListElement { text: "512" }
                        ListElement { text: "1024" }
                        ListElement { text: "2048" }
                        ListElement { text: "4096" }
                        ListElement { text: "8192" }
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
                        onCurrentTextChanged:{
                            if(enable_connection_CB.checked){
                                dliang_sp_tools.prepForSync()
                            }
                        }
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
                    AlgTextInput{
                        id: output_dir_TE
                        Layout.fillWidth: true
                        text: project_tex_output_path}

                    AlgButton {
                        id: output_folder_btn
                        iconName:"icons/open_folder.png"
                        anchors.right: parent.right
                        onClicked:{
                            if(alg.project.isOpen()){
                                export_path_dialog.open()
                            }else{
                                alg.log.error("Need to open a project")
                            }
                        }
                    }

                    FileDialog {
                          id: export_path_dialog
                          title: "Please select the export folder"
                          selectFolder:true
                          onAccepted: {
                              output_dir_TE.text = alg.fileIO.urlToLocalFile(fileUrl.toString())
                              alg.project.settings.setValue("output_path", alg.fileIO.urlToLocalFile(fileUrl.toString()));
                      }
                    }

                }

                AlgToolButton{
                  id:export_btn
                  iconName:"icons/export_textures.png"
                  iconSize:Qt.size(200,35)
                  Layout.fillWidth:true
                  Layout.columnSpan:2
                  Layout.preferredHeight:40
                  background:Rectangle{
                    color: export_btn.hovered && !export_btn.loading ? "#696969" : "transparent"
                    border.width: 2
                    border.color: "#828282"
                    radius: 6

                  }
                  onClicked:{
                    dliang_sp_tools.exportTex()
                    }
                  }

                Rectangle{
                    color:"#6d6d6d"
                    Layout.preferredHeight: 3
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                }
                // advance options
                AlgGroupWidget{
                    text:"Export to Maya"
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    GridLayout{
                        id: advanced_tab_layout
                        anchors.topMargin: 10
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10

                        AlgCheckBox{
                            id: enable_connection_CB
                            text: "Create Shader In Maya"
                            onCheckedChanged:{
                                if (enable_connection_CB.checked){
                                    dliang_sp_tools.prepForSync()
                                    export_btn.iconName = "icons/export_maya.png"
                                }else{
                                    export_btn.iconName = "icons/export_textures.png"
                                }

                            }
                        }

                        RowLayout{
                            AlgLabel{text:"Port"}
                            AlgTextEdit{
                                Layout.fillWidth: true
                                id:port_TE
                                text:"9001"
                            }
                        }

                        RowLayout{
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            spacing:5

                            AlgToolButton{
                                Layout.fillHeight: true
                                Layout.preferredWidth: 60
                                iconName:"icons/sync.png"
                                iconSize: Qt.size(30,30)
                                //background: Rectangle {color: "transparent"}
                                onClicked: {
                                    dliang_sp_tools.prepForSync()
                                }
                            }
                            GridLayout{
                                columns:2
                                AlgLabel{
                                text:"Material Name"
                                Layout.alignment: Qt.AlignRight
                            }
                                AlgTextEdit{
                                id: material_name_TE
                                Layout.fillWidth: true
                                text:alg.project.name()+"_mat"
                            }
                                AlgLabel{
                                text:"Renderer"
                                Layout.alignment: Qt.AlignRight
                            }
                                AlgComboBox{
                                id: renderer_CBB
                                Layout.fillWidth: true
                                model: ListModel {
                                      id: create_maya_shader_LM
                                      ListElement { text: "Arnold" }
                                }
                            }
                            }
                        }

                        GridLayout{
                                columns: 2
                                Layout.columnSpan: 2
                                Layout.fillWidth: true


                                AlgLabel{text:"BaseColor"}
                                AlgTextInput{
                                   id: basecolor_TE
                                   Layout.fillWidth: true
                                   horizontalAlignment: TextInput.AlignRight
                                }

                                AlgLabel{text:"Metallic"}
                                AlgTextInput{
                                    id: metallic_TE
                                    Layout.fillWidth: true
                                    horizontalAlignment: TextInput.AlignRight
                                }

                                AlgLabel{text:"Roughness"}
                                AlgTextInput{
                                    id: roughness_TE
                                   Layout.fillWidth: true
                                   horizontalAlignment: TextInput.AlignRight
                                }

                                AlgLabel{text:"Normal"}
                                AlgTextInput{
                                    id: normal_TE
                                    Layout.fillWidth: true
                                    horizontalAlignment: TextInput.AlignRight
                                }

                                AlgLabel{text:"Displacement"}
                                AlgTextInput{
                                    id: displacement_TE
                                    horizontalAlignment: TextInput.AlignRight
                                    Layout.fillWidth: true}

                                AlgLabel{text:"Emissive"}
                                AlgTextInput{
                                    id: emissive_TE
                                    horizontalAlignment: TextInput.AlignRight
                                    Layout.fillWidth: true}

                                AlgLabel{text:"Opacity"}
                                AlgTextInput{
                                    id: opacity_TE
                                    horizontalAlignment: TextInput.AlignRight
                                    Layout.fillWidth: true}

                                AlgLabel{text:"Transmissive"}
                                AlgTextInput{
                                    id: transmissive_TE
                                    horizontalAlignment: TextInput.AlignRight
                                    Layout.fillWidth: true}

                                AlgLabel{text:"Scattering"}
                                AlgTextInput{
                                    id: scattering_TE
                                    horizontalAlignment: TextInput.AlignRight
                                    Layout.fillWidth: true}


                            }

                    }

                }

            }// end of stack layout
        }//end of alg tab bar

    } //end of main layout
  } // end of window
}// end of button
