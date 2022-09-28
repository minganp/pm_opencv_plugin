//
// Created by Mingan Peng on 9/8/22.
//

#include "michImage.h"
Plane *createImagePlane() {
    return (struct Plane *) malloc(sizeof(struct Plane));
}
Img *createImage(){
    return (struct Img *) malloc(sizeof(struct Img));
}

MichRtImgFltFmt *createRtImgFmt(){
    return (struct MichRtImgFltFmt *) malloc((sizeof(struct MichRtImgFltFmt)));
}

MrzRoiOCR *createMrzRoiOCR(){
    return (struct MrzRoiOCR *) malloc((sizeof(struct MrzRoiOCR)));
}

ProcessArgument *createProcessArgumentP(){
    return (struct ProcessArgument*) malloc((sizeof (struct ProcessArgument)));
}
ImgForProcess *createImagePorProcess(){
    return (struct ImgForProcess*) malloc((sizeof (struct ImgForProcess)));
}
