#include <cstdio>
#include <cmath>
#include <cstdlib>
#include "converter.h"


using namespace cv;
extern "C" {

    int clamp(int lower, int higher, int val) {
        if (val < lower)
            return 0;
        else if (val > higher)
            return 255;
        else
            return val;
    }

    int getRotatedImageByteIndex(int x, int y, int rotatedImageWidth) {
        return rotatedImageWidth * (y + 1) - (x + 1);
    }

    //convert image plane to UIntList8
    __attribute__((visibility("default"))) __attribute__((used))
    uint32_t* convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel,
                 int width, int height) {
        int hexFF = 255;
        int x, y, uvIndex, index;
        int yp, up, vp;
        int r, g, b;
        int rt, gt, bt;

        auto *image = (uint32_t *) malloc(sizeof(uint32_t) * (width * height));

        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {

                uvIndex = bytesPerPixel * ((int) floor(x / 2)) + bytesPerRow * ((int) floor(y / 2));
                index = y * width + x;

                yp = plane0[index];
                up = plane1[uvIndex];
                vp = plane2[uvIndex];
                rt = round(yp + vp * 1436 / 1024 - 179);
                gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
                bt = round(yp + up * 1814 / 1024 - 227);
                r = clamp(0, 255, rt);
                g = clamp(0, 255, gt);
                b = clamp(0, 255, bt);
                image[getRotatedImageByteIndex(y, x, height)] =
                        (hexFF << 24) | (b << 16) | (g << 8) | r;
            }
        }
        return image;
    }

    /*
    int _cMat2Bytes(cv::InputArray img,int32_t ** outImgPtr){
        vector<uint8_t> buffer(rawBytes, rawBytes + inBytesCount);
        Mat imgMat = imdecode(buffer, IMREAD_COLOR);

        std::vector<uchar> buf;
        imencode(".jpg",img,buf);
        *outImgPtr=(int32_t *)malloc(buf.size());
        for(int i=0;i<buf.size();i++)
            (*outImgPtr)[i]=buf[i];
        return (int)buf.size();
    }
    __attribute__((visibility("default"))) __attribute__((used))
    int yuv420ToUIntList8(int height,int width,unsigned char * rawBytes,int32_t ** outputBytes){
        Mat imgMat;
        yuv420ToMat(height, width, rawBytes, imgMat);
        int len= _cMat2Bytes(imgMat,outputBytes);
        return len;
    }

    void yuv420ToMat(int height,int width,unsigned char *bytesRaw,Mat outputMat){
        cv::Mat pic(height*3/2,width,CV_8UC1,bytesRaw);
        pic=cv::Mat(height*3/2,width,CV_8UC1,bytesRaw);
        #if (CV_VERSION_MAJOR >= 4)
            cv::cvtColor(pic,outputMat,cv::COLOR_BGR2RGB);
        #else
            cv::cvtColor(pic, rePic, CV_BGR2RGB);
        #endif
    }
     */

    __attribute__((visibility("default"))) __attribute__((used))
    uint32_t* convertTestAndroid(
            uint8_t *plane0,int bytesPerRow0,
            uint8_t *plane1,int length1,int bytesPerRow1,
            uint8_t *plane2,int length2,int bytesPerRow2,
            int width,int height,int orientation)
            {
                uint32_t *image = (uint32_t *) malloc(sizeof(uint32_t) * (width * height));

                Mat img=prepareMatAndroid(
                        plane0,bytesPerRow0,
                        plane1,length1,bytesPerRow1,
                        plane2,length2,bytesPerRow2,
                        width,height,0);
        mat2UIntList8(img, &image);
        return image;
    }
}
//convert Android YUV420 plane to mat
cv::Mat prepareMatAndroid(
        uint8_t *plane0,int bytesPerRow0,
        uint8_t *plane1,int length1,int bytesPerRow1,
        uint8_t *plane2,int length2,
        int bytesPerRow2,int width,int height,int orientation) {

    uint8_t *yPixel = plane0;
    uint8_t *uPixel = plane1;
    uint8_t *vPixel = plane2;

    int32_t uLen = length1;
    int32_t vLen = length2;

    cv::Mat _yuv_rgb_img;
    assert(bytesPerRow0 == bytesPerRow1 && bytesPerRow1 == bytesPerRow2);
    uint8_t *uv = new uint8_t[uLen + vLen];
    memcpy(uv, uPixel, vLen);
    memcpy(uv + uLen, vPixel, vLen);
    cv::Mat mYUV = cv::Mat(height, width, CV_8UC1, yPixel, bytesPerRow0);
    cv::copyMakeBorder(mYUV, mYUV, 0, height >> 1, 0, 0, BORDER_CONSTANT, 0);

    cv::Mat mUV = cv::Mat((height >> 1), width, CV_8UC1, uv, bytesPerRow0);
    cv:Mat dst_roi = mYUV(Rect(0, height, width, height >> 1));
    mUV.copyTo(dst_roi);

    cv::cvtColor(mYUV, _yuv_rgb_img, COLOR_YUV2RGBA_NV21, 3);

    //used to fix the orientation of the image ,the image orientation from
    //mobile device. also we can use flutter_exif_rotation pub to fix before
    //send to c++, so here we no need to fix it!.
    //fixMatOrientation(orientation, _yuv_rgb_img);

    return _yuv_rgb_img;
}
/*
cv::Mat prepareMatIos(uint8_t *plane,
                      int bytesPerRow,
                      int width,
                      int height,
                      int orientation) {
    uint8_t *yPixel = plane;

    cv::Mat mYUV = cv::Mat(height, width, CV_8UC4, yPixel, bytesPerRow);

    //fixMatOrientation(orientation, mYUV);
    return mYUV;
}
*/
//trans opencv mat to intlist8 for mobile terminal
int mat2UIntList8(Mat imgMat,uint32_t ** outImg){
    std::vector<uchar> buf;
    imencode(".jpg", imgMat, buf);
    *outImg = (uint32_t *) malloc(buf.size());
    for (int i=0; i < buf.size(); i++)
        (*outImg)[i] = buf[i];
    return (int) buf.size();
}