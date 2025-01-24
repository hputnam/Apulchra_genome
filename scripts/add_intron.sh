#!/bin/bash 
#SBATCH -t 96:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=30GB
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=trinity.conn@uri.edu
#SBATCH --account=putnamlab
#SBATCH -o addin.out
#SBATCH -e addin.error

source ~/.bashrc

conda activate genometools

cd /data/putnamlab/tconn/annotate_results

#run jellyfish kmer count 

gt gff3 --addintrons yes Acropora_pulchra_fixed.gff3 > Acropora_pulchra_introns.gff3
