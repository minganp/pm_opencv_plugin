//
// Created by Mingan Peng on 9/15/22.
//

#ifndef ANDROID_ROI_MRZ_PASSPORT_H
#define ANDROID_ROI_MRZ_PASSPORT_H
#include <opencv2/opencv.hpp>

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MichRtImgFltFmt *getRoiMrzStepByStep(Img *img);

cv::Mat getMrzRoiMat(Img *img);

#endif //ANDROID_ROI_MRZ_PASSPORT_H
