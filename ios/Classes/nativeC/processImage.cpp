//
// Created by Mingan Peng on 9/9/22.
//

    cv::Mat genMatAndroid(
            uint8_t *plane0, int bytesPerRow0,
            uint8_t *plane1, int length1, int bytesPerRow1,
            uint8_t *plane2, int length2, int bytesPerRow2,
            int width, int height, int orientation
    ) {
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
        cv:
        Mat dst_roi = mYUV(Rect(0, height, width, height >> 1));
        mUV.copyTo(dst_roi);

        cv::cvtColor(mYUV, _yuv_rgb_img, COLOR_YUV2RGBA_NV21, 3);

        //fixMatOrientation(orientation, _yuv_rgb_img);

        return _yuv_rgb_img;
    }

    cv::Mat prepareMat(Img *img) {

        if (img->platform == 0) {
            //implementation for ios
        } else if (img->platform == 1) {

            auto *plan0 = img->plane;
            auto *plan1 = plan0->nextPlanePtr;
            auto *plan2 = plan1->nextPlanePtr;
            return genMatAndroid(
                    plan0->planeData,plan0->bytesPerRow,
                    plan1->planeData,plan1->length,plan1->bytesPerRow,
                    plan2->planeData,plan2->length,plan2->bytesPerRow,
                    img->width,img->height,img->orientation
                    );
        }
        throw "Cant parse image data due to the unknown platform";
    }



    MichRtImgFltFmt *mat2MichRtImg(cv::Mat imgMat){
        std::vector<uchar> buf;
        imencode(".jpg", imgMat, buf);
        LOGI("-----from native before create mat2MichRtImg. size: d");

        MichRtImgFltFmt * imgUInt8p=(struct MichRtImgFltFmt *)malloc(sizeof(struct MichRtImgFltFmt));
        LOGI("-----from native after create mat2MichRtImg. size: d");

        int size = buf.size();
        LOGI("-----from native after get size. size: %d",size);

        LOGI("-----from native mat2MichRtImg. size: %d",size);
        imgUInt8p->rtImg = (uint8_t *) malloc(size);
        imgUInt8p->size = (uint32_t *) malloc(1);
        *(imgUInt8p->size) = size;
        memcpy(imgUInt8p->rtImg,buf.data(),buf.size());
        LOGI("-----from native mat2MichRtImg. memcpy finished: $d");

        return imgUInt8p;
        /*
        *outImg = (uint32_t *) malloc(buf.size());
        for (int i = 0; i < buf.size(); i++)
            (*outImg)[i] = buf[i];
        */
        //memcpy(rtImg->rtImg,buf.data(),buf.size());
        //rtImg->size[0]=buf.size();

    }
void mat2MichRtImg2(cv::Mat imgMat,uchar *outImg,uint *size){

    std::vector<uchar> buf;
    imencode(".jpg", imgMat, buf);

    /*
    *outImg = (uint32_t *) malloc(buf.size());
    for (int i = 0; i < buf.size(); i++)
        (*outImg)[i] = buf[i];
    */
    memcpy(outImg,buf.data(),buf.size());
    size[0]=buf.size();

}
    MichRtImgFltFmt * processAndroidImage(Img *img) {

        cv::Mat imgMat=prepareMat(img);
        //MichRtImgFltFmt *rtImgFltFmt=createRtImgFmt();
        //LOGI("-------struct address:%d",rtImgFltFmt);
        //LOGI("-------struct img address:%d",rtImgFltFmt->rtImg);

        return mat2MichRtImg(imgMat);
        //LOGI("-------native opencv info: return image size: %d",rtImgFltFmt->size[0]);
        //return rtImgFltFmt;
    }

    void processAndroidImage2(Img * img,uchar *buf,uint *size){
       // LOGI("-------struct address:%d",rtImgFltFmt);
       // LOGI("-------struct img address:%d",rtImgFltFmt->rtImg);

        cv::Mat imgMat = prepareMat(img);
        mat2MichRtImg2(imgMat,buf,size);
}