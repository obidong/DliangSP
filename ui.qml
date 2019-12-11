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

    property var legal_strings: {
    "BaseColor":["aseCol","asecol","iffuse","Dif","dif","lebedo","ase_col","ase_Col","ase col","difCol","DifCol"],
    "Roughness":["oughness","pcrgh","pecRough","pecrough","spc_rgh","spec_rough","pec rough","spc rough"],
    "Normal":["ormal","nml","nor"],
    "Metallic":["etallic","etalness","metal","Metal"],
    "Displacement":["isplacement","dsp","Dsp","disp","Disp","Height","height"],
    "Emissive":["Emissive","emissive","emission","Emission"],
    "Opacity":["pacity","persen"],
    "Scattering":["cattering","sss","SSS"],
    "Transmissive":["ransmissive","ransparen","efraction"]
    }
    property bool loading: false
    property var texture_set_list:[]
    property string plugin_folder: alg.plugin_root_directory
    property var preset_folder: null
    property var project_name: null
    property var mesh_name: null
    property var channel_name: null
    property var document: null
    property var channel_list: []
    property var export_chan_list:[]
    property var output_channels:({})
    property var output_path:""
    property var output_format:""
    property var output_res:""
    property var output_depth:""
    property var output_textureset:[]
    property var output_name:""
    property var port:""
    property var renderer_param:
    {
        "Arnold":{
            "basecolor":"baseColor",
            "roughness":"specularRoughness",
            "normal":"NORMAL",
            "metallic":"metalness"

        },
        "VRay":{
            "basecolor":"color",
            "roughness":"reflectionGlossiness",
            "normal":"NORMAL",
            "metallic":"metalness"
        }
    }
    /*
    if(renderer=="Arnold"){
        channel_info.baseColor=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
        channel_info.specularRoughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
        channel_info.metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
        channel_info.aiNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
        channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
        channel_info.emissionColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
        channel_info.opacity=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
        channel_info.transmissionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
        channel_info.subsurface=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
    }else if(renderer == "Vray"){
        channel_info.color=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
        channel_info.reflectionGlossiness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
        channel_info.metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
        channel_info.vrayNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
        channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
        channel_info.illumColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
        channel_info.opacityMap=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
        channel_info.refractionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
        channel_info.fogMult=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
    }else if(renderer == "Renderman_PxrDisney"){
        channel_info.baseColor=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
        channel_info.roughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
        channel_info.metallic=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
        channel_info.pxrNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
        channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
        channel_info.emitColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
        channel_info.presence=(["outAlpha", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
        // PxrDisney has no refraction
        channel_info.refractionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
        channel_info.subsurface=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
    }else if(renderer == "RedShift"){
        channel_info.diffuse_color=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
        channel_info.refl_roughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
        channel_info.refl_metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
        channel_info.rsNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
        channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
        channel_info.emission_color=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"sRGB",emissive_TE.text])
        channel_info.opacity_color=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
        channel_info.refr_color=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
        channel_info.ss_amount=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
    }
    */

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
          texture_set_list = dliang_sp_tools.getTextureSetInfo()
      }catch(err){
          alg.log.exception(err)
      }
  }

    FileDialog  {
    id: dialog_export_preset
    width: 300
    height: 60
    visible: false
    selectFolder: true
    onAccepted:{
        var get_folder = dialog_export_preset.folder
        listmodel_export_preset.folder = get_folder
        preset_folder = alg.fileIO.urlToLocalFile(get_folder)
        alg.project.settings.setValue('project_export_preset_path', preset_folder)
    }
  }

    AlgDialog  {
        id: dialog_export_confirmation
        minimumHeight: 200
        minimumWidth: 330
        defaultButtonText: "Export"
        visible: false
        ColumnLayout{
            anchors.fill: parent
            AlgLabel{
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.margins: 15
                id:label_export_information
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
        width: 250
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
            //test
            //alg.log.info(alg.texturesets.structure("1001").stacks[0].channels[0].userName)
            //init UI
            alg.log.info(alg.project.settings)
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

            // refresh preset path
            if(alg.project.settings.contains("project_export_preset_path")){
              listmodel_export_preset.folder = alg.fileIO.localFileToUrl(alg.project.settings.value("project_export_preset_path"))
              preset_folder = alg.project.settings.value("project_export_preset_path")
            }else if(alg.settings.contains("export_preset_path")){
              listmodel_export_preset.folder = alg.fileIO.localFileToUrl(alg.settings.value("export_preset_path"))
              preset_folder = alg.settings.value("export_preset_path")
            }else{
                preset_folder = plugin_folder+"export-presets"
                listmodel_export_preset.folder = alg.fileIO.localFileToUrl(preset_folder)
            }


            // refresh output path
            if(alg.project.settings.contains("output_path")){
              output_dir_TE.text = alg.project.settings.value("output_path")
            }else{
              output_dir_TE.text =  "..."
            }

            // refresh file name format
            if(alg.project.settings.contains("file_name_format")){
              textinput_file_name.text = alg.project.settings.value("file_name_format")
            }else{
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
        function getSettingsFromUI(){
            // get parameters from UI and store in alg.project.settings when exporting textures.
            output_channels = {}
            output_textureset = dliang_sp_tools.getSelectedSets()       // output texture sets
            output_path = output_dir_TE.text                            // output texture folder
            output_name = textinput_file_name.text                      // output texture file name structure
            output_format = export_format_CB.currentText                // output extension
            output_res = export_size_CB.currentText                     // output resolution
            if (output_res == "default size"){
                output_res = null
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
                    output_channels[repeater_export_channel_list.itemAt(i).children[0].text]=repeater_export_channel_list.itemAt(i).children[1].text
                }
            }

            alg.project.settings.setValue("material_name", material_name_TI.text)
            alg.project.settings.setValue("output_path", output_path)
            alg.project.settings.setValue("output_format", output_format)
            alg.project.settings.setValue("project_renderer",renderer_CBB.currentText)
        }
        function setPresetPath(){
            dialog_export_preset.visible = true
        }
        function filterPreset(token,identifier){
            for(var i in legal_strings[identifier]){
                if(token.includes(legal_strings[identifier][i])){
                    return true}
            }
            return false
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
        function analyzingProject(){
            alg.log.info(" === Analyzing Export Presets === ")
            var params = dliang_sp_tools.getSettingsFromUI()
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
            var tokens = []
            for(var textureset in export_log){
                for(var p in export_log[textureset]){
                    tokens.push(p)
                }
            }

            var unique_tokens = tokens.filter(function(elem, index, self) {
                return index === self.indexOf(elem);
            })

            // fill preset tokens
            for (var index in unique_tokens){
                var token = unique_tokens[index]
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
            var renderer = renderer_CBB.currentText
            for(var i=0; i < repeater_export_channel_list.count; i++){
                    var channel_identifier = repeater_export_channel_list.itemAt(i).children[0].text
                    try{
                        repeater_export_channel_list.itemAt(i).children[1].text = renderer_param[renderer][channel_identifier]
                    }catch(err){}
            }
            //dliang_sp_tools.analyzingProject()
            // init
        }

        function syncToMaya(export_log){
            var port = maya_port_TI.text
            var materialName = material_name_TI.text
            var renderer = renderer_CBB.currentText
            var channel_info ={}
            var file_ext = export_format_CB.currentText.replace('"','\"')
            if(renderer=="Arnold"){
                channel_info.baseColor=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
                channel_info.specularRoughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
                channel_info.metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
                channel_info.aiNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
                channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
                channel_info.emissionColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
                channel_info.opacity=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
                channel_info.transmissionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
                channel_info.subsurface=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
            }else if(renderer == "Vray"){
                channel_info.color=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
                channel_info.reflectionGlossiness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
                channel_info.metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
                channel_info.vrayNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
                channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
                channel_info.illumColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
                channel_info.opacityMap=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
                channel_info.refractionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
                channel_info.fogMult=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
            }else if(renderer == "Renderman_PxrDisney"){
                channel_info.baseColor=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
                channel_info.roughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
                channel_info.metallic=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
                channel_info.pxrNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
                channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
                channel_info.emitColor=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"Raw",emissive_TE.text])
                channel_info.presence=(["outAlpha", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
                // PxrDisney has no refraction
                channel_info.refractionColor=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
                channel_info.subsurface=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
            }else if(renderer == "RedShift"){
                channel_info.diffuse_color=(["outColor", (output_dir_TE.text+"/"+basecolor_TE.text+"."+file_ext),"sRGB",basecolor_TE.text])
                channel_info.refl_roughness=(["outAlpha", (output_dir_TE.text+"/"+roughness_TE.text+"."+file_ext),"Raw",roughness_TE.text])
                channel_info.refl_metalness=(["outAlpha", (output_dir_TE.text+"/"+metallic_TE.text+"."+file_ext),"Raw",metallic_TE.text])
                channel_info.rsNormal=(["outColor", (output_dir_TE.text+"/"+normal_TE.text+"."+file_ext),"Raw",normal_TE.text])
                channel_info.displacement=(["outAlpha", (output_dir_TE.text+"/"+displacement_TE.text+"."+file_ext),"Raw",displacement_TE.text])
                channel_info.emission_color=(["outColor", (output_dir_TE.text+"/"+emissive_TE.text+"."+file_ext),"sRGB",emissive_TE.text])
                channel_info.opacity_color=(["outColor", (output_dir_TE.text+"/"+opacity_TE.text+"."+file_ext),"Raw",opacity_TE.text])
                channel_info.refr_color=(["outColor", (output_dir_TE.text+"/"+transmissive_TE.text+"."+file_ext),"sRGB",transmissive_TE.text])
                channel_info.ss_amount=(["outAlpha", (output_dir_TE.text+"/"+scattering_TE.text+"."+file_ext),"Raw",scattering_TE.text])
            }

            channel_info=(JSON.stringify(channel_info))
            channel_info=dliang_sp_tools.replaceAll(channel_info,'"','\"')
            alg.subprocess.check_output(["\""+alg.plugin_root_directory+"connect_maya.exe\"", port, materialName, channel_info, renderer])
        }
        function replaceAll(str,replaced,replacement){
            var reg=new RegExp(replaced,"g");
            str=str.replace(reg,replacement);
            return str;
        }
        function exportTexConfirmation(){
            alg.log.info(" === exporting textures === ")
            dliang_sp_tools.getSettingsFromUI()
            /*
            0. output_channels = {channel_identifier:maya_parameter}
            1. output_path
            2. output_format
            3. output_resolution
            4. output_depth
            5. output_textureset
            6. output_name
            7. port
            */
            /*
            if (params[3]==null){
                var export_log=alg.mapexport.exportDocumentMaps(params[0], params[1], params[2], {bitDepth:params[4]}, params[5])
            }else{
                var export_log = alg.mapexport.exportDocumentMaps(params[0], params[1], params[2], {resolution:[params[3],params[3]], bitDepth:params[4]}, params[5])

            }
            */

            label_export_information.text = "Export Channels Information"+"\n\n"
            for (var channel_identifier in output_channels){
                var channel_name = alg.settings.value(channel_identifier)
                var resolved_file_format  = output_name.replace("$channel",channel_name).replace("$mesh",mesh_name).replace("$project",project_name)
                label_export_information.text += output_path + "/"+ resolved_file_format +"." + output_format +"\n"
            }
            dialog_export_confirmation.open()

        }

        function exportTex(){
            var map_info = {}
            if (output_res != null){
                map_info = {resolution:[output_res,output_res]}
            }

            for (var i in output_textureset){
                var udim = output_textureset[i]
                for (var channel_identifier in output_channels){
                    var channel_name = alg.settings.value(channel_identifier)
                    if (channel_name == "USE_LABEL"){
                        var channel_document = alg.texturesets.structure(udim).stacks[0].channels
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
                            }
                        }
                    }
                    var resolved_file_format  = output_name.replace("$channel",channel_name).replace("$mesh",mesh_name).replace("$project",project_name).replace("$textureSet",udim)

                    try{
                        alg.mapexport.save([udim, channel_identifier], output_path + "/"+ resolved_file_format +"." + output_format, map_info)
                        alg.log.info("Finish exporting "+ udim +" "+channel_name)
                    }catch(err){
                        //alg.log.exception(err)
                     }

                }
            }
            // connect to maya
            if (enable_connection_CB.checked){
                alg.log.info("=== connecting to Maya ===")
                dliang_sp_tools.syncToMaya()
                }
            else{
                return
            }
        }

        // Layout, where the nightmare starts...
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
                                    id:listmodel_export_preset
                                    showDirs:false
                                    nameFilters: ["*.spexp"]
                                }

                                model:listmodel_export_preset
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
                            }

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

                        RowLayout{
                            id: output_texture_format_RL
                            anchors.topMargin: 10
                            Layout.fillHeight: false
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.columnSpan: 2

                            AlgLabel{
                                text:"Texture Name"
                                Layout.minimumWidth: 100
                            }
                            AlgTextInput{
                                id: textinput_file_name
                                Layout.fillWidth: true
                                text: "$mesh_$channel.$textureSet"
                            }

                        }

                        RowLayout{
                            id: layout_output_channel_list
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            Layout.minimumHeight: 90
                            spacing:0
                            Rectangle {
                              Layout.columnSpan: 2
                              anchors.fill: parent
                              anchors.margins: 1
                              Layout.fillWidth: true
                              //clip: true
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
                                        Layout.minimumWidth: scrollview_export_channel_list.width-30
                                        AlgCheckBox{
                                            text:modelData
                                            checked:true
                                            hoverEnabled: false
                                            Layout.minimumWidth: 90
                                        }
                                        AlgTextInput{
                                            Layout.fillWidth: true
                                        }



                                    }
                                }
                              }

                            }
                        }

                        RowLayout{
                            id: layout_channel_selection
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
                            //dialog_export_confirmation.open()
                            //dliang_sp_tools.getSettingsFromUI()
                            dliang_sp_tools.exportTexConfirmation()
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
                                    AlgLabel{text:"Maya Port"}
                                    AlgTextInput{
                                        Layout.fillWidth: true
                                        id:maya_port_TI
                                        text:alg.settings.value('default_maya_port')
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
                                        iconSize: Qt.size(45,36)
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
            }

        }//end of main layout
    }
}
