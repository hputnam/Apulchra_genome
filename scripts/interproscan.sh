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

cd /data/putnamlab/tconn/interpro

singularity exec --bind /data/putnamlab/tconn/interpro/interproscan-5.71-102.0/data:/opt/interproscan/data --bind /data/putnamlab/tconn/interpro/input:/input --bind /data/putnamlab/tconn/interpro/temp:/temp --bind /data/putnamlab/tconn/interpro/output:/output  interproscan_latest.sif /opt/interproscan/interproscan.sh \
	--input /input/apul.fa \
	--disable-precalc \
	--output-dir /output \
	--tempdir /temp \
	--cpu 8 
