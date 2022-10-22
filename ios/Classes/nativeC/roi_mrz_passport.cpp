//
// Created by Mingan Peng on 9/15/22.
//

#include "processImage.h"
#include <opencv2/opencv.hpp>

int height=600;
void toGray(cv::InputArray imgArray,cv::OutputArray outArray) {
    cv::cvtColor(imgArray, outArray, cv::COLOR_BGR2GRAY);
}
void smooth(cv::InputArray imgArray,cv::OutputArray outArray) {
    /*
    Convert image to gray scale and smooth image with gaussian blur
    :param np.ndarray image: resized image array
    :return: smoothed image
    :rtype: np.ndarray
    */
   // cv::Mat gray;
   // cv::cvtColor(imgArray, gray, cv::COLOR_BGR2GRAY);

    cv::GaussianBlur(imgArray,outArray,cv::Size(3,3),0);
}
void _rect_kernel(cv::OutputArray outArray) {
    cv::Point _rkp = cv::Point(5, 13);
    getStructuringElement(cv::MORPH_RECT, _rkp).copyTo(outArray);
}
void _resize(cv::InputArray imgArray,cv::OutputArray outArray) {
    int _height = imgArray.size().height;
    int _width = imgArray.size().width;
    int _new_width = int(_width * _height / _height);
    cv::Size _size = cv::Size(_new_width,height);
    resize(imgArray, outArray, _size);
}
void find_dark_regions(cv::InputArray imgArray,cv::OutputArray outArray){
    /*
    Morphological operator to find dark regions on a light background
    :param np.ndarray image: smoothed image array
    :return: blackhat image
    :rtype: np.ndarray
    */
    cv::Mat _kerArr;
    _rect_kernel(_kerArr);
    morphologyEx(imgArray, outArray, cv::MORPH_BLACKHAT, _kerArr);
}
void _sq_kernel(cv::OutputArray outArray) {
    cv::Point _sqp = cv::Point(33, 33);
    getStructuringElement(cv::MORPH_RECT, _sqp).copyTo(outArray);
}
void _apply_threshold(cv::InputArray imgArray,cv::OutputArray outArray) {
    /*
    Highlight the mrz code area with closing operations and erosions
    :param np.ndarray image: blackhat image array
    :return: threshold applied image
    :rtype: np.ndarray
    */
    cv::Mat _outArray;

    //compute the Scharr gradient
    Sobel(imgArray, _outArray, CV_32F, 1, 0, -1);
    _outArray = abs(_outArray);
    double _min, _max;
    minMaxLoc(_outArray, &_min, &_max);

    cv::Mat _scaled = (_outArray - _min) / (_max - _min);

    //scale the result into the range [0, 255]
    _scaled.convertTo(_outArray, CV_8U);

    //another closing operation to close gaps between lines of the MRZ
    threshold(_outArray, _outArray, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);

    //perform a series of erosions to break apart connected components
    cv::Mat _sqArr;
    _sq_kernel(_sqArr);
    morphologyEx(_outArray, _outArray, cv::MORPH_CLOSE, _sqArr);

    //perform a series of erosions to break apart connected components
    erode(_outArray, _outArray, cv::Mat(), cv::Point(-1, 1), 4);

    //set 5% of the left and right borders to zero because of
    //probability border pixels were included in the thresholding
    int _width = imgArray.size().width;
    int _p_val = int(_width * 0.05);
    for (int i = 0; i < _p_val; i++)
        _outArray.col(i) = 0;

    for (int i = _width - _p_val; i < _width; i++)
        _outArray.col(i) = 0;
    _outArray.copyTo(outArray);
}
bool _compareContoursAreas(const std::vector<cv::Point> _c1,const std::vector<cv::Point> _c2){
    double i=abs(contourArea(cv::Mat(_c1)));
    double j=abs(contourArea(cv::Mat(_c2)));
    return i<j;
}
void _find_coordinates(cv::InputArray threshImage, cv::InputArray darkImage,cv::Rect *rect) {
    /*
    Find coordinates of the mrz code area
    :param np.ndarray im_thresh: threshold applied image array
    :param np.ndarray im_dark: blackhat image array
    :return: coordinates of the mrz code area
    :rtype: tuple[y, y1, x, x1]
     */
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(threshImage, contours, hierarchy,cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE,cv::Point(0,0));
    LOGI("Found contours: %d",contours.size());
    std::sort(contours.begin(), contours.end(), _compareContoursAreas);
    for(auto & contour : contours){
        cv::Rect _rect;
        _rect = boundingRect(contour);
        double aspect = (double)_rect.width / (double)_rect.height;
        double cr_width = (double)_rect.width / (double)darkImage.size().width;
        LOGI("Contour: x:%d,y:%d,w:%d,h:%d,aspect:%f,cr_width:%f",
             _rect.x,_rect.y,_rect.width,_rect.height,aspect,cr_width);

        if (aspect > 5.0 && cr_width > 0.5) {
            int px = int((_rect.x + _rect.width) * 0.03);
            int py = int((_rect.y + _rect.height) * 0.03);
            int w = _rect.width + (px * 2);
            int h = _rect.height + (py * 2);
            LOGI("ROI info: px:%d,py:%d,w:%d,h:%d",px,py,w,h);
            rect->x = _rect.x - px;
            rect->y = _rect.y - py;
            rect->width = w;
            rect->height = h;
            break;
        }
    }
}

