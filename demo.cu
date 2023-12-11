#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <cstdlib>
#include <vector>
#include <algorithm>
#include <chrono>
#include <iostream>

int main(void)
{
    const size_t N = 32 << 20;
    const int K = 5; // Number of times to repeat each operation
    std::vector<int> h_vec_cpu(N);

    // generate 32M random numbers on the host
    thrust::generate(h_vec_cpu.begin(), h_vec_cpu.end(), rand);

    // Run CPU sort K times
    for (int i = 0; i < K; ++i) {
        auto cpu_start = std::chrono::high_resolution_clock::now();
        std::sort(h_vec_cpu.begin(), h_vec_cpu.end());
        auto cpu_end = std::chrono::high_resolution_clock::now();

        // Output the CPU performance
        std::chrono::duration<double, std::milli> cpu_duration = cpu_end - cpu_start;
        std::cout << "CPU sort in " << cpu_duration.count() << " ms\n";
    }

    // transfer data to the device
    thrust::device_vector<int> d_vec = h_vec_cpu;

    std::cout << "--------------------------------------------------\n";
    // ensure all previous CUDA operations have completed

    // sort data on the device K times
    for (int i = 0; i < K; ++i) {
        auto gpu_start = std::chrono::high_resolution_clock::now();
        thrust::sort(d_vec.begin(), d_vec.end());
        auto gpu_end = std::chrono::high_resolution_clock::now();

        // Output the GPU performance
        std::chrono::duration<double, std::milli> gpu_duration = gpu_end - gpu_start;
        std::cout << "GPU sort in " << gpu_duration.count() << " ms\n";
    }

    return 0;
}
