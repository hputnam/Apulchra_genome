#!/bin/bash
#SBATCH -t 72:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=50GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error


source ~/.bashrc
conda activate repeatmasker 

cd /data/putnamlab/tconn/repeats

RepeatModeler -database apulchra -engine ncbi -threads 20 -recoverDir /data/putnamlab/tconn/repeats/RM_79143.FriJul261435412024 -LTRStruct 
