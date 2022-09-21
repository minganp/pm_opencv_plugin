cmake_minimum_required(VERSION 3.6.0)
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(lib_tesseract SHARED IMPORTED)
set_target_properties(lib_tesseract PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libtesseract.so)

set(SOURCES
    ../ios/Classes/nativeC/main.cpp
)
add_library(OpenCV_ffi SHARED ${SOURCES})

find_library(log-lib log)

target_link_libraries(OpenCV_ffi lib_tesseract lib_opencv ${log-lib})