//
// Created by Mingan Peng on 9/5/22.
//

#include <vector>
#include <android/log.h>

#include "michImage.h"
#include "processImage.h"
//#include "roi_mrz_passport.h"

#define  LOG_TAG    "CVPLUGIN"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)

//using namespace cv;
//using namespace std;

extern "C" __attribute__((visibility("default"))) __attribute__((used))
uint32_t *
convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel,
             int width, int height);

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void convertTestAndroid(
        uint8_t *plane0,int bytesPerRow0,
        uint8_t *plane1,int length1,int bytesPerRow1,
        uint8_t *plane2,int length2,int bytesPerRow2,
        int width,int height,int orientation,
        unsigned char *outImage,unsigned int *size);

extern "C" __attribute__((visibility("default"))) __attribute__((used))
const char *version();

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void process_image(const char *inputImagePath, const char *outputImagePath);

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MichRtImgFltFmt * processAndroidImage(Img *img);

extern "C" __attribute__((visibility("default"))) __attribute__((used))
Plane *createImagePlane() {
    return (struct Plane *) malloc(sizeof(struct Plane));
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
Img *createImage(){
    return (struct Img *) malloc(sizeof(struct Img));
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MichRtImgFltFmt *createRtImgFmt(){
    return (struct MichRtImgFltFmt *) malloc(sizeof(struct MichRtImgFltFmt));
}
extern "C" __attribute__((visibility("default"))) __attribute__((used))
ProcessArgument *createProcessArgumentP(){
    return (struct ProcessArgument*) malloc((sizeof (struct ProcessArgument)));
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
ImgForProcess *createImagePorProcess(){
    return (struct ImgForProcess*) malloc((sizeof (struct ImgForProcess)));
}


//void processAndroidImage2(Img * img,MichRtImgFltFmt * rtImgFltFmt);
extern "C" __attribute__((visibility("default"))) __attribute__((used))
void processAndroidImage2(Img * img,unsigned char *buf,uint *size);
//#include "michImage.cpp"
//#include "converter.cpp"
extern "C" __attribute__((visibility("default"))) __attribute__((used))
MichRtImgFltFmt *getRoiMrzStepByStep(Img *img);

//extern "C" __attribute__((visibility("default"))) __attribute__((used))
//MrzRoiOCR* getImgMrz(const char* trainedPath,const char* lang,Img *passportImg);
//#include "native_opencv.cpp"
#include "roi_mrz_passport.cpp"
#include "processImage.cpp"
#include "mrz_ocr.cpp"

