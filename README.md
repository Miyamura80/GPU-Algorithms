# GPU-Algorithms
Playing around with Thrust, and other GPU Algorithms

# Demo Comparisons:

## Sorting:

`demo1.cu`

```
nvcc -O2 -gencode arch=compute_86,code=sm_86 demo.cu -o build/thrust_sort
./build/thrust_sort
CPU sort in 3133.77 ms
CPU sort in 523.632 ms
CPU sort in 525.84 ms
CPU sort in 538.64 ms
CPU sort in 528.767 ms
--------------------------------------------------
GPU sort in 6.21531 ms
GPU sort in 7.56116 ms
GPU sort in 7.6428 ms
GPU sort in 7.64368 ms
GPU sort in 7.76629 ms
```

## Sum reduction:

`demo2.cu`

```
(base) eito@EitoZbook:~/GPU-Algorithms$ make run
nvcc -O2 -gencode arch=compute_86,code=sm_86 demo2.cu -o build/thrust_sort
./build/thrust_sort
CPU sum: 563608529 in 27.1164 ms
CPU sum: 563608529 in 30.1195 ms
CPU sum: 563608529 in 29.2672 ms
CPU sum: 563608529 in 31.0961 ms
CPU sum: 563608529 in 31.8511 ms
--------------------------------------------------
GPU sum: 563608529 in 2.01526 ms
GPU sum: 563608529 in 2.3816 ms
GPU sum: 563608529 in 2.3094 ms
GPU sum: 563608529 in 2.21172 ms
GPU sum: 563608529 in 2.21746 ms
```

