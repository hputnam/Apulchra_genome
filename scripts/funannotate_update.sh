#!/bin/bash
#SBATCH -t 240:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=300GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc 

conda activate annotate


funannotate update -i /data/putnamlab/tconn/ --cpus 20 --max_intronlen 100000  --memory 300GB

