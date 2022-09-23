//
// Created by Mingan Peng on 9/9/22.
//
#ifndef _MICHIMAGE_H_
#define _MICHIMAGE_H_
#include <opencv2/opencv.hpp>
struct Plane{
    uint8_t * planeData;
    Plane * nextPlanePtr;
    int bytesPerRow;
    int length;
};

struct Img{
    Plane * plane;
    int platform;
    int width;
    int height;
    int orientation;
};

//return image in UInt8List for flutter Image Widget
struct MichRtImgFltFmt{
    uint8_t *rtImg;
    uint32_t *size;
};

struct MPoint{
    uint32_t x;
    uint32_t y;
    uint32_t width;
    uint32_t height;
};

struct MrzRoiOCR{
    MichRtImgFltFmt *img;
    char * ocrTxt;
};
#endif