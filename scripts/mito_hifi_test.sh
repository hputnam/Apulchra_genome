#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

echo "Starting mito assembly with Amillepora refs" $(date)

source ~/.bashrc
conda activate mitohifi

cd /data/putnamlab/tconn/mito

singularity exec --home /data/putnamlab/tconn/mito docker://ghcr.io/marcelauliano/mitohifi:master mitohifi.py -r m84100_240128_024355_s2.hifi_reads.bc1029.fasta \
 -f NC_022830.1.fasta -g NC_022830.1.gb \
 -t 8 \
 -o 5 #invert code 

echo "Mito assembly complete!" $(date)
