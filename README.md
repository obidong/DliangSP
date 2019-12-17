# DLiang Substance Painter Toolkit
 
## Features

1.Easily export specified channels with custom naming conventions.

2.Live link to Maya. Automatically create shading networks. (Support aiStandardSurface, PxrDisney, VRayMtl, RedShiftMaterial)

3.Batch create channels for multiple texture sets.

4.Batch modify texture set size, channel color profile.

## Known limitations

1.texture set MUST be in UDIM format (1001,1002,etc)

2.Only support Metalness/Roughness workflow.

3.Currently don't support PxrSurface. 

4.SP version need to be 2019.2 and up.

5.Cannot adjust color profile. This needs to be set by Maya color management. 

6.Windows platform only.

## How to Export Texture:

1.Select texture sets

2.Set export size, file extension, bit depth. output path, and normal format (openGL for Maya)

3.Adjust output naming format as needed. There are four available tokens: $mesh, $project, $channel, $textureSets.

4.Check the channels you wish to export.

5.Click on Export Textures. A confirmation dialog will pop out. Click on "Export" to export the textures. 

## How To Export Texture and  create shading network in Maya

1.Repeat the above steps 1-4

2.Click on the "Export to Maya" tab, check "Create Shader In Maya"

3.Set Maya port number, material name, and preferred renderer

4.In  "Maya shader parameter" section, you can adjust the parameter name if needed. For example: if you need to connect your "User0" channel to the diffuse weight of the shader, you can just put "base" in the text input slot. 

5.Note that NORMAL and DISPLACEMENT are capitalized. Please keep them that way. 

6.Click on Export To Maya and click on "Export" in the confirmation dialog 

In Maya, a new shading network will be created. If any mesh is selected. Maya will ask if you want to assign the network to your selection.
