package com.bowoo.pm_opencv_plugin;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;

//import com.googlecode.tesseract.android.TessBaseAPI;
import java.io.File;

public class MrzReader {
    /*
    byte[] _imageBytes;
    TessBaseAPI _tess;

    MrzReader() {
        this._tess = new TessBaseAPI();
    }

    public void setImageBytes(byte[] imageBytes) {
        this._imageBytes = imageBytes;
    }

    public String imageToText() {
        String dataPath = new File(
                Environment.getExternalStorageDirectory(), "tesseract")
                .getAbsolutePath();
        String lang = "mrz.traineddata";
        Bitmap bitmap = BitmapFactory.decodeByteArray(_imageBytes, 0, _imageBytes.length);
        _tess.setDebug(true);
        _tess.init(dataPath, lang);
        _tess.setImage(bitmap);
        String recognizedText = _tess.getUTF8Text();
        _tess.recycle();
        return recognizedText;
    }
    */

}
