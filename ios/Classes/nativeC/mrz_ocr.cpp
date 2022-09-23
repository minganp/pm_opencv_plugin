//
// Created by Mingan Peng on 9/21/22.
//
#include <string>
#include <tesseract3/baseapi.h>
#include "roi_mrz_passport.h"
char * getTextFromMrz(char* trainedPath,char* lang,cv::Mat roi){

    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    api->Init(trainedPath,lang);

    api->SetImage(roi.data,roi.cols,roi.rows,4,4*roi.cols);
    char *outText = api->GetUTF8Text();
    return outText;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MrzRoiOCR* getImgMrz(char* trainedPath,char* lang,Img *passportImg){
    cv::Mat mrzRoiMat= getMrzRoiMat(passportImg);
    char *ocrTxt = getTextFromMrz(trainedPath,lang,mrzRoiMat);

    MichRtImgFltFmt *mrzImg = mat2MichRtImg(mrzRoiMat);
    MrzRoiOCR *mrzRoiOcr=(struct MrzRoiOCR *) malloc((sizeof(struct MrzRoiOCR)));
    mrzRoiOcr->img = mrzImg;
    mrzRoiOcr->ocrTxt = ocrTxt;
    return mrzRoiOcr;
}


