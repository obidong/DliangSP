function get_spexp(pathName){  
    var  sp_presets = [];
    var dirFile = new File(pathName);  

    if (!dirFile.exists()) {   
        return ;  
    }  

    var fileList = dirFile.list();  
    for (var i = 0; i < fileList.length; i++) {    
        var string = fileList[i];  
        var file = new File(dirFile.getPath(),string);  
        var name = file.getName();  
        if (!file.isDirectory()) {  
            sp_presets.push(name);}
    }  
    return sp_presets; 
}  


function send_to_maya(){
    var cmd = "C:/Users/obi/Desktop/test.py";
    Runtime.getRuntime().exec("python "+cmd);
}