# Acropora pulchra genome assembly 

Written on 10/24/25 by J. Ashey. See assembly notes and troubleshooting post [here](https://github.com/JillAshey/JillAshey_Putnam_Lab_Notebook/blob/master/_posts/2024-02-06-Apulchra-Genome-Assembly.md). 

This markdown provides a workflow for genome assembly from PacBio Hifi reads. More information on this project can be found on the [github](https://github.com/hputnam/Apulchra_genome/tree/main) and [OSF repository](https://osf.io/y8963/). 

I used genome assembly methods from [Young et al. 2024](https://link.springer.com/article/10.1186/s12864-024-10092-w?utm_source=rct_congratemailt&utm_medium=email&utm_campaign=oa_20240229&utm_content=10.1186/s12864-024-10092-w#Sec12334225451) (see github [here](https://github.com/benyoung93/orbicella_faveolata_pacbio_genome_transcriptome/blob/main)). This analysis was done on URI's old HPC, Andromeda. 

## Table of Contents

* [Samples](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#samples)
* [PacBio HiFi sequencing](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#pacbio-hifi-sequencing)
* [Genome assembly](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#genome-assembly)
	* [bam2fastq](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#bam2fastq)
	* [seqtk](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#seqtk)
	* [Contaminant removal](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#contaminant-removal)
	* [Hifiasm](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#hifiasm)
	* [Busco & Quast on Hifiasm assembly](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#busco--quast-on-hifiasm-assembly)
	* [ntlinks](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#ntlinks)
	* [Busco & Quast on Hifiasm + ntlinks assembly](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/Apul_genome_assembly.md#busco--quast-on-hifiasm--ntlinks-assembly)

## Samples

Sperm and tissue from adult Acropora pulchra colonies were collected from Moorea, French Polynesia in 2022 and preserved in DNA/RNA shield. 

## PacBio HiFi sequencing 

The PacBio sequencing for the Apul genome were done with HiFi sequencing that are produced with circular consensus sequencing on PacoBio long read systems. Here's how HiFi reads are generated from the [PacBio website](https://www.pacb.com/technology/hifi-sequencing/):

![](https://raw.githubusercontent.com/JillAshey/JillAshey_Putnam_Lab_Notebook/master/images/hifi_read_generation.png)

## Genome assembly  

The PacBio files that will be used for assembly are located here on Andromeda: `/data/putnamlab/KITT/hputnam/20240129_Apulchra_Genome_LongRead`. The files in the folder that we will use are:

```
m84100_240128_024355_s2.hifi_reads.bc1029.bam
m84100_240128_024355_s2.hifi_reads.bc1029.bam.pbi
```

The bam file contains all of the read information in computer language and the pbi file is an index file of the bam. 

### bam2fastq

Convert the bam file to fastq file for analysis using `bam2fastq`. This is a part of the PacBio BAM toolkit package `pbtk`.

Since this was not installed on Andromeda, I created a conda environment and installed the package. 

```
module load Miniconda3/4.9.2
conda create --prefix /data/putnamlab/conda/pbtk
conda activate /data/putnamlab/conda/pbtk
conda install -c bioconda pbtk
```

In my scripts folder: `nano bam2fastq.sh`

```
#!/bin/bash -i
#SBATCH -t 500:00:00
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

conda activate /data/putnamlab/conda/pbtk

echo "Convert PacBio bam file to fastq file" $(date)

bam2fastq -o /data/putnamlab/jillashey/Apul_Genome/assembly/data/m84100_240128_024355_s2.hifi_reads.bc1029.fastq /data/putnamlab/KITT/hputnam/20240129_Apulchra_Genome_LongRead/m84100_240128_024355_s2.hifi_reads.bc1029.bam

echo "Bam to fastq complete!" $(date)

conda deactivate
```

Check the fastq file that was produced

```
less m84100_240128_024355_s2.hifi_reads.bc1029.fastq.fastq.gz 

@m84100_240128_024355_s2/261887593/ccs
TATAAGTTTTACAGCTGCCTTTTGCTCAGCAAAGAAAGCAGCATTGTTATTGAACAGAAAAAGCCTTTTGGTGATATAAAGGTTTCTAAGGGACCAAAGTTTGATCTAGTATGCTAAGTGTGGTGGGTTAAAACTTTGTTTCACCTTTTTCCCGTGATGTTACAAAATTGGTGCAAATATTCATGACGTCGTACTCAAGTCTGACACTAAGAGCATGCAATTACTTAAACAAACAAGCCATACACCAATAAACTGAAGCTCTGTCAACTAGAAAACCTTTGAGTATTTTCATTGTAAAGTACAAGTGGTATATTGTCACTTGCTTTTACAACTTGAAGAACTCACAGTTAAGTTACTAGATTCACCATAGTGCTTGGCAATGAAGAAGCCAAATCACATAAAGTCGGAGCATGTGGTGTTTAGACCTAATCAAACAAGAACACAATATTTAGTACCTGCATCCTGTCTAAGGAGGAAATTTTAAGCTGCTTTCTTTTAAATTTTTTTTATTAGCATTTCAATGGTTGAGGTCGATTATAGGTGCTAGGCTTTAATTCCGTACTATGAAAGAAGAAAGGTCGTTGTTATTAACCATGTCAAACAGAGAAACACATGGTAAAAAATTGACTTCCTTTTCCTCTCGTTGCCACTTAAGCTTAATGATGGTGTTTGACCTGAAAGATGTTACAATTGTTTTAGATGAAAAGACTGTTCTGCGTAAAACAGTGAAGCCTCCCAACTTATTTTGTTATGTGGATTTTGTTGTCTTGTTAGTAACATGTATTGGACTATCTTTTGTGAGTACATAGCTTTTTTTCCATCAACTGACTATATACGTGGTGTAATTTGAGATCATGCCTCCAAGTGTTAGTCTTTTGTTTGGGGCTAACTCGTAAAAGACAAAGGGAGGGGGGTTGTCTAATTCCTAAGCAAAGCATTAAGTTTAACACAGGAAATTGTTTGCGTTGATATTGCTATCCTTTCAGCCCCAAACAAAAAATTTAATGGTTATTTTATTTTACATCTATTGTAAATATATTTTAACATTAATTTTTATTATTGCACTGTAAATACTTGTACTAATGTTCTGTTTGAATTAATTTTGATTCATTCCTTGTGCTTACAACAACAGGGATACAAAACCGATATGTATAATAATACTATTAGAGATGCTTATTTGCATTTTTAGCCCATACCATGAGTTTTAATAACGCCAGGCCATTGGAGATTTTATGGAGTGAGGATTCATTGTACAAACATGGTTGATTTAATATTAAAGTTGTATCCAAATAATTAATATCTGCTGTGATCAGTGAAAGATTGACCTTTCAGTTGTTTGGTTGCACCTTCATCTTATTGGAAACAACTGAATGGAGCATCTTTCCAGTTTAAAAATGTACCACTGCCCACTTTCATGAAGTTATGCCACATATTAATAATGACTATTAATTGTTGAAAACCCTTCTTCCAAAATGTTTCCATTTATTTGTAATAGCATATGTGGTCCATCAGAACAATAATTTAAATCATTACTATTAATAATTTTCCAATAACTGACTTTCAAACCTAGCCAACAAGCATAAGTCAGTAAGCCACAGAGTCCAGAGATACACTTACACTTTACTTTTCACTTCTGAAACATTTTATAATCTCAGTATGAGCATAGAACTTTTCAGTTGGGCAGCATGGAATAGAACCTTTGGACCCCTCTGTGAATATCAAAAATAGGCAACCACTTCCAGCATACACTCTAGCCTCCTTCATAAAGCAAGCCTTAGTGTTTTAGCTTCTACTAGTTAGATTCATTTTAAAAGAAGTTCAGTATACTTAATCTTATAGAAGCTGATTGTGATATAATTGCATAGGTGGATCTCAGAAAAGTGAGATGTAGCTGTCAAATTAAAAGAAGTCCTTTCCAAGCGTAGCTTCTGATAAACAATGCATTTTAGTTAACATTGGATTATGGTTTCAAAGGACTTGTAAAGCTAAATTCAAGTTTTTATGACAACTTGAAAGCCTTTGCCACAGTCTCCGCTGATTTAAGACTTCCATCAAAGTTAGAGTGGTGTGAATGCATCTCCACATGCAATTAATAAAGGTGAGGCAGACAACACAAAACACCCTGGTGCACCATCAACTCCACGGATCACTTGACTGTAACGCCATCTTATACAGCGACTGCCAATTGGAACTGGAAGATCAGGAATGATCTCTTTCACATGGGAAATGAGCATGGTCTTGATAATGCTTTCATCAGTATCCCAATGTTGAAGACAGAAGGACTTTGTTGAATGTACTAAAAGAGAGGGACCAACATCCACTGGATCTGGAACAGAATGCCAAAGCATATGCAAAATGTTATCATGTATAATAAAGAAAAAACCAAACTCATGAAGTTCAACGGTCACAGGCTTTGGTAAAAGACTGTACATGGTAAAGTACTCAGGGTGAAAGTTTGTATCCAAAAAACGAAAAGCTAACCTGTACCACATCTCTTCCGAGAGTCCACTGACACAAATGCAATATTAGGATTGCCAGTCGCATATTTACACGTCCATGGCACATTGATAACTGCTTCATGATCAAAAAAGTATCCTACTGCAAACCGTGATGAATATTCCACATTTTGTAAGGATTTGATTTCATTTTGTAAGAATGCTTGAATTGAACCTTGTAGCTGAAGAAGTTGTGGTACTGGAATAGTTACTATGACTGA

zgrep -c "@m84100" m84100_240128_024355_s2.hifi_reads.bc1029.fastq.fastq.gz 
5898386
```

5.8 million HiFi reads were generated. 

### seqtk

Convert the fastq to a fasta file with [seqtk](https://github.com/lh3/seqtk). `nano seqtk.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load seqtk/1.3-GCC-9.3.0

echo "Convert PacBio fastq file to fasta file" $(date)

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

seqtk seq -a m84100_240128_024355_s2.hifi_reads.bc1029.fastq.fastq > m84100_240128_024355_s2.hifi_reads.bc1029.fasta

echo "Fastq to fasta complete! Summarize read lengths" $(date)

awk '/^>/{printf("%s\t",substr($0,2));next;} {print length}' m84100_240128_024355_s2.hifi_reads.bc1029.fasta > rr_read_lengths.txt

echo "Read length summary complete" $(date)
```

Load the `rr_read_lengths.txt` into R to quantify length for each read. 

```{r}
library(tidyverse)

read.table(file = "~/Desktop/PutnamLab/Apulchra_genome/rr_read_lengths.txt", 
           header = F) %>% 
  dplyr::rename("hifi_read_name" = 1, 
         "length" = 2) -> hifi_read_length
nrow(hifi_read_length) # 5,898,386 total reads
mean(hifi_read_length$length) # mean length of reads is 13,424.64
sum(hifi_read_length$length) #length sum 79,183,709,778. Will need this for the NCBI submission
```

Mean length of reads is 13,242.64 bp. There are 79,183,709,778 total bp. In R, make histogram of read bins from raw hifi data.

```{r}
rr_length_histo <- ggplot(data = hifi_read_length, 
       aes(x = length, fill = "blue")) +
  geom_histogram(binwidth = 2000) + 
  labs(x = "Raw Read Length", y = "Count", title = "Histogram of Raw HiFi Read Lengths") + 
  scale_fill_manual(values = c("blue")) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)); rr_length_histo
```

![](https://raw.githubusercontent.com/hputnam/Apulchra_genome/main/output/rr_length_histogram.png)

### Contaminant removal 

Screen raw reads for potential contaminants and remove any reads that have identified contaminants. For the Apul genome, I screened for common eukaryote contaminant sequences (`ftp.ncbi.nlm.nih. gov/pub/kitts/contam_in_euks.fa.gz`), viral (`ref_viruses_rep_genomes`) and prokaryote (`ref_prok_rep_genomes`) representative genome sets, Apul symbiont genomes, and the Apul mitochondrial genome using BLAST. 

Blast raw reads against eukaryotic contaminant sequences. `nano blastn_contam_euk.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load BLAST+/2.13.0-gompi-2022a

echo "BLASTing hifi fasta against eukaryote contaminant sequences" $(date)

cd /data/putnamlab/jillashey/Apul_Genome/assembly/dbs
wget ftp.ncbi.nlm.nih. gov/pub/kitts/contam_in_euks.fa.gz
gunzip contam_in_euks.fa.gz

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -subject /data/putnamlab/jillashey/Apul_Genome/dbs/contam_in_euks.fa -task megablast -outfmt 6 -evalue 4 -perc_identity 90 -num_threads 15 -out contaminant_hits_euks_rr.txt

echo "BLAST complete, remove contaminant seqs from hifi fasta" $(date)

awk '{ if( ($4 >= 50 && $4 <= 99 && $3 >=98 ) ||
         ($4 >= 100 && $4 <= 199 && $3 >= 94 ) ||
         ($4 >= 200 && $3 >= 90) )  {print $0}
    }' contaminant_hits_euks_rr.txt > contaminants_pass_filter_euks_rr.txt

echo "Contaminant seqs removed from hifi fasta" $(date)
```

The viral and prokaryote genome sets are very large, so they will take a while to run. For reference, the euk blast script took 2.5 hours to run, while the prok blast script took 5 days. 

`blastn_contam_prok.sh`

```
#!/bin/bash 
#SBATCH -t 30-00:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load BLAST+/2.13.0-gompi-2022a

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Blasting hifi reads against prokaryote genomes to look for contaminants" $(date)

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -db ref_prok_rep_genomes -outfmt 6 -evalue 1e-4 -perc_identity 90 -out prok_contaminant_hits_rr.txt

echo "Blast complete!" $(date)
```

`blastn_contam_viral.sh`

```
#!/bin/bash 
#SBATCH -t 30-00:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load BLAST+/2.13.0-gompi-2022a

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Blasting hifi reads against viral genomes to look for contaminants" $(date)

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -db ref_viruses_rep_genomes -outfmt 6 -evalue 1e-4 -perc_identity 90 -out viral_contaminant_hits_rr.txt

echo "Blast complete!" $(date)
```

Concatenate the prok and viral blast results and remove any hits whose bit score was <1000. 

```
cd /Users/jillashey/Desktop/PutnamLab/Apulchra_genome
cat viral_contaminant_hits_rr.txt prok_contaminant_hits_rr.txt > all_contaminant_hits_rr.txt
awk '$12 > 1000 {print $0}' all_contaminant_hits_rr.txt > contaminant_hits_pv_passfilter_rr.txt
```

From the E5 physiology manuscript, we know that our Apul samples are mostly dominated by A1 and D1 symbionts. Download the [A1 genome](http://smic.reefgenomics.org/download/Smic.genome.scaffold.final.fa.gz) and the [D1 genome](https://marinegenomics.oist.jp/symbd/viewer/download?project_id=102) to blast against the raw reads. `nano blastn_contam_sym.sh`

```
#!/bin/bash 
#SBATCH -t 30-00:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load BLAST+/2.13.0-gompi-2022a

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Build A1 seq db" $(date)

makeblastdb -in /data/putnamlab/jillashey/Apul_Genome/dbs/Smic.genome.scaffold.final.fa -dbtype nucl -out /data/putnamlab/jillashey/Apul_Genome/dbs/A1_db

echo "Build D1 seq db" $(date)

makeblastdb -in /data/putnamlab/jillashey/Apul_Genome/dbs/102_symbd_genome_scaffold.fa -dbtype nucl -out /data/putnamlab/jillashey/Apul_Genome/dbs/D1_db

echo "Blasting hifi reads against symbiont A1 genome to look for contaminants" $(date)

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -db /data/putnamlab/jillashey/Apul_Genome/dbs/A1_db -outfmt 6 -evalue 1e-4 -perc_identity 90 -out sym_A1_contaminant_hits_rr.txt

echo "A1 blast complete! Now blasting hifi reads against symbiont D1 genome to look for contaminants" $(date)

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -db /data/putnamlab/jillashey/Apul_Genome/dbs/D1_db -outfmt 6 -evalue 1e-4 -perc_identity 90 -out sym_D1_contaminant_hits_rr.txt

echo "D1 blast complete!"$(date)
```

Concatenate the sym blast results together and remove anything that has a bit score <1000. 

```
cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

cat sym_A1_contaminant_hits_rr.txt sym_D1_contaminant_hits_rr.txt > sym_contaminant_hits_rr.txt
awk '$12 > 1000 {print $0}' sym_contaminant_hits_rr.txt > contaminant_hits_sym_passfilter_rr.txt

wc -l contaminant_hits_sym_passfilter_rr.txt 
12 contaminant_hits_sym_passfilter_rr.txt
```

Blast the Apul mitochondrial genome (assembled by Trinity, see mitohifi script [here](https://github.com/hputnam/Apulchra_genome/blob/main/scripts/mito_hifi_test.sh)). `nano blastn_contam_mito.sh`

```
#!/bin/bash 
#SBATCH -t 24:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load BLAST+/2.13.0-gompi-2022a

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Build Apul mito genome db" $(date)

makeblastdb -in /data/putnamlab/tconn/mito/final_mitogenome.fasta -dbtype nucl -out /data/putnamlab/jillashey/Apul_Genome/dbs/mito_db

echo "Blasting hifi reads against mito genome to look for contaminants" $(date)

blastn -query m84100_240128_024355_s2.hifi_reads.bc1029.fasta -db /data/putnamlab/jillashey/Apul_Genome/dbs/mito_db -outfmt 6 -evalue 1e-4 -perc_identity 90 -out mito_contaminant_hits_rr.txt

echo "Mito blast complete!"$(date)
```

Remove all mitochondrial hits with a bit score <1000. 

```
awk '$12 > 1000 {print $0}' mito_contaminant_hits_rr.txt > contaminant_hits_mito_passfilter_rr.txt

wc -l contaminant_hits_mito_passfilter_rr.txt 
1921 contaminant_hits_mito_passfilter_rr.txt
```

Read in the blast text output files into R to look at the reads to remove. 

```{r}
## Euk hits 
read.table(file = "~/Desktop/PutnamLab/Apulchra_genome/contaminants_pass_filter_euks_rr.txt", 
           header = F) %>% 
  dplyr::rename("read_ID" = 1, 
         "subject_ID" = 2, 
         "percent_identity" = 3, 
         "align_length" = 4, 
         "mismatches" = 5, 
         "gap_open" = 6, 
         "query_start" = 7, 
         "query_end" = 8, 
         "subject_start" = 9, 
         "subject_end" = 10, 
         "e_value" = 11, 
         "bit_Score" = 12) %>%
       group_by(read_ID) %>%
  summarise(count = n()) -> euk_hit_for_removal      
         
## Mito hits 
read.table(file = "~/Desktop/PutnamLab/Apulchra_genome/contaminant_hits_mito_passfilter_rr.txt", 
           header = F) %>% 
  dplyr::rename("read_ID" = 1, 
         "subject_ID" = 2, 
         "percent_identity" = 3, 
         "align_length" = 4, 
         "mismatches" = 5, 
         "gap_open" = 6, 
         "query_start" = 7, 
         "query_end" = 8, 
         "subject_start" = 9, 
         "subject_end" = 10, 
         "e_value" = 11, 
         "bit_Score" = 12) %>%
    group_by(read_ID) %>%
  summarise(count = n()) -> mito_hit_for_removal
  
## Sym hits
read.table(file = "~/Desktop/PutnamLab/Apulchra_genome/contaminant_hits_sym_passfilter_rr.txt", 
           header = F) %>% 
  dplyr::rename("read_ID" = 1, 
         "subject_ID" = 2, 
         "percent_identity" = 3, 
         "align_length" = 4, 
         "mismatches" = 5, 
         "gap_open" = 6, 
         "query_start" = 7, 
         "query_end" = 8, 
         "subject_start" = 9, 
         "subject_end" = 10, 
         "e_value" = 11, 
         "bit_Score" = 12) %>%
    group_by(read_ID) %>%
  summarise(count = n()) -> sym_hit_for_removal

## Prok and viral hits
read.table(file = "~/Desktop/PutnamLab/Apulchra_genome/contaminant_hits_pv_passfilter_rr.txt", 
           header = F) %>% 
  dplyr::rename("read_ID" = 1, 
         "subject_ID" = 2, 
         "percent_identity" = 3, 
         "align_length" = 4, 
         "mismatches" = 5, 
         "gap_open" = 6, 
         "query_start" = 7, 
         "query_end" = 8, 
         "subject_start" = 9, 
         "subject_end" = 10, 
         "e_value" = 11, 
          "bit_Score" = 12) %>% 
   inner_join(hifi_read_length, 
              by = c("read_ID" = "hifi_read_name")) -> pv_hits

## making the percentage of each hits align length to the contigs
##so obviously if there is a blast result with 100% it means that whole contig is probably a contaminant
pv_hits %>% 
  mutate(percent_alignment = (align_length/length)*100) -> pv_hits

pv_hits %>%
  group_by(read_ID) %>% 
  summarise(count = n()) -> pv_hit_for_removal
length(unique(pv_hit_for_removal))
```

Using these results, I will remove the contaminants and then use the cleaned reads for assembly with hifiasm. 

Sum of contamination and proportion of contamination to raw reads 

```{r}
(nrow(summarised_alignments_raw_reads) + nrow(euk_hit_for_removal) + nrow(mito_hit_for_removal) + nrow(sym_hit_for_removal) + nrow(pv_hit_for_removal))
(nrow(summarised_alignments_raw_reads) + nrow(euk_hit_for_removal) + nrow(mito_hit_for_removal) + nrow(sym_hit_for_removal + nrow(pv_hit_for_removal)))/nrow(hifi_read_length) * 100
```

Sum of all contamination = 1922
This is only 0.03258519% of the raw reads, which is pretty amazing! 

Summarize the contam information 

```{r}
summarised_alignments_raw_reads %>% 
  dplyr::select(read_ID) %>% 
  rbind(euk_hit_for_removal %>% 
          dplyr::select(read_ID)) 
  rbind(mito_hit_for_removal %>% 
          dplyr::select(read_ID)) %>% 
  rbind(sym_hit_for_removal %>% 
          dplyr::select(read_ID)) %>% 
  rbind(pv_hit_for_removal %>% 
          dplyr::select(read_ID)) -> all_contam_removal

hifi_read_length %>% 
  dplyr::filter(!hifi_read_name %in% all_contam_removal$read_ID) -> all_contam_rem_good_hifi_read_list
```

`all_contam_rem_good_hifi_read_list` is the df of all contigs that passed contamination filtering. 

Mean and sum calculation for cleaned raw reads 

```{r}
mean(all_contam_rem_good_hifi_read_list$length)
sum(all_contam_rem_good_hifi_read_list$length)

sum(hifi_read_length$length)
```

After contam removal, 5896464 reads remain, with a mean read length of 13426 bp and total read length of 79168047656. 

Calculating rough sequencing depth for genome

```{r}
hifi_read_length %>% 
  dplyr::filter(hifi_read_name %in% all_contam_rem_good_hifi_read_list$hifi_read_name) -> filt_raw_Reads
(sum(filt_raw_Reads$length)/79183709778)*((79168047656/sum(filt_raw_Reads$length))*100)
```

We have roughly 100x coverage! This is similar to Young et al. 2024 Orbicella results as well. 

Write a table for filtering reads on Andromeda
```{r}
write.table(all_contam_rem_good_hifi_read_list,
            file = "~/Desktop/PutnamLab/Apulchra_genome/all_contam_rem_good_hifi_read_list.txt",
            row.names = F,
            col.names = F,
            quote = F)
```

Copy this table to Andromeda to select the 'good' reads. Subset the raw hifi fasta file to remove the contaminant sequences using the [seqtk subseq](https://github.com/lh3/seqtk) command. `nano subseq.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load seqtk/1.3-GCC-9.3.0

echo "Subsetting hifi reads that passed contamination filtering" $(date)

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

# Select the specific reads to subset 
awk '{$2=""; print $0}' all_contam_rem_good_hifi_read_list.txt > output_file.txt

seqtk subseq m84100_240128_024355_s2.hifi_reads.bc1029.fasta output_file.txt > hifi_rr_allcontam_rem.fasta

echo "Subsetting complete!" $(date)
```

### Hifiasm

[Hifiasm](https://hifiasm.readthedocs.io/en/latest/index.html), a fast haplotype-resolved de novo assembler designed for PacBio HiFi reads, was the assembly tool used for this genome. According to [Hifiasm github](https://github.com/chhylp123/hifiasm), here are some good reasons to use Hifiasm:

- Hifiasm delivers high-quality telomere-to-telomere assemblies. It tends to generate longer contigs and resolve more segmental duplications than other assemblers.
- Hifiasm can purge duplications between haplotigs without relying on third-party tools such as purge_dups. Hifiasm does not need polishing tools like pilon or racon, either. This simplifies the assembly pipeline and saves running time.
- Hifiasm is fast. It can assemble a human genome in half a day and assemble a ~30Gb redwood genome in three days. No genome is too large for hifiasm.
- Hifiasm is trivial to install and easy to use. It does not required Python, R or C++11 compilers, and can be compiled into a single executable. The default setting works well with a variety of genomes.

Since this tool is not on Andromeda, create a conda environment and install the package. 

```
cd /data/putnamlab/conda
mkdir hifiasm
cd hifiasm

module load Miniconda3/4.9.2
conda create --prefix /data/putnamlab/conda/hifiasm
conda activate /data/putnamlab/conda/hifiasm
conda install -c bioconda hifiasm
```

I ran a couple of different iterations of hifiasm changing the -s option, which sets a similary threshold for duplicate haplotigs that should be purged; the default is 0.55. The iterations that I ran (0.3, 0.55, and 0.8) all worked well to resolve haplotypes with the heterozygosity. Therefore, I stuck with the default 0.55 option (which is what Young et al. 2024 also did). I'm also using -primary to output a primary and alternate assembly, instead of an assembly and two haplotype assemblies, as we have no real way of knowing if the haplotypes produced are real or not. See my [notes](https://github.com/JillAshey/JillAshey_Putnam_Lab_Notebook/blob/master/_posts/2024-02-06-Apulchra-Genome-Assembly.md) and the github [results](https://github.com/hputnam/Apulchra_genome/tree/main/output/assembly/s_iterations) for different iteration results. `nano hifiasm.sh`

```
#!/bin/bash -i
#SBATCH -t 30-00:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

conda activate /data/putnamlab/conda/hifiasm

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Starting assembly with hifiasm" $(date)

hifiasm -o apul.hifiasm.s55_pa hifi_rr_allcontam_rem.fasta --primary -s 0.55 -t 36 2> apul_hifiasm_allcontam_rem_s55_pa.log

echo "Assembly with hifiasm complete!" $(date)

conda deactivate
```

This took about 3 days to run. The primary assembly file is `apul.hifiasm.s55_pa.p_ctg.gfa` and the alternate assembly file is `apul.hifiasm.s55_pa.a_ctg.gfa`. This [page](https://hifiasm.readthedocs.io/en/latest/interpreting-output.html#interpreting-output) provides a helpful overview of the Hifiasm output files. 

### Busco & Quast on Hifiasm assembly 

[Busco](https://busco.ezlab.org/) and [Quast ](https://github.com/ablab/quast) were used for assembly QC. Busco (Benchmarking Universal Single-Copy Orthologs) assesses the biologically completeness of an assembly by checking if highly conserved single copy orthologs are present. Quast provides assembly metrics, such as N50. 

Convert the output files from gfa to fa. 

```
## PRIMARY 
awk '/^S/{print ">"$2"\n"$3}' apul.hifiasm.s55_pa.p_ctg.gfa | fold > apul.hifiasm.s55_pa.p_ctg.fa

zgrep -c ">" apul.hifiasm.s55_pa.p_ctg.fa
187

## ALTERNATE 
awk '/^S/{print ">"$2"\n"$3}' apul.hifiasm.s55_pa.a_ctg.gfa | fold > apul.hifiasm.s55_pa.a_ctg.fa

zgrep -c ">" apul.hifiasm.s55_pa.a_ctg.fa
3548
```

Run Busco for the primary and alternate assembly. `nano busco_qc.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=15
#SBATCH --export=NONE
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

echo "Convert from gfa to fasta for downstream use" $(date)

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

###### PRIMARY ASSEMBLY w/ -s 0.55

awk '/^S/{print ">"$2;print $3}' apul.hifiasm.s55_pa.p_ctg.gfa > apul.hifiasm.s55_pa.p_ctg.fa

echo "Begin busco on hifiasm-assembled primary fasta with -s 0.55" $(date)

labbase=/data/putnamlab
busco_shared="${labbase}/shared/busco"
[ -z "$query" ] && query="${labbase}/jillashey/Apul_Genome/assembly/data/apul.hifiasm.s55_pa.p_ctg.fa" # set this to the query (genome/transcriptome) you are running
[ -z "$db_to_compare" ] && db_to_compare="${busco_shared}/downloads/lineages/metazoa_odb10"

source "${busco_shared}/scripts/busco_init.sh"  # sets up the modules required for this in the right order

# This will generate output under your $HOME/busco_output
cd "${labbase}/${Apul_Genome/assembly/data}"
busco --config "$EBROOTBUSCO/config/config.ini" -f -c 20 --long -i "${query}" -l metazoa_odb10 -o apul.primary.busco -m genome

echo "busco complete for hifiasm-assembled primary fasta with -s 0.55" $(date)

###### ALTERNATE ASSEMBLY w/ -s 0.55

awk '/^S/{print ">"$2;print $3}' apul.hifiasm.s55_pa.a_ctg.gfa > apul.hifiasm.s55_pa.a_ctg.fa

echo "Begin busco on hifiasm-assembled alternate fasta with -s 0.55" $(date)

labbase=/data/putnamlab
busco_shared="${labbase}/shared/busco"
[ -z "$query" ] && query="${labbase}/jillashey/Apul_Genome/assembly/data/apul.hifiasm.s55_pa.a_ctg.fa" # set this to the query (genome/transcriptome) you are running
[ -z "$db_to_compare" ] && db_to_compare="${busco_shared}/downloads/lineages/metazoa_odb10"

source "${busco_shared}/scripts/busco_init.sh"  # sets up the modules required for this in the right order

# This will generate output under your $HOME/busco_output
cd "${labbase}/${Apul_Genome/assembly/data}"
busco --config "$EBROOTBUSCO/config/config.ini" -f -c 20 --long -i "${query}" -l metazoa_odb10 -o apul.alternate.busco -m genome

echo "busco complete for hifiasm-assembled alternate fasta with -s 0.55" $(date)
```

Here are the results for the primary assembly: 

```
# BUSCO version is: 5.2.2 
# The lineage dataset is: metazoa_odb10 (Creation date: 2024-01-08, number of genomes: 65, number of BUSCOs: 954)
# Summarized benchmarking in BUSCO notation for file /data/putnamlab/jillashey/Apul_Genome/assembly/data/apul.hifiasm.s55_pa.p_ctg.fa
# BUSCO was run in mode: genome
# Gene predictor used: metaeuk

        ***** Results: *****

        C:93.3%[S:92.0%,D:1.3%],F:3.1%,M:3.6%,n:954        
        890     Complete BUSCOs (C)                        
        878     Complete and single-copy BUSCOs (S)        
        12      Complete and duplicated BUSCOs (D)         
        30      Fragmented BUSCOs (F)                      
        34      Missing BUSCOs (M)                         
        954     Total BUSCO groups searched                

Dependencies and versions:
        hmmsearch: 3.3
        metaeuk: GITDIR-NOTFOUND
```

93.3% overall completeness and 92% of single copy BUSCOs, which is great for the assembly! 

Run Quast for the primary and alternate assembly. I also included other published coral genomes to compare metrics from our study. `nano quast_qc.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --export=NONE
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

module purge
module load Python/2.7.18-GCCcore-10.2.0
module load QUAST/5.0.2-foss-2020b-Python-2.7.18
# previously used QUAST/5.2.0-foss-2021b but it failed and produced module conflict errors

echo "Begin quast of primary and alternate assemblies w/ reference" $(date)

quast -t 10 --eukaryote \
apul.hifiasm.s55_pa.p_ctg.fa \
apul.hifiasm.s55_pa.a_ctg.fa \
/data/putnamlab/jillashey/genome/Ofav_Young_et_al_2024/Orbicella_faveolata_gen_17.scaffolds.fa \
/data/putnamlab/jillashey/genome/Amil_v2.01/Amil.v2.01.chrs.fasta \
/data/putnamlab/jillashey/genome/Aten/GCA_014633955.1_Aten_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Ahya/GCA_014634145.1_Ahya_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Ayon/GCA_014634225.1_Ayon_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Mcap/V3/Montipora_capitata_HIv3.assembly.fasta \
/data/putnamlab/jillashey/genome/Pacuta/V2/Pocillopora_acuta_HIv2.assembly.fasta \
/data/putnamlab/jillashey/genome/Peve/Porites_evermanni_v1.fa \
/data/putnamlab/jillashey/genome/Ofav/GCF_002042975.1_ofav_dov_v1_genomic.fna \
/data/putnamlab/jillashey/genome/Pcomp/Porites_compressa_contigs.fasta \
/data/putnamlab/jillashey/genome/Plutea/plut_final_2.1.fasta \
-o /data/putnamlab/jillashey/Apul_Genome/assembly/output/quast

echo "Quast complete; all QC complete!" $(date)
```

See output files [here](https://github.com/hputnam/Apulchra_genome/tree/main/output/assembly/primary). Our assembly has 187 contigs, which is quite low compared to other coral species (except Ofav, which has 51). 

### ntlinks

After QC of the assembly, use [ntlinks](https://github.com/bcgsc/ntLink) to scaffold the assembly. It will not change the contigs themselves but can combine them into scaffolds using sequence overlaps or k-mer information. This can increase N50 and reduce assembly fragmentation. he ntlink software has options to run multiple iterations/rounds of ntlink to achieve the highest possible contiguity without sacrificing assembly correctness. From the Basic Protocol 3 from the [ntlinks paper](https://currentprotocols.onlinelibrary.wiley.com/doi/10.1002/cpz1.733): "Using the in-code round capability of ntLink allows a user to maximize the contiguity of the final assembly without needing to manually run ntLink multiple times. To avoid re-mapping the reads at each round, ntLink lifts over the mapping coordinates from the input draft assembly to the output post-ntLink scaffolds, which can then be used for the next round of ntLink. The same process can be repeated as many times as needed, thus enabling multiple rounds of ntLink to be powered by a single instance of long-read mapping." 

Install ntlinks on Andromeda using conda.

```
cd /data/putnamlab/conda
module load Miniconda3/4.9.2
conda create --prefix /data/putnamlab/conda/ntlink
conda activate /data/putnamlab/conda/ntlink
conda install -c bioconda -c conda-forge ntlink
```

Run ntlinks (5 rounds). `nano ntlinks_5rounds.sh`

```
#!/bin/bash -i
#SBATCH -t 30-00:00:00
#SBATCH --nodes=1 --ntasks-per-node=36
#SBATCH --export=NONE
#SBATCH --mem=500GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH --exclusive
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

module load Miniconda3/4.9.2

conda activate /data/putnamlab/conda/ntlink

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Starting scaffolding of hifiasm primary assembly with ntlinks (rounds = 5)" $(date)

ntLink_rounds run_rounds_gaps \
t=36 \
g=100 \
rounds=5 \
gap_fill \
target=apul.hifiasm.s55_pa.p_ctg.fa \
reads=hifi_rr_allcontam_rem.fasta \
out_prefix=apul_ntlink_s55

echo "Scaffolding of hifiasm primary assembly with ntlinks (rounds = 5) complete!" $(date)
```

The code above is scaffolding contigs iteratively over 5 rounds, improving contig ordering and orientation. The `gap_fill` attempts to fill gaps between contigs using the reads, while the gap size `-g` controls the minimum gap size allowed between joined contigs. 

### Busco & Quast on Hifiasm + ntlinks assembly 

Use Busco and Quast to QC the updated assembly. `nano busco_ntlink_qc.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=15
#SBATCH --export=NONE
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

echo "Convert from gfa to fasta for downstream use" $(date)

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

echo "Begin busco on scaffolded assembly" $(date)

labbase=/data/putnamlab
busco_shared="${labbase}/shared/busco"
[ -z "$query" ] && query="${labbase}/jillashey/Apul_Genome/assembly/data/apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa" # set this to the query (genome/transcriptome) you are running
[ -z "$db_to_compare" ] && db_to_compare="${busco_shared}/downloads/lineages/metazoa_odb10"

source "${busco_shared}/scripts/busco_init.sh"  # sets up the modules required for this in the right order

# This will generate output under your $HOME/busco_output
cd "${labbase}/${Apul_Genome/assembly/data}"
busco --config "$EBROOTBUSCO/config/config.ini" -f -c 20 --long -i "${query}" -l metazoa_odb10 -o apul.ntlink.busco -m genome

echo "busco complete for scaffolded assembly" $(date)
```

`nano quast_ntlink_qc.sh`

```
#!/bin/bash 
#SBATCH -t 100:00:00
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --export=NONE
#SBATCH --mem=250GB
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH --mail-user=jillashey@uri.edu #your email to send notifications
#SBATCH --account=putnamlab
#SBATCH -D /data/putnamlab/jillashey/Apul_Genome/assembly/scripts
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error

cd /data/putnamlab/jillashey/Apul_Genome/assembly/data

module purge
module load Python/2.7.18-GCCcore-10.2.0
module load QUAST/5.0.2-foss-2020b-Python-2.7.18
# previously used QUAST/5.2.0-foss-2021b but it failed and produced module conflict errors

echo "Begin quast of scaffolded assemblies w/ references" $(date)

quast -t 10 --eukaryote \
apul.hifiasm.s55_pa.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa \
apul.hifiasm.s55_pa.p_ctg.fa \
apul.hifiasm.s55_pa.a_ctg.fa \
/data/putnamlab/jillashey/genome/Ofav_Young_et_al_2024/Orbicella_faveolata_gen_17.scaffolds.fa \
/data/putnamlab/jillashey/genome/Amil_v2.01/Amil.v2.01.chrs.fasta \
/data/putnamlab/jillashey/genome/Aten/GCA_014633955.1_Aten_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Ahya/GCA_014634145.1_Ahya_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Ayon/GCA_014634225.1_Ayon_1.0_genomic.fna \
/data/putnamlab/jillashey/genome/Mcap/V3/Montipora_capitata_HIv3.assembly.fasta \
/data/putnamlab/jillashey/genome/Pacuta/V2/Pocillopora_acuta_HIv2.assembly.fasta \
/data/putnamlab/jillashey/genome/Peve/Porites_evermanni_v1.fa \
/data/putnamlab/jillashey/genome/Ofav/GCF_002042975.1_ofav_dov_v1_genomic.fna \
/data/putnamlab/jillashey/genome/Pcomp/Porites_compressa_contigs.fasta \
/data/putnamlab/jillashey/genome/Plutea/plut_final_2.1.fasta \
-o /data/putnamlab/jillashey/Apul_Genome/assembly/output/quast

echo "Quast complete; all QC complete!" $(date)
```

See QC output [here](https://github.com/hputnam/Apulchra_genome/tree/main/output/assembly/ntlink). Busco completeness increased to 96.7%, with single copy orthologs at 95.1%. There is an improvement of number of contigs from the initial assembly (187 contigs for initial assembly and 174 contigs for ntlinks cleaned assembly). N50 also increased after running ntlinks. 





