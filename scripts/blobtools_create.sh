#!/bin/bash 
#SBATCH -t 1:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=10GB
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=trinity.conn@uri.edu
#SBATCH --account=putnamlab
#SBATCH -o blobtools.out
#SBATCH -e blobtools.error

source ~/.bashrc

conda activate blobtools2 

cd /data/putnamlab/tconn/

blobtools create --fasta /data/putnamlab/tconn/repeats/apul_softmasked/apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked --taxid 140239 --taxdump /data/putnamlab/tconn/blobtools/taxdump /data/putnamlab/tconn/BTK/Datasets/Apul
