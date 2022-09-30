package com.bowoo.pm_opencv_plugin;

import java.util.HashMap;

public class PrepareMrzResult{
    int errCode;
    String trainedPath;
    String errMsg;

    PrepareMrzResult(int result, String trainedPath,String err){
        this.errCode = result;
        this.trainedPath = trainedPath;
        this.errMsg = err;
    };
    HashMap<String,Object> toJson(){
        HashMap<String,Object> json = new HashMap<String,Object>();
        json.put("errCode",errCode);
        json.put("trainedPath",trainedPath);
        json.put("errMsg",errMsg);
        return json;
    }
}
