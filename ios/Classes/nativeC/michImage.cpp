//
// Created by Mingan Peng on 9/8/22.
//


Plane *createImagePlane() {
    return (struct Plane *) malloc(sizeof(struct Plane));
}
Img *createImage(){
    return (struct Img *) malloc(sizeof(struct Img));
}

MichRtImgFltFmt *createRtImgFmt(){
    return (struct MichRtImgFltFmt *) malloc((sizeof(struct MichRtImgFltFmt)));
}

