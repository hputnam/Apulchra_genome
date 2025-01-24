#!/bin/bash
#SBATCH -t 120:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=100GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc
mamba activate annotate

#load the mysql container 
#ok while i figure out this mysql issue i'm going to start running it with sqlite 


#train the gene predictors using Danielle's RNA seq data 

funannotate train -i /data/putnamlab/tconn/repeats/apul_softmasked/apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked -o /data/putnamlab/tconn/ -l /data/putnamlab/tconn/rna_seq/*_R1* -r /data/putnamlab/tconn/rna_seq/*_R2* --memory 300G --no_trimmomatic --pasa_db sqlite  --max_intronlen 100000 --species 'Acropora pulchra'  --cpus 20 


