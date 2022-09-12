//
// Created by Mingan Peng on 9/9/22.
//

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


