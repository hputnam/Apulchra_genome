#!/bin/bash
#SBATCH -t 72:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=100GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fai$
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc 
conda activate repeatmasker 
cd /data/putnamlab/tconn/repeats

#plot repeat landscape  on aligned repeat

createRepeatLandscape.pl -div Apul.divsum -g 518000000 > /data/putnamlab/tconn/repeats/ApulRepeats.html  
