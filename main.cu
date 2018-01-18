#include <helper_cuda.h>
#include <stdio.h>
#include <iostream>
#include <host_defines.h>
#include <device_launch_parameters.h>
#include <cuda_runtime_api.h>
#include <time.h>
#include <stdlib.h>
#include <curand.h>
#include <curand_kernel.h>
//#include "walker.h"
#include <iostream>
#include <fstream>

#define BLOCKS 2048
#define THREADS 1024
#define PER_THREAD_EXP 65536

__device__ int rng(curandState_t state) {
    return curand(&state) % 4;
}




//__device__ bool randomWalk(Walker a, Walker b, curandState_t state) {
//    a.setXY(0, 0);
//    b.setXY(2, 2);
//    for (int i=0; i<3; ++i) {
//        a.walk(state);
//        b.walk(state);
//        if (a.getX() == b.getX() && a.getY() == b.getY()) {
//            printf("sciabbe'\n");
//            return  true;
//        }
//    }
//    printf("me alone\n");
//    return false;
//}

__global__ void init(unsigned int seed, curandState_t* states) {
    unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(seed, id, 0, &states[id]);
}

__global__ void simulate_kernel(curandState_t* states, int* C) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;

    int meetings = 0;
    for (int k = 0; k < PER_THREAD_EXP; ++k) {
        bool meet = false;
        int xa = 0;
        int ya = 0;
        int xb = 2;
        int yb = 2;
        for (int i = 0; i < 3; ++i) {
            int moveA = curand(&states[id]) % 4;
            int moveB = curand(&states[id]) % 4;
            switch (moveA) {
                case 0:
                    xa++;
                    break;
                case 1:
                    xa--;
                    break;
                case 2:
                    ya++;
                    break;
                case 3:
                    ya--;
                    break;
                default:
                    printf("really you shouldn't be here");
                    break;
            }
            switch (moveB) {
                case 0:
                    xb++;
                    break;
                case 1:
                    xb--;
                    break;
                case 2:
                    yb++;
                    break;
                case 3:
                    yb--;
                    break;
                default:
                    printf("really you shouldn't be here");
                    break;
            }
//            if (xa == xb && ya == yb) {
//                ++meetings;
//                break;
//            }
            //those lines remove the if to minimize warp divergence
            meet = meet || (xa == xb && ya == yb);
        }
        meetings += meet;
    }
//    printf("block %u, thread %u, meetings %u \n", blockIdx.x, threadIdx.x, meetings);
    atomicAdd(&C[blockIdx.x], meetings);
//    C[blockIdx.x] += meetings;

}



int main() {

    //init random states
    curandState_t* states;
    cudaMalloc((void**) &states, BLOCKS * THREADS * sizeof(curandState_t));
    init<<<BLOCKS, THREADS>>>(time(0), states);

    //
    const unsigned int size = BLOCKS /* *THREADS */;
    int C[size] = {0};
    int *Cd = C;
    cudaMalloc((void**) &Cd, size*sizeof(int));
    cudaMemcpy(Cd, C, size*sizeof(int), cudaMemcpyHostToDevice);

    simulate_kernel<<<BLOCKS,THREADS>>>(states, Cd);



    cudaDeviceSynchronize();
    getLastCudaError("Kernel execution failed");

    //copying result back
    cudaMemcpy(C, Cd, size*sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(Cd);
    cudaFree(states);
    

    long double success = 0;
    for (int i = 0; i<size; ++i) {
        success +=  (long double)C[i]/(long double)(THREADS * PER_THREAD_EXP);
    }
//    long long totExp = BLOCKS * THREADS * PER_THREAD_EXP;
//    std::cout << "P = " << std::scientific << success << " / " << totExp << std::endl;

    //hello
    std::ifstream swagFile("swag.txt");
    if (swagFile.is_open())
        std::cout << std::endl << swagFile.rdbuf() << std::endl << std::endl;
    printf("total experiments = %u * %u * %u \n", BLOCKS, THREADS, PER_THREAD_EXP);
//    printf("P = %llu / %llu \n", success, totExp);
    printf("P = %Le \n", success/(long double)BLOCKS);




    return 0;
}
