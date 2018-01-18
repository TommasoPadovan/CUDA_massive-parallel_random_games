//
// Created by pado on 17/01/18.
//

#include <host_defines.h>
#include <curand_kernel.h>
#include <device_launch_parameters.h>
#include <curand.h>
#include <curand_kernel.h>
#include <stdio.h>

#define N 1000
#define THREADS 1000

__global__ void init(unsigned int seed, curandState_t* states) {
//    printf("-----------INIT--------------\n");
    unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;
//    printf("id = %u \n", id);
    curand_init(seed, id, 0, &states[id]);
//    printf("curand init to %u, %u, %u\n", seed, id, 0);
//    printf("-----------INIT_END----------\n");

}

__global__ void randoms(curandState_t* states, unsigned int* numbers) {
//    printf("%u \n", blockDim.x);
    unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;
    numbers[id] = curand(&states[id]) % 100;
    for (int i=0; i<3; ++i) {
        printf("Block %u, Thread %u, id %u -> %u \n", blockIdx.x, threadIdx.x, id, curand(&states[id]) % 100);
    }
}


int main(void) {
    /* CUDA's random number library uses curandState_t to keep track of the seed value
     we will store a random state for every thread  */
    curandState_t* states;

    /* allocate space on the GPU for the random states */
    cudaMalloc((void**) &states, N * THREADS * sizeof(curandState_t));

    /* invoke the GPU to initialize all of the random states */
    init<<<N, THREADS>>>(time(0), states);

    /* allocate an array of unsigned ints on the CPU and GPU */
    unsigned int cpu_nums[N];
    unsigned int* gpu_nums;
    cudaMalloc((void**) &gpu_nums, N * sizeof(unsigned int));

    /* invoke the kernel to get some random numbers */
    randoms<<<N, THREADS>>>(states, gpu_nums);

    /* copy the random numbers back */
    cudaMemcpy(cpu_nums, gpu_nums, N * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    /* print them out */
    for (int i = 0; i < N; i++) {
        printf("%u ", cpu_nums[i]);
    }
    printf("\n");

    /* free the memory we allocated for the states and numbers */
    cudaFree(states);
    cudaFree(gpu_nums);

    return 0;
}
