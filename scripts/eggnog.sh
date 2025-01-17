#!/bin/bash 
#SBATCH -t 96:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=250GB 
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=trinity.conn@uri.edu
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out 
#SBATCH -e slurm-%j.error 

source ~/.bashrc 

conda activate annotate 

mkdir /data/putnamlab/tconn/eggnog

cd /data/putnamlab/tconn/eggnog

emapper.py -i /data/putnamlab/tconn/interpro/input/apul.fa -o apul_eggnog
