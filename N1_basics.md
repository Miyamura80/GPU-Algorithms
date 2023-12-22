
# Basic Operations

```cpp
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>

#include <iostream>

int main(void){
    // Init host & device vector
    thrust::host_vector<int> H(4);
    
    // Init device as host
    thrust::device_vector<int> D = H;


    // Read
    std::cout << "H[" << H.size() << "] = " << H[H.size()] << std::endl;

    // Write
    D[0] = 3;
    D.resize(2);

    // print Y
    thrust::copy(D.begin(), D.end(), std::ostream_iterator<int>(std::cout, "\n"));
}
```

# Init
```cpp
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <thrust/copy.h>
#include <thrust/fill.h>
#include <thrust/sequence.h>

#include <iostream>

int main(void)
{
    // initialize all ten integers of a device_vector to 1
    // D = [1,1,1,1,1,1,1,1,1,1]
    thrust::device_vector<int> D(10, 1); 

    // set the first seven elements of a vector to 9
    // D = [9,9,9,9,9,9,9,1,1,1]
    thrust::fill(D.begin(), D.begin() + 7, 9);

    // initialize a host_vector with the first five elements of D
    // H = [D[0], D[1], D[2], D[3], D[4]]
    thrust::host_vector<int> H(D.begin(), D.begin() + 5);

    // set the elements of H to 0, 1, 2, 3, ...
    // H = [0, 1, 2, 3, 4]
    thrust::sequence(H.begin(), H.end());

    // copy all of H back to the beginning of D
    // D = [H[0], H[1], H[2], H[3], H[4],9,9,1,1,1]
    thrust::copy(H.begin(), H.end(), D.begin());

    return 0;
}

```

# Implementation Details
-  `thurst` uses iterators for `H.begin()` and `H.end()` (similar for `D`) which is used to infer the type of the construct
    - Can pass raw pointer as well, but if it is `device` pointer, have to use `thrust::device_ptr`, converting `host` pointer to `device` pointer
        ```cpp
        size_t N = 10;

        // raw pointer to device memory
        int * raw_ptr;
        cudaMalloc((void **) &raw_ptr, N * sizeof(int));

        // wrap raw pointer with a device_ptr
        thrust::device_ptr<int> dev_ptr(raw_ptr);

        // use device_ptr in thrust algorithms
        thrust::fill(dev_ptr, dev_ptr + N, (int) 0);
        ```
        Going from `device` pointer -> `host` pointer:
        ```cpp
        size_t N = 10;

        // create a device_ptr
        thrust::device_ptr<int> dev_ptr = thrust::device_malloc<int>(N);

        // extract raw pointer from device_ptr
        int * raw_ptr = thrust::raw_pointer_cast(dev_ptr);
        ```
