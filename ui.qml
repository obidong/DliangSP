// Substance Painter Toolkit 1.0
// Copyright (C) 2019 Liang Dong

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
    tooltip: "Launch Dliang Substance Painter Toolkit UI"

    property bool loading: false
    property var texture_set_list:[]
    property var project_name: null
    property var mesh_name: null
    property var channel_name: null
    property var document: null
    property var channel_list: []
    property var export_info:null
    property var output_channels:({})
    property string output_path:""
    property string output_format:""
    property string output_normal_format: ""
    property string output_res:""
    property string output_depth:""
    property var output_textureset:[]
    property string output_name:""
    property string port:""
    property var renderer_param:
    {
        "Arnold":{
            "basecolor":"baseColor",
            "roughness":"specularRoughness",
            "normal":"NORMAL",
            "metallic":"metalness",
            "height":"",
            "emissive":"emissionColor",
            "opacity":"opacity",
            "scattering":"subsurface",
            "transmissive":"transmissionColor",
            "ambientOcclusion":"",
            "anisotropylevel":"",
            "anisotropyangle":"",
            "blendingmask":"",
            "diffuse":"",
            "displacement":"DISPLACEMENT",
            "glossiness":"",
            "ior":"",
            "reflection":"",
            "specular":"",
            "specularlevel":""
        },
        "VRay":{
            "basecolor":"color",
            "roughness":"reflectionGlossiness",
            "normal":"NORMAL",
            "metallic":"metalness",
            "height":"",
            "emissive":"illumColor",
            "opacity":"opacityMap",
            "scattering":"fogMult",
            "transmissive":"refractionColor",
            "ambientOcclusion":"",
            "anisotropylevel":"",
            "anisotropyangle":"",
            "blendingmask":"",
            "diffuse":"",
            "displacement":"DISPLACEMENT",
            "glossiness":"",
            "ior":"",
            "reflection":"",
            "specular":"",
            "specularlevel":""
        },
        "Renderman_PxrDisney":{
            "basecolor":"baseColor",
            "roughness":"roughness",
            "normal":"NORMAL",
            "metallic":"metallic",
            "height":"",
            "emissive":"emitColor",
            "opacity":"presence",
            "scattering":"subsurface",
            "transmissive":"",
            "ambientOcclusion":"",
            "anisotropylevel":"",
            "anisotropyangle":"",
            "blendingmask":"",
            "diffuse":"",
            "displacement":"DISPLACEMENT",
            "glossiness":"",
            "ior":"",
            "reflection":"",
            "specular":"",
            "specularlevel":""
        },
        "RedShift":{
            "basecolor":"diffuse_color",
            "roughness":"refl_roughness",
            "normal":"NORMAL",
            "metallic":"refl_metalness",
            "height":"",
            "emissive":"emission_color",
            "opacity":"opacity_color",
            "scattering":"ss_amount",
            "transmissive":"refr_color",
            "ambientOcclusion":"",
            "anisotropylevel":"",
            "anisotropyangle":"",
            "blendingmask":"",
            "diffuse":"",
            "displacement":"DISPLACEMENT",
            "glossiness":"",
            "ior":"",
            "reflection":"",
            "specular":"",
            "specularlevel":""
        }
    }

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
          if(alg.project.isOpen()){
              dliang_sp_tools.initParams()
          }
          dliang_sp_tools.open()
          alg.log.info("set tool visible")

          dliang_sp_tools.refreshInterface()
          alg.log.info("refresh ui")
          texture_set_list = dliang_sp_tools.getTextureSetInfo()
          alg.log.info(texture_set_list)
  }

    AlgDialog  {
        id: dialog_export_confirmation
        minimumHeight: 300
        minimumWidth: 330
        defaultButtonText: "Export"
        //visible: false
        Rectangle{
            color:"transparent"
            anchors.fill:parent
            anchors.margins: 5
            anchors.bottomMargin: 100
            AlgScrollView {
                id: scrollview_export_confirmation
                anchors.fill: parent
                ColumnLayout {
                spacing: 6
                Layout.maximumWidth: scrollview_export_confirmation.viewportWidth
                Layout.minimumWidth: scrollview_export_confirmation.viewportWidth
                    AlgLabel{
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.margins: 15
                        id:label_export_information
                    }
                }
            }
        }

        GridLayout{
            anchors.fill: parent
            anchors.margins: 5
            anchors.bottomMargin: 40
            AlgLabel{
               text:"Export Progress"
               Layout.maximumWidth: 90
               Layout.minimumHeight: 25
               Layout.maximumHeight: 25
               Layout.alignment: Qt.AlignHCenter|Qt.AlignBottom
            }
            AlgProgressBar {
                id: progressbar_export
                Layout.fillWidth: true
                Layout.minimumHeight: 25
                Layout.maximumHeight: 25
                Layout.alignment: Qt.AlignHCenter|Qt.AlignBottom
                from: 0
                to: 1
                value: 0.0
                height: 25
            }
        }
        onAccepted:{
            dliang_sp_tools.exportTex()
        }
    }
    AlgWindow{
        id: dliang_sp_tools
        title: "Dliang SP Toolkit"
        visible: false
        width: 320
        height: 700
        minimumWidth: 300
        minimumHeight: 600
        flags: Qt.Window
          | Qt.WindowTitleHint
          | Qt.WindowSystemMenuHint
          | Qt.WindowMinMaxButtonsHint
          | Qt.WindowCloseButtonHint

        // basic functions
        function initParams(){
            alg.log.info("start tool")
            channel_list = []
            // gether project information
            project_name = alg.project.name()
            var mesh_url = alg.project.lastImportedMeshUrl()
            mesh_name = mesh_url.substring(mesh_url.lastIndexOf("/")+1).split(".")[0]
            document = alg.mapexport.documentStructure()
            for (var i in document.materials){
                texture_set_list.push(document.materials[i].name)
                for(var j in document.materials[i].stacks[0].channels){
                    if (document.materials[i].stacks[0].channels[j] in channel_list != true){
                        channel_list.push(document.materials[i].stacks[0].channels[j])
                    }
                }
            }
            texture_set_list.sort()
            channel_list = channel_list.filter(function(elem, index, self) {
                return index === self.indexOf(elem);
            })
            channel_list.sort()
            repeater_export_channel_list.model = channel_list

            // refresh material name
            if(alg.project.settings.contains("material_name")){
                material_name_TI.text = alg.project.settings.value("material_name")
            }else{
                material_name_TI.text = alg.project.name()+"_mat"
            }

            // refresh output path
            if(alg.project.settings.contains("output_path")){
              output_dir_TE.text = alg.project.settings.value("output_path")
            }else{
              output_dir_TE.text =  "..."
            }

            // refresh file naming convention
            if(alg.project.settings.contains("file_name_format")){
              textinput_file_name.text = alg.project.settings.value("file_name_format")
            }else if(alg.settings.contains("file_name_format")){
              textinput_file_name.text = alg.settings.value("file_name_format")
            }
            else{
              textinput_file_name.text =  "$mesh_$channel.$textureSet"
            }

            // refresh output format
            if(alg.project.settings.contains("output_format")){
                export_format_LE.get(0).text = alg.project.settings.value("output_format")
            }else{
                export_format_LE.get(0).text =  alg.settings.value('format')
            }

            //refresh render engine
            if(alg.project.settings.contains("project_renderer")){
              create_maya_shader_LM.get(0).text = alg.project.settings.value("project_renderer")
            }else{
              create_maya_shader_LM.get(0).text = alg.settings.value('renderer')
            }

            // refresh port
            maya_port_TI.text = alg.settings.value('default_maya_port')

            if (enable_connection_CB.checked != true){
                for(var i=0; i < repeater_export_channel_list.count; i++){
                    repeater_export_channel_list.itemAt(i).children[1].text = ""
                }
            }
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
        function textureSetCheckbox(state){
            var i=0
            for (i in texture_sets_SV.children){
                try{
                    texture_sets_SV.children[i].checkState=state
                }catch(err){}
            }
        }
        function channelCheckbox(state){
            for(var i=0; i < repeater_export_channel_list.count; i++){
                repeater_export_channel_list.itemAt(i).children[0].checkState = state
            }
        }
        function selectVisible(){
            // No API found for this feature yet - -...Adobe bu gei li a
            return
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
                        }catch(err){alg.log.exception(err)}
                    }
                }
            }
            catch(err){
              alg.log.exception(err)
            }
        }
        function setSize(){
            var i=0
            var texture_set = dliang_sp_tools.getSelectedSets()
            var size_int = parseInt(textureset_size_CB.currentText)
            var log_size = (Math.log(size_int)/Math.log(2))
            alg.texturesets.setResolution(texture_set,[log_size, log_size])
        }
        function setColorProfile(){
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
        function replaceAll(str,replaced,replacement){
            var reg=new RegExp(replaced,"g");
            str=str.replace(reg,replacement);
            return str;
        }
        // export functions
        function getSettingsFromUI(){
            // get parameters from UI and store in alg.project.settings when exporting textures.
            output_channels = {}
            output_textureset = dliang_sp_tools.getSelectedSets()       // output texture sets
            output_path = output_dir_TE.text                            // output texture folder
            output_name = textinput_file_name.text                      // output texture file name structure
            output_format = export_format_CB.currentText                // output extension
            var normal_format = cbb_normal_format.currentText           // output normal format
            if (normal_format == "OpenGL"){
                output_normal_format = "normal_opengl"
            }else{
                output_normal_format = "normal_directx"
            }
            output_res = export_size_CB.currentText                     // output resolution
            if (output_res == "default size"){
                output_res = ""
            }else{
                output_res=parseInt(output_res)
            }
                                                                        // output depth
            if(bit_depth_CB.currentText == "8 bit"){
                output_depth = 8
            }else{
                output_depth = 16
            }
            port = maya_port_TI.text

            for(var i=0; i < repeater_export_channel_list.count; i++){
                if (repeater_export_channel_list.itemAt(i).children[0].checked){
                    // output_channels= {basecolor:"baseColor", height:"DISPLACEMENT"...channel_identifier:maya_params}
                    output_channels[repeater_export_channel_list.itemAt(i).children[0].text]=repeater_export_channel_list.itemAt(i).children[1].text
                }
            }

            alg.project.settings.setValue("material_name", material_name_TI.text)
            alg.project.settings.setValue("output_path", output_path)
            alg.project.settings.setValue("output_format", output_format)
            alg.project.settings.setValue("project_renderer",renderer_CBB.currentText)
        }
        function exportTexConfirmation(){
            alg.log.info(" === exporting textures === ")
            var export_channel_info = {}
            var output_full_path ={}
            progressbar_export.value = 0
            dliang_sp_tools.getSettingsFromUI()
            label_export_information.text = "Export Channels Information"+"\n\n"
            label_export_information.text += "=== Export Channels ===\n"


            for (var channel_identifier in output_channels){
                var channel_name = alg.settings.value(channel_identifier)
                var resolved_file_format  = output_name.replace("$channel",channel_name).replace("$mesh",mesh_name).replace("$project",project_name)
                output_full_path[channel_identifier] = output_path + "/"+ resolved_file_format +"." + output_format
                label_export_information.text += output_full_path[channel_identifier] +"\n"

            }
            // if export to maya
            if (enable_connection_CB.checked){
                for(var i=0; i < repeater_export_channel_list.count; i++){
                    if (repeater_export_channel_list.itemAt(i).children[0].checked){
                        channel_identifier = repeater_export_channel_list.itemAt(i).children[0].text
                        var maya_params = repeater_export_channel_list.itemAt(i).children[1].text
                        export_channel_info[channel_identifier] = [output_full_path[channel_identifier],maya_params]
                    }
                }
            }
            //alg.log.info(export_channel_info)
            export_info = export_channel_info
            dialog_export_confirmation.open()

        }
        function exportTex(){
            var map_info = {}
            if (output_res != ""){
                map_info = {resolution:[output_res,output_res]}
            }

            var channel_num = 0
            for (var i in output_channels){
                channel_num +=1
            }

            var textureset_num = output_textureset.length
            var total_channel_num =  channel_num * textureset_num

            for (var i in output_textureset){
                var textureset = output_textureset[i]
                for (var channel_identifier in output_channels){
                    var channel_name = alg.settings.value(channel_identifier)
                    if (channel_name == "USE_LABEL"){
                        var channel_document = alg.texturesets.structure(textureset).stacks[0].channels
                        /*"channels": [
                        {
                          "format": "DataChannelFormat_L32F",
                          "type": "DataChannelType_User0",
                          "uid": 9412,
                          "userName": "MyChannelMask"
                        },
                        {
                          "format": "DataChannelFormat_sRGB8",
                          "type": "DataChannelType_BaseColor",
                          "uid": 9413,
                          "userName": ""
                        }
                        */
                        for (var index in channel_document){
                            if (channel_identifier.includes(channel_document[index].type.replace("DataChannelType_U",""))){
                                channel_name = channel_document[index].userName
                                export_info[channel_identifier][0] = export_info[channel_identifier][0].replace("USE_LABEL",channel_name)
                            }
                        }
                    }
                    var resolved_file_format  = output_name.replace("$channel",channel_name).replace("$mesh",mesh_name).replace("$project",project_name).replace("$textureSet",textureset)

                    try{
                        if (channel_identifier == "normal"){
                            alg.mapexport.saveConvertedMap(textureset,output_normal_format,output_path + "/"+ resolved_file_format +"." + output_format, map_info)
                        }else{
                            alg.mapexport.save([textureset, channel_identifier], output_path + "/"+ resolved_file_format +"." + output_format, map_info)
                        }
                        if (progressbar_export.value<0.995){
                            progressbar_export.value += 1/total_channel_num
                        }
                        alg.log.info("Finish exporting "+ textureset +" "+channel_name)
                    }catch(err){
                        if (progressbar_export.value<0.995){
                            progressbar_export.value += 1/total_channel_num
                        }
                     }

                }
            }
            dialog_export_confirmation.close()
            // connect to maya
            if (enable_connection_CB.checked){
                alg.log.info("=== connecting to Maya ===")
                dliang_sp_tools.syncToMaya()
            }else{
                return
            }
        }
        function prepForSync(){
            var renderer = renderer_CBB.currentText
            for(var i=0; i < repeater_export_channel_list.count; i++){
                    var channel_identifier = repeater_export_channel_list.itemAt(i).children[0].text
                    try{
                        repeater_export_channel_list.itemAt(i).children[1].text = renderer_param[renderer][channel_identifier]
                    }catch(err){}
            }
        }
        function syncToMaya(){
            var port = maya_port_TI.text
            var materialName = material_name_TI.text
            var renderer = renderer_CBB.currentText
            var file_ext = export_format_CB.currentText
            var channel_info=(JSON.stringify(export_info))
            channel_info=dliang_sp_tools.replaceAll(channel_info,'"','\"')
            alg.subprocess.check_output(["\""+alg.plugin_root_directory+"connect_maya.exe\"", port, materialName, channel_info, renderer])
            //for checking
            //alg.log.info("\"" + alg.plugin_root_directory + "connect_maya.exe\"" + " " + port + " " + materialName + " " + channel_info + " " + renderer)
        }

        // Layout, where the nightmare starts...
        ColumnLayout{
            id: main_layout
            anchors.topMargin: 10
            anchors.rightMargin:5
            anchors.leftMargin:5
            anchors.bottomMargin:5
            anchors.fill:parent

            RowLayout{
                Layout.fillWidth: true
                AlgToolButton{
                    Layout.alignment:Qt.AlignLeft|Qt.AlignTop
                    iconName: "icons/sync.png"
                    iconSize: Qt.size(30,30)
                    onClicked: {
                        try{
                            if(alg.project.isOpen()){
                                dliang_sp_tools.initParams()
                            }
                            dliang_sp_tools.refreshInterface()
                            texture_set_list = dliang_sp_tools.getTextureSetInfo()
                        }catch(err){
                            alg.log.exception(err)
                        }
                    }
                }
                AlgLabel {
                  id: texture_sets_label
                  Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                  text: "Textures Sets"
                    }
            }

            AlgScrollView{
              id:texture_sets_SV
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

            RowLayout{
                AlgButton{
              id: select_all_btn
              text: "Select All"
              Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
              Layout.preferredHeight:25
              Layout.fillWidth:true
              onClicked:{
                dliang_sp_tools.textureSetCheckbox(1)
                  }
                }
                AlgButton{
              id: hide_all_btn
              text: "Deselect All"
              Layout.preferredHeight:25
              Layout.fillWidth:true
              Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
              onClicked:{
                dliang_sp_tools.textureSetCheckbox(0)
                  }
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
                    text: "Create and Modify"
                    activeCloseButton:null
                  }
                AlgTabButton {
                    id: export_tab_btn
                    text: "Export"
                    width:children.width
                    activeCloseButton:null
                  }
                /*
                AlgTabButton {
                    id: advanced_tab_btn
                    text: "Advanced"
                    width:children.width
                    activeCloseButton:null
                  }
                */
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
                        //Modify
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            radius: 2
                            height:3
                            color:"#d6d6d6"
                        }
                        AlgLabel{text: "texture size: "}
                        AlgLabel{text: "color profile: "}
                        AlgComboBox {
                          id: textureset_size_CB
                          Layout.fillWidth: true
                          model: ListModel {
                                id: texture_set_size_LM
                                ListElement { text: "128" }
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
                              dliang_sp_tools.setColorProfile()
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
                          }
                        AlgComboBox {
                          id: export_size_CB
                          Layout.fillWidth: true
                          model: ListModel {
                                id: export_size_LE
                                ListElement { text: "default size" }
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
                            id: output_dir_RL
                            anchors.topMargin: 2
                            Layout.fillHeight: false
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            AlgLabel{text:"Output Path"}
                            AlgTextInput{
                                id: output_dir_TE
                                Layout.fillWidth: true
                                onEditingFinished:{
                                    output_dir_TE.text = output_dir_TE.text.replace(/\\/g,"/")
                                    output_path = output_dir_TE.text
                                }
                            }
                            AlgToolButton {
                                id: output_folder_btn
                                iconName:"icons/open_folder.png"
                                //Layout.alignment: Qt.AlignRight
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
                        RowLayout{
                            id: output_texture_format_RL
                            anchors.topMargin: 10
                            Layout.fillHeight: false
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.columnSpan: 2

                            AlgLabel{
                                text:"File Format "
                                Layout.maximumWidth: 90
                            }
                            AlgTextInput{
                                id: textinput_file_name
                                Layout.fillWidth: true
                                text: "$mesh_$channel.$textureSet"
                                tooltip:"$mesh: mesh name\n$project: current project name\n$channel: channel name preset\n$textureSet: UDIM only!"
                            }
                            AlgComboBox{
                                id:cbb_normal_format
                                tooltip: "Normal Map Format"
                                Layout.maximumWidth: 70
                                model:ListModel{
                                    ListElement{text:"OpenGL"}
                                    ListElement{text:"DirectX"}
                                }
                            }

                        }
                        Rectangle{
                            Layout.fillWidth: true
                            height:3
                            Layout.columnSpan: 2
                            radius:2
                            color:"#d6d6d6"
                        }
                        RowLayout{
                            id: output_parameter_RL
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            AlgLabel{
                                text:"SP Channel"
                                Layout.minimumWidth: 90
                            }
                            AlgLabel{
                                Layout.fillWidth: true
                                text:"    Maya Shader Parameter"
                            }
                        }
                        RowLayout{
                            id: output_channel_RL
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            Layout.minimumHeight: 120
                            spacing:0
                            Rectangle {
                              Layout.columnSpan: 2
                              //Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                              anchors.fill: parent
                              //anchors.margins: 1
                              Layout.fillWidth: true
                              color: "transparent"
                              AlgScrollView {
                                id: scrollview_export_channel_list
                                Layout.columnSpan: 2
                                anchors.fill: parent
                                anchors.margins: 1
                                Repeater{
                                    id:repeater_export_channel_list
                                    model:channel_list
                                    RowLayout{
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: scrollview_export_channel_list.width-5
                                        AlgCheckBox{
                                            text:modelData
                                            tooltip:modelData
                                            checked:true
                                            hoverEnabled: false
                                            Layout.maximumWidth: 110
                                        }
                                        AlgTextInput{
                                            Layout.alignment: Qt.AlignLeft
                                            Layout.fillWidth: true
                                        }



                                    }
                                }
                              }

                            }
                        }
                        RowLayout{
                            id: channel_selection_RL
                            anchors.topMargin: 10
                            Layout.fillHeight: false
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            AlgButton{
                                text:"Select All Channels"
                                Layout.fillWidth: true
                                onClicked: {
                                    dliang_sp_tools.channelCheckbox(1)
                                }
                            }
                            AlgButton{
                                text:"Deselect All"
                                Layout.fillWidth: true
                                onClicked: {
                                    dliang_sp_tools.channelCheckbox(0)
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
                              dliang_sp_tools.exportTexConfirmation()
                            }
                          }
                        Rectangle{
                            color:"#d6d6d6"
                            Layout.preferredHeight: 3
                            radius:2
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                        }
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
                                    AlgLabel{text:"Maya Port"}
                                    AlgTextInput{
                                        Layout.fillWidth: true
                                        id:maya_port_TI
                                        text:alg.settings.value('default_maya_port')
                                    }
                                }
                                GridLayout{
                                    columns:2
                                    Layout.columnSpan: 2
                                    Layout.fillWidth: true
                                    AlgLabel{
                                        text:"Material Name"
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    AlgTextInput{
                                        id: material_name_TI
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
                                            ListElement { text: "" }
                                            ListElement { text: "Arnold" }
                                            ListElement { text: "VRay" }
                                            ListElement { text: "Renderman_PxrDisney" }
                                            ListElement { text: "RedShift" }
                                        }
                                        onCurrentTextChanged: {
                                            dliang_sp_tools.prepForSync()
                                        }
                                    }
                                }
                            }

                        }

                    }
            }

        }//end of main layout
    }
}
