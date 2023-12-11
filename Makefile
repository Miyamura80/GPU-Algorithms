# Makefile for compiling CUDA Thrust code

# Compiler
NVCC = nvcc

# Compiler flags
NVCCFLAGS = -O2 -gencode arch=compute_86,code=sm_86

# Name of the executable
EXECUTABLE = thrust_sort

# Source files
SOURCES = demo2.cu

# Default make target
all: $(EXECUTABLE)

# Rule to link the object files and create the executable
$(EXECUTABLE): $(SOURCES)
	$(NVCC) $(NVCCFLAGS) $^ -o build/$@

# Rule to run the program
run: all
	./build/$(EXECUTABLE)

# Rule to clean the directory
clean:
	rm -f build/$(EXECUTABLE)

# Phony targets
.PHONY: all run clean
