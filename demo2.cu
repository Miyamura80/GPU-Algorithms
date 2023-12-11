#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/reduce.h>
#include <thrust/functional.h>
#include <cstdlib>
#include <vector>
#include <numeric>
#include <chrono>
#include <iostream>

// Use the same size for fair comparison
const size_t N = 100000000;
const int NUM_TRIALS = 5; // Number of times to run each test

int main(void) {
    std::vector<int> h_vec_cpu(N);

    // Generate random data on the CPU
    std::generate(h_vec_cpu.begin(), h_vec_cpu.end(), std::rand);

    // Run CPU test multiple times
    for (int i = 0; i < NUM_TRIALS; ++i) {
        // Measure time for CPU sum
        auto cpu_start = std::chrono::high_resolution_clock::now();
        int cpu_sum = std::accumulate(h_vec_cpu.begin(), h_vec_cpu.end(), 0);
        auto cpu_end = std::chrono::high_resolution_clock::now();

        // Output the CPU performance
        std::chrono::duration<double, std::milli> cpu_duration = cpu_end - cpu_start;
        std::cout << "CPU sum: " << cpu_sum << " in " << cpu_duration.count() << " ms\n";
    }

    // Initialize Thrust host vector with the same random data for fair comparison
    thrust::host_vector<int> h_vec_gpu(h_vec_cpu.begin(), h_vec_cpu.end());
    std::cout << "--------------------------------------------------\n";

    // Run GPU test multiple times
    for (int i = 0; i < NUM_TRIALS; ++i) {
        // Transfer to device and compute sum
        thrust::device_vector<int> d_vec_gpu = h_vec_gpu;

        // Measure time for GPU sum
        auto gpu_start = std::chrono::high_resolution_clock::now();
        int gpu_sum = thrust::reduce(d_vec_gpu.begin(), d_vec_gpu.end(), 0, thrust::plus<int>());
        auto gpu_end = std::chrono::high_resolution_clock::now();

        // Output the GPU performance
        std::chrono::duration<double, std::milli> gpu_duration = gpu_end - gpu_start;
        std::cout << "GPU sum: " << gpu_sum << " in " << gpu_duration.count() << " ms\n";
    }

    return 0;
}
