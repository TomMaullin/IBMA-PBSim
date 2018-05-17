#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=04:00:00
#$ -l h_vmem=8G
#$ -t 1:38
#$ -o log/$JOB_NAME.o$JOB_ID.$TASK_ID
#$ -e log/$JOB_NAME.e$JOB_ID.$TASK_ID
#$ -cwd

. /etc/profile

module add matlab

matlab -nodisplay -r "addpath('/storage/u1406435/code/spm12');addpath(genpath(pwd));RunSim($id);quit"