cv::Mat getMrzRoiMat(ImgForProcess *imgForProcess){
    cv::Mat _resized;
    cv::Mat _pDark;
    cv::Mat _pThresh;
    cv::Mat _pSmoothed;
    cv::Mat _gray;
    cv::Rect _rect;

    cv::Mat imgMat=prepareMat(imgForProcess->img);
    _resize(imgMat,_resized);
    toGray(_resized,_gray);
    smooth(_gray,_pSmoothed);
    find_dark_regions(_pSmoothed,_pDark);
    _apply_threshold(_pDark,_pThresh);
    _find_coordinates(_pThresh,_pSmoothed,&_rect);
    LOGI("ROI X: %d,ROI Y: %d,ROI W: %d,ROI H: %d",_rect.x,_rect.y,_rect.width,_rect.height);

    return _resized(_rect);
}

cv::Mat getMrzRoiMatRect(ImgForProcess *imgForProcess,MRect *mRect){
    cv::Mat _resized;
    cv::Mat _pDark;
    cv::Mat _pThresh;
    cv::Mat _pSmoothed;
    cv::Mat _gray;
    cv::Rect _rect;

    cv::Mat imgMat=prepareMat(imgForProcess->img);
    _resize(imgMat,_resized);
    toGray(_resized,_gray);
    smooth(_gray,_pSmoothed);
    find_dark_regions(_pSmoothed,_pDark);
    _apply_threshold(_pDark,_pThresh);
    _find_coordinates(_pThresh,_pSmoothed,&_rect);
    LOGI("ROI X: %d,ROI Y: %d,ROI W: %d,ROI H: %d",_rect.x,_rect.y,_rect.width,_rect.height);

    mRect->x = _rect.x;
    mRect->y = _rect.y;
    mRect->width = _rect.width;
    mRect->height = _rect.height;

    return _resized(_rect);

}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
MichRtImgFltFmt *getRoiMrzStepByStep(Img *img){
    cv::Mat _resized;
    cv::Mat _pDark;
    cv::Mat _pThresh;
    cv::Mat _pSmoothed;
    cv::Rect _rect;

    cv::Mat imgMat=prepareMat(img);
    _resize(imgMat,_resized);
    smooth(_resized,_pSmoothed);
    find_dark_regions(_pSmoothed,_pDark);
    _apply_threshold(_pDark,_pThresh);
    _find_coordinates(_pThresh,_pSmoothed,&_rect);
    LOGI("ROI X: %d,ROI Y: %d,ROI W: %d,ROI H: %d",_rect.x,_rect.y,_rect.width,_rect.height);

    //return mat2MichRtImg(_pThresh);
    return mat2MichRtImg(_resized(_rect));

}