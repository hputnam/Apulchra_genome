#!/bin/bash
#SBATCH -t 72:00:00
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fai$
#SBATCH --mail-user=trinity.conn@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

source ~/.bashrc 
conda activate repeatmasker 
cd /data/putnamlab/tconn/repeats

#Make protein blastable database
makeblastdb -in GCF_000222465.1_Adig_1.1_protein.faa  -dbtype prot

#blast downloaded digitifera proteins against repeat peps lib

blastp -query GCF_000222465.1_Adig_1.1_protein.faa \
	-db /home/trinity.conn/.conda/envs/repeatmasker/pkgs/repeatmasker-4.1.5-pl5321hdfd78af_1/share/RepeatMasker/Libraries/RepeatPeps.lib \
	-evalue 1e-5 \
	-culling_limit 2 \
	-num_threads 20 \
	-max_target_seqs 5 \
	-outfmt '6 qseqid sseqid pident evalue bitscore staxids stitle' -out out.br

#remove predicted TEs from the digitifera transcripts using fastaqual_select

perl fastaqual_select.pl -f GCF_000222465.1_Adig_1.1_rna.fna -e <(awk '{print $1}' out.br | sort | uniq) > Adigtranscripts.no_rep.fa

#make BLAST database for transcripts 

makeblastdb -in Adigtranscripts.no_rep.fa -dbtype nucl

#blast repeatmodeler library to the no TE to find misidentified fragments 

blastn -task megablast -query consensi.fa.classified -db Adigtranscripts.no_rep.fa -outfmt '6 qseqid sseqid pident evalue bitscore' \
	-max_target_seqs 25 \
	-culling_limit 2 \
	-num_threads 20 \
	-evalue 1e-10 \
	-out repeatmodelerlib.note.megablast.out 

#filter out those misidentified fragments 

perl fastaqual_select.pl \
	-f consensi.fa.classified \
	-e <(awk '{print $1}' repeatmodelerlib.note.megablast.out | sort | uniq) \
	> consensi.fa.classified.filtered_for_gene.fa

#make consensus library for repeat masker 

perl /home/trinity.conn/.conda/envs/repeatmasker/pkgs/repeatmasker-4.1.5-pl5321hdfd78af_1/share/RepeatMasker/util/buildRMLibFromEMBL.pl /home/trinity.conn/.conda/envs/repeatmasker/pkgs/repeatmasker-4.1.5-pl5321hdfd78af_1/share/RepeatMasker/Libraries/RepeatMaskerLib.embl \ 
 >RepeatMaskerLib.fasta 

perl /home/trinity.conn/.conda/envs/repeatmasker/pkgs/repeatmasker-4.1.5-pl5321hdfd78af_1/share/RepeatMasker/util/queryRepeatDatabase.pl \
	- species "Acropora"
	> repeatmasker.Acropora.fa


cat repeatmasker.Acropora.fa consensi.fa.classified.filtered_for_gene.fa > Apul.repeatlib.fa


RepeatMasker \
	-lib Apul.repeatlib.fa \
	-engine ncbi \
	-parallel 20 \
	-gff -xsmall -s \
	-poly \
	-dir ./apul_softmasked \
	-a \
	apulchra apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa
