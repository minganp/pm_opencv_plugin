cmake_minimum_required(VERSION 3.6.0)
project(pass_mrz)
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

#include(${CMAKE_CURRENT_SOURCE_DIR}/ocrTrainedData/CMakeLists.txt)

add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(lib_leptonica SHARED IMPORTED)
set_target_properties(lib_leptonica PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libleptonica.so)

add_library(lib_jpeg SHARED IMPORTED)
set_target_properties(lib_jpeg PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libjpeg.so)

add_library(lib_png SHARED IMPORTED)
set_target_properties(lib_png PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libpng.so)

add_library(lib_tesseract SHARED IMPORTED)
set_target_properties(lib_tesseract PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libtesseract.so)

set(SOURCES
    ../ios/Classes/nativeC/main.cpp
)
add_library(OpenCV_ffi SHARED ${SOURCES})
find_library(log-lib log)

target_link_libraries(OpenCV_ffi lib_leptonica lib_jpeg lib_png lib_tesseract lib_opencv ${log-lib})
#target_link_libraries(OpenCV_ffi lib_opencv ${log-lib})