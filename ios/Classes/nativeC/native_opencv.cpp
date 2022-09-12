#include <android/log.h>
#include <opencv2/opencv.hpp>

#define  LOG_TAG    "CVPLUGIN"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)

using namespace cv;
using namespace std;


// Avoiding name mangling
// Attributes to prevent 'unused' function from being removed and to make it visible
    const int height = 600;

    __attribute__((visibility("default"))) __attribute__((used))
    const char *version() {
        return CV_VERSION;
    }

    void process_image(const char *inputImagePath, const char *outputImagePath) {
        Mat input = imread(inputImagePath, IMREAD_GRAYSCALE);
        Mat threshed, withContours;
        LOGI("Hello world! You can use ");
        //__android_log_print(ANDROID_LOG_INFO, "Info", "------ %s", outputImagePath);

        vector<vector<Point>> contours;
        vector<Vec4i> hierarchy;

        adaptiveThreshold(input, threshed, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 77, 6);
        findContours(threshed, contours, hierarchy, RETR_TREE, CHAIN_APPROX_TC89_L1);

        cvtColor(threshed, withContours, COLOR_GRAY2BGR);
        drawContours(withContours, contours, -1, Scalar(0, 255, 0), 4);

        imwrite(outputImagePath, withContours);
    }

    void _rect_kernel(OutputArray outArray) {
        Point _rkp = Point(5, 13);
        getStructuringElement(MORPH_RECT, _rkp).copyTo(outArray);
    }
    void _sq_kernel(OutputArray outArray) {
        Point _sqp = Point(33, 33);
        getStructuringElement(MORPH_RECT, _sqp).copyTo(outArray);
    }

    void _resize(InputArray imgArray,OutputArray outArray) {
        int _height = imgArray.size().height;
        int _width = imgArray.size().width;
        int _new_width = int(_width * _height / _height);
        Size _size = Size(_new_width,height);
        resize(imgArray, outArray, _size);
    }
    void _smooth(InputArray imgArray,OutputArray outArray) {
        /*
        Convert image to gray scale and smooth image with gaussian blur
        :param np.ndarray image: resized image array
        :return: smoothed image
        :rtype: np.ndarray
        */
        cvtColor(imgArray, outArray, COLOR_BGR2GRAY);
    }
    void _find_dark_regions(InputArray imgArray,OutputArray outArray){
        /*
        Morphological operator to find dark regions on a light background
        :param np.ndarray image: smoothed image array
        :return: blackhat image
        :rtype: np.ndarray
        */
        Mat _kerArr;
        _rect_kernel(_kerArr);
        morphologyEx(imgArray, outArray, MORPH_BLACKHAT, _kerArr);
    }

    void _apply_threshold(InputArray imgArray,OutputArray outArray) {
        /*
        Highlight the mrz code area with closing operations and erosions
        :param np.ndarray image: blackhat image array
        :return: threshold applied image
        :rtype: np.ndarray
        */
        Mat _outArray;

        //compute the Scharr gradient
        Sobel(imgArray, _outArray, CV_32F, 1, 0, -1);
        _outArray = abs(_outArray);
        double _min, _max;
        minMaxLoc(_outArray, &_min, &_max);

        Mat _scaled = (_outArray - _min) / (_max - _min);

        //scale the result into the range [0, 255]
        _scaled.convertTo(_outArray, CV_8U);

        //another closing operation to close gaps between lines of the MRZ
        threshold(_outArray, _outArray, 0, 255, THRESH_BINARY | cv::THRESH_OTSU);

        //perform a series of erosions to break apart connected components
        Mat _sqArr;
        _sq_kernel(_sqArr);
        morphologyEx(_outArray, _outArray, MORPH_CLOSE, _sqArr);

        //perform a series of erosions to break apart connected components
        erode(_outArray, _outArray, Mat(), Point(-1, 1), 4);

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

    bool _compareContoursAreas(const vector<Point2i> _c1,const vector<Point2i> _c2){
        double i=abs(contourArea(Mat(_c1)));
        double j=abs(contourArea(Mat(_c2)));
        return i<j;
    }
    void _find_coordinates(InputArray threshImage, InputArray darkImage,Rect rect) {
        /*
        Find coordinates of the mrz code area
        :param np.ndarray im_thresh: threshold applied image array
        :param np.ndarray im_dark: blackhat image array
        :return: coordinates of the mrz code area
        :rtype: tuple[y, y1, x, x1]
         */
        vector<vector<Point2i>> contours;
        findContours(threshImage, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
        std::sort(contours.begin(), contours.end(), _compareContoursAreas);
        for(auto & contour : contours){
            Rect _rect;
            _rect = boundingRect(contour);
            float aspect = float(_rect.width) / float(_rect.height);
            float cr_width = float(_rect.width) / float(darkImage.size().width);
            if (aspect > 5 && cr_width > 0.5) {
                int px = int((_rect.x + _rect.width) * 0.03);
                int py = int((_rect.y + _rect.height) * 0.03);
                int w = _rect.width + (px * 2);
                int h = _rect.height + (py * 2);
                rect.x=px;
                rect.y=py;
                rect.width=w;
                rect.height=h;
                break;
            }
        }
    }

    void _get_mrz(InputArray inputArray,Rect _rect){
        Mat _resized,_smoothed,_dark,_thresh;
        _resize(inputArray,_resized);
        _smooth(_resized,_smoothed);
        _find_dark_regions(_smoothed,_dark);
        _apply_threshold(_dark,_thresh);
        _find_coordinates(_thresh, _smoothed,_rect);
    }
    //convert image info from dart to Mat
    /*
    int _fImg2CMat(int h,int w,uchar* rawBytes,uchar** encodedOutput){
        Mat img=Mat(h,w,CV_8UC3,rawBytes);
        vector<uchar> buf;
        imencode(".jpg",img,buf);
        *encodedOutput=(unsigned char *) malloc(buf.size());
        for (int i=0;i<buf.size();i++)
            (*encodedOutput)[i]=buf[i];
        Mat
        return (int)buf.size();
    }
    */
    void _fImg2CMat(int h,int w,uchar* rawBytes,Mat outMat){
        Mat(h,w,CV_8UC3,rawBytes,Mat::AUTO_STEP).copyTo(outMat);
    }
    int _cMat2Bytes(InputArray img,uchar** outImgPtr){
        vector<uchar> buf;
        imencode(".jpg",img,buf);
        *outImgPtr=(unsigned char *)malloc(buf.size());
        for(int i=0;i<buf.size();i++)
            (*outImgPtr)[i]=buf[i];
        return (int)buf.size();
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void get_mrz(int h,int w,uchar* rawBytes,Rect rect){
        Mat _img;
        _fImg2CMat(h,w,rawBytes,_img);
        _get_mrz(_img,rect);
    }

    int resized(int h,int w,uchar* rawBytes,uchar** outBytes){
        Mat _outImg;
        _fImg2CMat(h,w,rawBytes,_outImg);
        _resize(_outImg,_outImg);
        return _cMat2Bytes(_outImg,outBytes);
    }


