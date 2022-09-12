//
// Created by Mingan Peng on 8/30/22.
//
#include <opencv2/opencv.hpp>

using namespace cv;

#ifndef ANDROID_CONVERTER_H
#define ANDROID_CONVERTER_H
extern "C" {
__attribute__((visibility("default"))) __attribute__((used))
uint32_t *
convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel,
             int width, int height);

//int yuv420ToUIntList8(int height,int width,unsigned char * rawBytes,int32_t ** outputBytes);
//void yuv420ToMat(int height,int width,unsigned char *bytesRaw,Mat outputMat);
__attribute__((visibility("default"))) __attribute__((used))
uint32_t *convertTestAndroid(
                uint8_t *plane0,int bytesPerRow0,
                uint8_t *plane1,int length1,int bytesPerRow1,
                uint8_t *plane2,int length2,int bytesPerRow2,
                int width,int height,int orientation);
}
/*
cv::Mat prepareMatIos(uint8_t *plane,
                      int bytesPerRow,
                      int width,
                      int height,
                      int orientation);
*/
 cv::Mat prepareMatAndroid(
        uint8_t *plane0,
        int bytesPerRow0,
        uint8_t *plane1,
        int length1,
        int bytesPerRow1,
        uint8_t *plane2,
        int length2,
        int bytesPerRow2,
        int width,
        int height,
        int orientation);
int mat2UIntList8(Mat imgMat,uint32_t ** outImg);
#endif //ANDROID_CONVERTER_H
