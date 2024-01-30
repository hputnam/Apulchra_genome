DNA is extracted using Qiagen Genomic Tip protocol and buffers. The samples are 2x ethanol precipitated post column elution, put in the freezer overnight and then spun for 30 minutes at 14K rcf the next day. The alcohol is removed and the DNA pellets are suspended in lowTE. In the case of your 3 samples, we combined them and then did a further cleanup to make sure that they would be sufficiently clean to sequence well. This is using the PACBio SRE Kit to remove fragments under 25kb, part number 102-208-300.

DNA is then sheared to ~17kb using a Diagenode Megaruptor. Shearing was checked on femtopulse to assess size. The DNA was then cleaned and concentrated post shearing using a 1x AMPure bead cleanup. The DNA was then made into a library using the PacBio SMRTbell prep kit 3.0, following the instructions provided with the kit. Final sizing of the library was performed using the 35% v/v dilution of AMPure PB beads as suggested on page 12 of the protocol (just uploaded) "Preparing whole genome and metagenome libraries using SMRTbell prep kit 3.0"


## Output

```
m84100_240128_024355_s2.fail_reads.bc1029.bam   
m84100_240128_024355_s2.fail_reads.bc1029.bam.pbi   
m84100_240128_024355_s2.fail_reads.unassigned.bam   
m84100_240128_024355_s2.fail_reads.unassigned.bam.pbi   
m84100_240128_024355_s2.hifi_reads.bc1029.bam   
m84100_240128_024355_s2.hifi_reads.bc1029.bam.pbi   
