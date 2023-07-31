# Instruction Roofline for Adept

This repository contains the essential scripts of profiling, building, and visualizing the Instruction Roofline Model for the Adept kernels on NVIDIA GPUs.

## Usage Instructions


1. Allocate a GPU node (preferably with `--exclusive`) using the following command:     

```bash
salloc -G 1 -C gpu -t 00:30:00 --exclusive
```

3. Run the `collect_metric_extended.sh` script as:     

```bash
srun ./collect_metric_extended.sh
```

4. After profiler completion, run the `merge.sh` to obtain the `Adept_F.csv` and `Adept_R.csv` files using:     

```bash
srun ./merge.sh ./output_extended
```

5. Finally, run the `adept_roofline.py` script with proper parameters to build and visualize the roofline for both Adept kernels as:     

```bash
# get help on input parameters
python ./adept_rooflines.py --help

# run adept_rooflines.py with correct parameters
srun python ./adept_rooflines.py -f ./output_extended/Adept_F.csv --ftime 193.94 -r ./output_extended/Adept_R.csv --rtime 61.853 && ps2pdf ./adept_glob.eps && ps2pdf ./adept_shm.eps
```

## References
1. Ding, Nan, and Samuel Williams. "An instruction roofline model for gpus." 2019 IEEE/ACM Performance Modeling, Benchmarking and Simulation of High Performance Computer Systems (PMBS). IEEE, 2019    
