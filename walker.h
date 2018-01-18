////
//// Created by pado on 17/01/18.
////
//
//#ifndef IBANPARALLEL_WALKER_H
//#define IBANPARALLEL_WALKER_H
//
//#include <host_defines.h>
//#include <curand_kernel.h>
//
//__device__ int rng(curandState_t state) {
//    return curand(&state) % 4;
//}
//
//class Walker {
//public:
//    __device__ Walker(int x0, int y0) {
//        x = x0;
//        y = y0;
//    }
//    __device__ ~Walker() {}
//
//    __device__ int getX() const {
//        return x;
//    }
//
//    __device__ int getY() const {
//        return y;
//    }
//
//    __device__ void setXY(int x0, int y0) {
//        x = x0;
//        y = y0;
//    }
//
////    __device__ void printp(std::string label) {
////        std::cout << label << " = " << "(" << x << "," << y << ")" << std::endl;
////    }
//
//    __device__ void walk(curandState_t state) {
//        int direction = rng(state) % static_cast<int>(4);
////        printf("direction %u \n", direction);
//        switch(direction) {
//            case 0:
//                ++x;
//                break;
//            case 1:
//                --x;
//                break;
//            case 2:
//                ++y;
//                break;
//            case 3:
//                --y;
//                break;
//        }
//    }
//
//    __device__ bool meets(const Walker& otherWalker) {
//        return (x == otherWalker.getX() && y == otherWalker.getY());
//    }
//
//private:
//    int x;
//    int y;
//};
//#endif //IBANPARALLEL_WALKER_H
