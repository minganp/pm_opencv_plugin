//
// Created by Mingan Peng on 9/9/22.
//
#ifndef _PROCESSIMAGE_H_
#define _PROCESSIMAGE_H_
extern "C" __attribute__((visibility("default"))) __attribute__((used))
void processAndroidImage2(Img * img,uchar *buf,uint *size);

void mat2MichRtImg2(cv::Mat imgMat,uchar *outImg,uint *size);
cv::Mat genMatAndroid(
        uint8_t *plane0, int bytesPerRow0,
        uint8_t *plane1, int length1, int bytesPerRow1,
        uint8_t *plane2, int length2, int bytesPerRow2,
        int width, int height, int orientation);
cv::Mat prepareMat(Img *img);
MichRtImgFltFmt *mat2MichRtImg(cv::Mat imgMat);
#endif