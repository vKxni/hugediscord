cmake_minimum_required(VERSION 3.8)

project(crow)
set(LIBRARY_NAME crow)
set(LIBRARY_FOLDER crow)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${crow_SOURCE_DIR}/cmake/")

if(TOKEN)
    add_definitions(-DTOKEN="${TOKEN}")
else()
    message(SEND_ERROR "You need to specify token")
    return()
endif()

if(PREFIX)
    add_definitions(-DPREFIX="${PREFIX}")
else()
    message(SEND_ERROR "You need to specify prefix")
    return()
endif()

include_directories("${CMAKE_SOURCE_DIR}/include")
file(GLOB SOURCE_LIB "${CMAKE_SOURCE_DIR}/src/*.c")

find_package(CURL)
if(NOT CURL_FOUND)
    message(SEND_ERROR "Failed to find CURL")
    return()
else()
    include_directories(${CURL_INCLUDE_DIR})
endif()

find_package(JSON-C)
if (NOT JSON-C_FOUND)
    message(SEND_ERROR "Failed to find json-c")
    return()
else()
    include_directories(${JSON-C_INCLUDE_DIRS})
endif()

include_directories("${CMAKE_SOURCE_DIR}/deps/libwsclient")
include_directories("${CMAKE_SOURCE_DIR}/deps/librequests/include")


add_library(crow STATIC ${SOURCE_LIB})
add_subdirectory(tests)