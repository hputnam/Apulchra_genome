#!/bin/bash 
#SBATCH -t 96:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=30GB
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=trinity.conn@uri.edu
#SBATCH --account=putnamlab
#SBATCH -o jf.out
#SBATCH -e jf.error

source ~/.bashrc

conda activate jellyfish

cd /data/putnamlab/tconn/repeats

#run jellyfish kmer count 

jellyfish count -C -m 31 -s 1000000000 -t 10 /data/putnamlab/jillashey/Apul_Genome/assembly/data/m84100_240128_024355_s2.hifi_reads.bc1029.fastq.fastq -o reads.jf
