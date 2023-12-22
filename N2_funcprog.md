
# Functional programming

```cpp
#include <thrust/device_vector.h>
#include <thrust/device_vector.h>
#include <thrust/transform.h>
#include <thrust/sequence.h>
#include <thrust/copy.h>
#include <thrust/fill.h>
#include <thrust/replace.h>
#include <thrust/functional.h>
#include <iostream>

#include <iostream>
int main(void)
{
    // allocate three device_vectors with 10 elements
    thrust::device_vector<int> X(10);
    thrust::device_vector<int> Y(10);
    thrust::device_vector<int> Z(10);
    
    // 1) Map pre-defined thrust functions
    // y = map (\j -> -j) X
    thrust::transform(X.begin(), X.end(), Y.begin(), thrust::negate<int>());

    // 2) Vector-vector Operations
    // z = [2]*10
    thrust::fill(Z.begin(), Z.end(), 2);
    // Y = X mod Z
    thrust::transform(X.begin(), X.end(), Z.begin(), Y.begin(), thrust::modulus<int>());

    // 3) Replace certain elements with another 
    // map (\j -> 10 if j==0 else j) Y
    thrust::replace(Y.begin(), Y.end(), 1, 10);



    return 0;
}
```

## More sophisticated `map` 

For computation of form `y <- a * x + y>` where `a` scalar and `x,y` vector

**Sharp bit:** Actually, applying the operation in CPU is faster, than having a vector of `[a,a,...,a]` and applying vector operations, since operations are __memory-bound__. Solve with **operator fusion** 

`fast_saxpy`: performs 2N reads and N writes
`slow_saxpy`: performs 4N reads and 3N writes

```cpp
struct saxpy_functor
{
    const float a;

    saxpy_functor(float _a) : a(_a) {}

    __host__ __device__
        float operator()(const float& x, const float& y) const {
            return a * x + y;
        }
};

void saxpy_fast(float A, thrust::device_vector<float>& X, thrust::device_vector<float>& Y)
{
    // Y <- A * X + Y
    thrust::transform(X.begin(), X.end(), Y.begin(), Y.begin(), saxpy_functor(A));
}

void saxpy_slow(float A, thrust::device_vector<float>& X, thrust::device_vector<float>& Y)
{
    thrust::device_vector<float> temp(X.size());

    // temp <- A
    thrust::fill(temp.begin(), temp.end(), A);

    // temp <- A * X
    thrust::transform(X.begin(), X.end(), temp.begin(), temp.begin(), thrust::multiplies<float>());

    // Y <- A * X + Y
    thrust::transform(temp.begin(), temp.end(), Y.begin(), Y.begin(), thrust::plus<float>());
}

```

## Takeaways: 

`thrust::transform` only supports transformations with one or two input arguments (e.g. $f(x) \rightarrow y$ and $f(x,y) \rightarrow z$). When a transformation uses more than two input arguments it is necessary to use a different approach. The arbitrary_transformation example demonstrates a solution that uses thrust::zip_iterator and thrust::for_each.


# Fold (Reductions)
```cpp

thrust::device_vector<int> vec(5,0);

const int k = 1;

// Sum 
// sum = sum(vec)
// All equivelant forms
int sum = thrust::reduce(vec.begin(), vec.end(), (int) 0, thrust::plus<int>());
int sum = thrust::reduce(vec.begin(), vec.end(), (int) 0);
int sum = thrust::reduce(vec.begin(), vec.end())

// Count function
// result = count(vec, k)
int result = thrust::count(vec.begin(), vec.end(), 1);


```

## Other reductions 

Other reduction operations include thrust::`count_if`, thrust::`min_element`, thrust::`max_element`, thrust::`is_sorted`, thrust::`inner_product`, and several others. Refer to the documentation for a complete listing.

## Taking the norm via `transform_reduce` using unary & binary operator 

**Key:** Applies the `unary` transformation on all elements before `thrust::reduce`:

`reduce binary [unary(x_1),...,unary(x_n)]`


```cpp
#include <thrust/transform_reduce.h>
#include <thrust/functional.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <cmath>

// square<T> computes the square of a number f(x) -> x*x
template <typename T>
struct square
{
    __host__ __device__
        T operator()(const T& x) const {
            return x * x;
        }
};

int main(void)
{
    // initialize host array
    float x[4] = {1.0, 2.0, 3.0, 4.0};

    // transfer to device
    thrust::device_vector<float> d_x(x, x + 4);

    // setup arguments
    square<float>        unary_op;
    thrust::plus<float> binary_op;
    float init = 0;

    // compute norm
    // transform_reduce :: Iterator -> Iterator -> (T -> T2) -> ((T2, T2) -> T3) -> T3
    // Or in other forms:
    // fold binary init (map unary x)
    float norm = std::sqrt( thrust::transform_reduce(d_x.begin(), d_x.end(), unary_op, init, binary_op) );

    std::cout << norm << std::endl;

    return 0;
}
```

