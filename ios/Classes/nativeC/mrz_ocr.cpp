//
// Created by Mingan Peng on 9/21/22.
//
#include <string>
#include <tesseract/baseapi.h>
#include "roi_mrz_passport.h"
//#include "tessTrain.h"
const char * getTextFromMrz(const char *path,const char* lang,cv::Mat roi){
    //LOGI("----Begin to initial TessBaseAPI,path: %s,file: %s", path,lang);
    //LOGI("----width:%d,height:%d,channel:%d",roi.size().width,roi.size().height,roi.channels());
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    //api->Init(trainedPath,lang)==-1

    int i = api->Init(path,"mrz");
    //LOGI("----Tesseract init result:%d",i);
    /*
    if(!api->Init(name.c_str(), "mrz")){
        LOGI("----Could not initialize Tesseract! File:%s",lang);
    }
    */
    api->SetImage(
            (uchar *)roi.data,
            roi.size().width,
            roi.size().height,
            roi.channels(),
            roi.step1());
    const char *outText = api->GetUTF8Text();
    std::string ot(outText,outText+strlen(outText));
    LOGI("---From native: Wonderful result: %s",outText);
    return outText;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MrzRoiOCR* getImgMrz(ImgForProcess *passImgForProcess){
    cv::Mat mrzRoiMat= getMrzRoiMat(passImgForProcess);
    const char *ocrTxt = getTextFromMrz(
            passImgForProcess->processArgument->trainFileDirectory,
            passImgForProcess->processArgument->trainFile,
            mrzRoiMat);

    MichRtImgFltFmt *mrzImg = mat2MichRtImg(mrzRoiMat);
    MrzRoiOCR *mrzRoiOcr=(struct MrzRoiOCR *) malloc((sizeof(struct MrzRoiOCR)));
    mrzRoiOcr->img = mrzImg;
    mrzRoiOcr->ocrTxt = ocrTxt;
    return mrzRoiOcr;
}


