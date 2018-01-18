cmake_minimum_required(VERSION 3.8)
project(ibanParallel)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cu rnd.cu walker.h)
add_executable(ibanParallel ${SOURCE_FILES})