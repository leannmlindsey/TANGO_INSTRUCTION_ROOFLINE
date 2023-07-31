#!/bin/bash
set -x

# print usage
#function usage() {
#    echo "USAGE: sudo collect_metrics_extended.sh"
#    echo "DEPENDENCY: GiCOPS setup and ready to run"
#    echo "BEFORE RUNNING: Set GiCOPS_HOME path on line# 22, and params (except dM) on line# 28"
#}

# make sure of sudo acess
#if [ "$(id -u)" != "0" ] ; then
#   echo "ERROR: Run this script as sudo"
#   usage
#   exit 0
#fi

# list of kernels to profile
kernel=(sequence_dna_kernel_traceback)

# path to app's home
#apphome=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/LEANN_TEST/TESTING_ADEPT_8BIT/ADEPT-T

# ADEPT GPU-BSW
#apphome=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/LEANN_TEST/ADEPT_DEVELOPMENT/DEVELOPMENT/GPU-BSW

# ADEPT 4 bit
#apphome=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/LEANN_TEST/ADEPT_CURRENT/CLEAN/ADEPT-T

# ADEPT 8 bit vertical 
#apphome=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/LEANN_TEST/ADEPT_CURRENT/8BIT_VERTICAL/ADEPT-T

# ADEPT 8 bit vertical if 
apphome=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/LEANN_TEST/ADEPT_CURRENT/8BIT_VERTICAL_IF/ADEPT-T

# path to app and arguments
app=${apphome}/build/program_gpu

# arguments
arg1=dna
arg2=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/DATA/large_datasets/DNA/MILLION/dna_ref_1M.fasta
arg3=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/DATA/large_datasets/DNA/MILLION/dna_read_1M.fasta
arg4=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/BENCHMARKING_RESULTS/ROOFLINE/out

#outputfolder=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/BENCHMARKING_RESULTS/ROOFLINE/ADEPT
#outputfolder=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/BENCHMARKING_RESULTS/ROOFLINE/ADEPT_4bit
#outputfolder=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/BENCHMARKING_RESULTS/ROOFLINE/ADEPT_8bit
outputfolder=/uufs/chpc.utah.edu/common/home/u1323098/sundar-group-space2/ADEPT/BENCHMARKING_RESULTS/ROOFLINE/ADEPT_8bit_if

mkdir $outputfolder

# prepare the app
#pushd ${apphome}/build
#cmake .. -DUSE_GPU=ON -DUSE_MPI=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=${apphome}/install-ncu
#make clean
#make install -j 12
#popd

# remove previous output directory if exists
rm -rf ${outputfolder}

# make a new output directory
mkdir -p ${outputfolder}


# timing for kernels
ncu --print-summary per-gpu ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/clean.log

# collect all metrics for all kernels individually
for k in ${kernel[@]}
do
    echo "Profiling kernel: ${k}"

    # events not available
    ncu -k "${k}" --csv --metrics smsp__thread_inst_executed.sum,smsp__inst_executed.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_event.log

    ncu -k "${k}" --csv --metrics smsp__inst_executed.avg.per_cycle_active,smsp__sass_thread_inst_executed_op_integer_pred_on.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_set1.log
    ncu -k "${k}" --csv --metrics smsp__inst_executed_op_global_ld.sum,smsp__inst_executed_op_global_st.sum,smsp__inst_executed_op_local_ld.sum,smsp__inst_executed_op_local_st.sum,dram__sectors_read.sum,dram__sectors_write.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_inst.log
    ncu -k "${k}" --csv --metrics l1tex__data_pipe_lsu_wavefronts_mem_shared_op_ld.sum,l1tex__data_pipe_lsu_wavefronts_mem_shared_op_st.sum,smsp__inst_executed_op_shared_ld_pred_on_any.sum,smsp__inst_executed_op_shared_ld_pred_off_all.sum,smsp__inst_executed_op_shared_st_pred_on_any.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_inst_shared.log
    ncu -k "${k}" --csv --metrics smsp__sass_thread_inst_executed_op_memory_pred_on.sum,smsp__inst_executed_pipe_lsu.avg.pct_of_peak_sustained_active ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_ld.log
    # ncu -k "${k}" --csv --metrics smsp__sass_thread_inst_executed_op_conversion_pred_on.sum,smsp__sass_thread_inst_executed_op_control_pred_on.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_set2.log
    # ncu -k "${k}" --csv --metrics smsp__sass_thread_inst_executed_op_fp64_pred_on.sum,smsp__sass_thread_inst_executed_op_fp32_pred_on.sum,smsp__sass_thread_inst_executed_op_fp16_pred_on.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_set3.log
    # ncu -k "${k}" --csv --metrics smsp__sass_thread_inst_executed_op_dadd_pred_on.sum,smsp__sass_thread_inst_executed_op_dmul_pred_on.sum,smsp__sass_thread_inst_executed_op_fadd_pred_on.sum,smsp__sass_thread_inst_executed_op_fmul_pred_on.sum,smsp__sass_thread_inst_executed_op_ffma_pred_on.sum,smsp__sass_thread_inst_executed_op_hadd_pred_on.sum,smsp__sass_thread_inst_executed_op_hmul_pred_on.sum,smsp__sass_thread_inst_executed_op_hfma_pred_on.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_set4.log
    # ncu -k "${k}" --csv --metrics smsp__sass_thread_inst_executed_op_dfma_pred_on.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_flop_count_dp_fma.log
    ncu -k "${k}" --csv --metrics l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum,l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_local.log
    ncu -k "${k}" --csv --metrics l1tex__t_sectors_pipe_lsu_mem_global_op_st.sum,l1tex__t_sectors_pipe_lsu_mem_global_op_ld.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_global.log
    # ncu -k "${k}" --csv --metrics l1tex__average_t_sectors_per_request_pipe_lsu_mem_local_op_ld.ratio,l1tex__average_t_sectors_per_request_pipe_lsu_mem_local_op_st.ratio ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_local_req.log
    # ncu -k "${k}" --csv --metrics l1tex__average_t_sectors_per_request_pipe_lsu_mem_global_op_ld.ratio,l1tex__average_t_sectors_per_request_pipe_lsu_mem_global_op_st.ratio ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_gld_req.log
    # ncu -k "${k}" --csv --metrics lts__t_sectors_op_write.sum,lts__t_sectors_op_atom.sum,lts__t_sectors_op_red.sum,lts__t_sectors_op_read.sum,lts__t_sectors_op_atom.sum,lts__t_sectors_op_red.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_l2.log
    # ncu -k "${k}" --csv --metrics lts__t_sectors_aperture_sysmem_op_read.sum,lts__t_sectors_aperture_sysmem_op_write.sum ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_sysmem.log
    # ncu -k "${k}" --csv --metrics smsp__sass_average_branch_targets_threads_uniform.pct ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_branch_efficiency.log
    # ncu -k "${k}" --csv --metrics smsp__thread_inst_executed_per_inst_executed.pct,smsp__thread_inst_executed_per_inst_executed.ratio ${app} ${arg1} ${arg2} ${arg3} ${arg4} |&  tee ${outputfolder}/${k}_warp_execu_eff.log

done

