#!/bin/bash 
#SBATCH -t 96:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=trinity.conn@uri.edu
#SBATCH --account=putnamlab
#SBATCH -o busco.out
#SBATCH -e busco.error

source ~/.bashrc

conda activate busco

cd /data/putnamlab/tconn/blobtools


#BUSCO on masked + annotated assembly 
sequence_file=/data/putnamlab/tconn/repeats/apul_softmasked/apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked
lineage=/data/putnamlab/shared/busco/downloads/lineages/metazoa_odb10

busco -i ${sequence_file} -m genome -l  ${lineage} -c 20 -o BUSCO_ApulAnnotGenome 

