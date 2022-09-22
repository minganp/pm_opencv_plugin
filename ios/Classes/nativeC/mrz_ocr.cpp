//
// Created by Mingan Peng on 9/21/22.
//
#include <string>
#include <tesseract3/baseapi.h>

char * getTextFromMrz(char* trainedPath,char* lang,cv::Mat roi){

    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    api->Init(trainedPath,lang);

    api->SetImage(roi.data,roi.cols,roi.rows,4,4*roi.cols);
    char *outText = api->GetUTF8Text();
    return outText;
}


