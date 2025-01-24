#!/bin/bash
#SBATCH -t 96:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=300GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc

conda activate annotate 

cd /data/putnamlab/tconn/scripts/gmes_linux_64/

funannotate predict \
-i /data/putnamlab/tconn/repeats/apul_softmasked/apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked \
-o /data/putnamlab/tconn/ \
-s "Acropora pulchra" \
--repeats2evm \
--organism other \
--max_intronlen 100000 \
--busco_db metazoa \
--GENEMARK_PATH /data/putnamlab/tconn/scripts/gmes_linux_64/ \
--cpus 20

