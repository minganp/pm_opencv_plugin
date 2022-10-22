//
// Created by Mingan Peng on 9/21/22.
//
#include <tesseract/baseapi.h>
#include "roi_mrz_passport.h"
//#include "tessTrain.h"
const char * getTextFromMrz(const char *path,const char* lang,cv::Mat roi){
    //LOGI("----Begin to initial TessBaseAPI,path: %s,file: %s", path,lang);
    //LOGI("----width:%d,height:%d,channel:%d",roi.size().width,roi.size().height,roi.channels());
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    //api->Init(trainedPath,lang)==-1
    const char *outText;
    path = "/data/user/0/com.bowoo.pm_opencv_plugin_example/files/trainedData/";
    LOGI("Native C: trained file path: %s",path);
    int i = api->Init(path,"mrz");
    LOGI("Native C: init result: %d",i);

    if(i<0){
        outText = "Native C: init failed. Possibly caused by the wrong training data.";
        //code = -1;
    }else {
        //LOGI("----Tesseract init result:%d",i);
        /*
        if(!api->Init(name.c_str(), "mrz")){
            LOGI("----Could not initialize Tesseract! File:%s",lang);
        }
        */
        api->SetImage(
                (uchar *) roi.data,
                roi.size().width,
                roi.size().height,
                roi.channels(),
                roi.step1());
        outText = api->GetUTF8Text();
        //std::string ot(outText, outText + strlen(outText));
        LOGI("---From native: Wonderful result: %s",outText);
        api->End();
    }
    return outText;
}

int getTextFromMrz2(
        const char *path,
        const char* lang,
        cv::Mat roi,
        char ** ocrTxt
        ){
    //LOGI("----Begin to initial TessBaseAPI,path: %s,file: %s", path,lang);
    //LOGI("----width:%d,height:%d,channel:%d",roi.size().width,roi.size().height,roi.channels());
    const char *txt;
    int code;
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    //api->Init(trainedPath,lang)==-1
    path = "/data/user/0/com.bowoo.pm_opencv_plugin_example/files/trainedData/";
    LOGI("Native C: trained file path: %s",path);
    int i = api->Init(path,"mrz");
    if(i<0){
        txt = "Native C: init failed. Possibly caused by the wrong training data.";
        code = -1;
    }else{
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
        txt = api->GetUTF8Text();
        if(strlen(txt)<1)
        {
            txt = "Native C: nothing can detect from the image";
            code = -2;
        }else {
            //std::string ot(outText,outText+strlen(outText));
            //LOGI("---From native: Wonderful result: %s",outText);
            //txt = "Native C: successfully recognized";
            code = 0;
        }
    }
    LOGI("Native C, recognized txt: %s",txt);
    *ocrTxt = (char *) malloc(strlen(txt));
    strcpy(*ocrTxt,txt);
    api->End();
    return code;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MrzRoiOCR* getImgMrz(ImgForProcess *passImgForProcess){
    cv::Mat mrzRoiMat= getMrzRoiMat(passImgForProcess);
    const char *ocrTxt = getTextFromMrz(
            passImgForProcess->processArgument->trainFileDirectory,
            passImgForProcess->processArgument->trainFile,
            mrzRoiMat);
    LOGI("--from native : %s",ocrTxt);
    MichRtImgFltFmt *mrzImg = mat2MichRtImg(mrzRoiMat);
    MrzRoiOCR *mrzRoiOcr=(struct MrzRoiOCR *) malloc((sizeof(struct MrzRoiOCR)));
    mrzRoiOcr->img = mrzImg;
    mrzRoiOcr->ocrTxt = ocrTxt;
    LOGI("--from native : %s",mrzRoiOcr->ocrTxt);
    return mrzRoiOcr;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MrzRoiOCR2* getImgMrzRect(ImgForProcess *passImgForProcess){
    MrzRoiOCR2 *mrzRoiOcr2 = (struct MrzRoiOCR2 *) malloc((sizeof(struct MrzRoiOCR2)));
    mrzRoiOcr2->mRect = (struct MRect *) malloc((sizeof(struct MRect))) ;

    cv::Mat mrzRoiMat = getMrzRoiMatRect(passImgForProcess,mrzRoiOcr2->mRect);
    int errCode = getTextFromMrz2(
            passImgForProcess->processArgument->trainFileDirectory,
            passImgForProcess->processArgument->trainFile,
            mrzRoiMat,
            &mrzRoiOcr2->ocrTxt
            );
    mrzRoiOcr2->errCode = errCode;
    //MichRtImgFltFmt *mrzImg = mat2MichRtImg(mrzRoiMat);

    //mrzRoiOcr2->img = mrzImg;
    return mrzRoiOcr2;
}

