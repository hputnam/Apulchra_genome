#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=300GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc 

conda activate annotate


funannotate annotate -i /data/putnamlab/tconn/ --iprscan /data/putnamlab/tconn/interpro/output/apul.fa.xml --eggnog /data/putnamlab/tconn/eggnog/apul_eggnog.emapper.annotations --busco_db metazoa  --cpus 10  

