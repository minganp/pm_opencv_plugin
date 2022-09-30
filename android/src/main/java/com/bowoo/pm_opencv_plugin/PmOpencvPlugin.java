package com.bowoo.pm_opencv_plugin;

import android.util.Log;
//import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** PmOpencvPlugin */
public class PmOpencvPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  //private final MrzReader mrzReader = new MrzReader();
  private FlutterPluginBinding binding;
  //private String ERR_TAG = "Error";
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pm_opencv_plugin");
    channel.setMethodCallHandler(this);
    binding=flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    switch (call.method) {
      case "getPlatformVersion":
              result.success("Android " + android.os.Build.VERSION.RELEASE);
              break;/*argument as image of byte[]
          //mrzReader.setImageBytes(call.argument("imgBytes"));
          result.success(mrzReader.imageToText());
          */
      case "prepareMrz":
        PrepareMrzResult _result = prepareMrz();
        result.success(_result.toJson());
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private PrepareMrzResult prepareMrz(){
    boolean fileExistFlag = false;


    String dstPathDir = "/trainedData/";
    String srcFile = "mrz.traineddata";
    String assetPath = binding.getFlutterAssets().getAssetFilePathBySubpath(
            "assets/ocrTrainedData/"+srcFile,"pm_opencv_plugin");

    InputStream inFile ;
    String errMsg ;
    int errCode ;

    dstPathDir = binding.getApplicationContext().getFilesDir() + dstPathDir;
    //String dstInitPathDir = context.getFilesDir() + "/tesseract";
    String dstPathFile = dstPathDir;
    FileOutputStream outFile = null;
    try{
      inFile = binding.getApplicationContext().getAssets().open(assetPath);
    }catch(Exception e){
      Log.e("err",e.getMessage());
      errCode = -1;
      errMsg = "0";
      return new PrepareMrzResult(errCode,dstPathFile,errMsg);
    }

    try {

      File f = new File(dstPathDir);

      if (!f.exists()) {
        if (!f.mkdirs()) {
          errCode = -1;
          errMsg = "Trained can't be created.";
          //Toast.makeText(context, srcFile + " can't be created.", Toast.LENGTH_SHORT).show();
          return new PrepareMrzResult(errCode,dstPathFile,errMsg);
        }
        outFile = new FileOutputStream(dstPathFile);
      } else {
        fileExistFlag = true;
      }
    } catch (Exception ex) {
      errCode = -1;
      errMsg = assetPath+"does not exists";
      return new PrepareMrzResult(errCode,dstPathFile,errMsg);
      //Log.e(ERR_TAG, ex.getMessage());
    } finally {
      if (fileExistFlag) {
        try {
          if (inFile != null) inFile.close();
          //mTess.init(dstInitPathDir, language);
          errCode = 1;
          errMsg = "Trained file already exists";
        } catch (Exception ex) {
          errCode = -1;
          errMsg = "3";
          Log.e("ERR", ex.getMessage());
        }
      }
      else if (inFile != null && outFile != null) {
        try {
          //copy file
          byte[] buf = new byte[1024];
          int len;
          while ((len = inFile.read(buf)) != -1) {
            outFile.write(buf, 0, len);
          }
          inFile.close();
          outFile.close();
         // mTess.init(dstInitPathDir, language);
          errCode = 0;
          errMsg = "Trained file prepare success";
        } catch (Exception ex) {
          errCode = -1;
          errMsg = "4";
          //Log.e(ERR_TAG, ex.getMessage());
        }
      }
      else {
        errCode = -1;
        errMsg = "Trained file can't be read";
        //Toast.makeText(context, srcFile + " can't be read.", Toast.LENGTH_SHORT).show();
      }
    }
    Log.e("-----LOG",errMsg);
    return new PrepareMrzResult(errCode,dstPathFile,errMsg);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

