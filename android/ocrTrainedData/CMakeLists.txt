
set(TRAINNEDFILE ${CMAKE_CURRENT_SOURCE_DIR}/ocrTrainedData/mrz.traineddata)
file(COPY ${TRAINNEDFILE} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
set(train_file_path ${CMAKE_CURRENT_BINARY_DIR}/${TRAINNEDFILE})
set(TRAINDATA_PATH "    \"${train_file_path}\"")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ocrTrainedData/tessTrain.h.in ${CMAKE_CURRENT_BINARY_DIR}/tessTrain.h @ONLY)
include_directories( ${CMAKE_CURRENT_BINARY_DIR} )