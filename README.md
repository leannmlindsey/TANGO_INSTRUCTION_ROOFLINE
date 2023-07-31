# Instruction Roofline for Adept

This repository contains the essential scripts of profiling, building, and visualizing the Instruction Roofline Model for the Adept kernels on NVIDIA GPUs.

Note: This repository was adapted from https://github.com/mhaseeb123/Instruction_roofline_scripts.git

## Usage Instructions


1. Allocate a GPU node using the following command:     

```
salloc --account=soc-gpu-np --partition=soc-gpu-np --nodes=1 --ntasks=16 --gres=gpu:a100:1 --mem=0
```

2. Run the `collect_metric_extended_4bit.sh` and `collect_metric_extended_8bit.sh` script as:     

```bash
srun ./collect_metric_extended_4bit.sh <path to TANGO build dir> <path to 4_bit output dir> <input file ref> <input file query> <result file>
srun ./collect_metric_extended_8bit.sh <path to TANGO build dir> <path to 8_bit output dir> <input file ref> <input file query> <result file>
```

3. After profiler completion, run the `merge.sh` to obtain the `sequence_dna_kernel_traceback.csv` files using:     

```bash
srun ./merge.sh <path to 4_bit output dir>
srun ./merge.sh <path to 8_bit output dir>
```

4. Get the time of the kernel by running Nvidia Nsight Compute

   
5. Finally, run the `two_kernel_roofline.py` script with proper parameters to build and visualize the roofline for both kernels as:     

```bash

# run adept_rooflines.py with correct parameters
srun python ./two_kernel_rooflines.py -a <path to output dir>/sequence_dna_kernel_traceback.csv --at 5.35 -b <path to output dir>/sequence_dna_kernel_traceback.csv --bt 4.63

# The values for -at and -bt were obtained from running Nvidia Nsight Compute with the following command:

cd <path to TANGO build dir>
srun -N 1 --gpus-per-node=1 --ntasks=1 ncu -o ncu-metrics.txt -k sequence_dna_kernel_traceback --mode=launch-and-attach --set full ./program_gpu dna <input file ref> <input file query> ./out-file
```


## References
1. Ding, Nan, and Samuel Williams. "An instruction roofline model for gpus." 2019 IEEE/ACM Performance Modeling, Benchmarking and Simulation of High Performance Computer Systems (PMBS). IEEE, 2019    
