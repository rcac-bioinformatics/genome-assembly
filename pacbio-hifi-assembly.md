---
title: 'PacBio HiFi Assembly using HiFiasm'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- What is HiFiasm, and how does it improve genome assembly using PacBio HiFi reads?
- What are the key steps in running HiFiasm for haplotype-resolved assembly?
- How does HiFiasm handle haplotype resolution and purging of duplications?
- What are the benefits of using HiFiasm for assembling complex and heterozygous genomes?


::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: objectives

- Understand the purpose and function of HiFiasm for haplotype-resolved genome assembly.
- Learn to set up and run HiFiasm for assembling genomes using PacBio HiFi reads.
- Gain hands-on experience with haplotype resolution and purging of duplications in HiFiasm.
- Analyze and interpret HiFiasm output to assess assembly quality and completeness.

::::::::::::::::::::::::::::::::::::::::::::::::


## Introduction to HiFiasm

[HiFiasm](https://www.nature.com/articles/s41592-020-01056-5) is a specialized de novo assembler designed for PacBio HiFi reads, providing high-quality, haplotype-resolved genome assemblies. Unlike traditional assemblers that collapse heterozygous regions into a consensus sequence, HiFiasm preserves haplotype information using a phased assembly graph approach. This enables more accurate representation of genetic variations and structural differences.

Leveraging the low error rate of HiFi reads, HiFiasm constructs phased assembly graphs that allow for haplotype separation without requiring external polishing or duplication-purging tools. It significantly improves assembly contiguity, resolving complex regions more effectively than alternative methods. HiFiasm is widely used in genome projects, including the Human Pangenome Project, and has been successfully applied to large and highly heterozygous genomes such as Sequoia sempervirens (~30 Gb). 

With its ability to generate fast and accurate assemblies, HiFiasm has become the preferred tool for haplotype-resolved genome assembly, especially when parental reads or Hi-C data are available.


:::::::::::::::::::::::::::::::::::::::  prereq

## Latest version of HiFiasm

The latest version of HiFiasm supports assembling ONT reads as well. It has also added support to integrate ultra-long ONT reads for improved contiguity, as well as hybrid assembly (using both ONT and HiFi reads). Apart from ONT data, HiFiasm can handle Hi-C data for scaffolding, as well as kmer profiles from parents to resolve haplotypes. The latest version includes several bug fixes and performance improvements, making it more efficient and user-friendly.


:::::::::::::::::::::::::::::::::::::::


## Installation and Setup

HiFiasm is available as module on RCAC clusters. You can load the module using the following command:


```bash
ml --force purge
ml biocontainers
ml hifiasm
hifiasm --version
```

You can also use the Singularity container for HiFiasm, which provides a consistent environment across different systems. The container can be pulled from the BioContainers registry using the following command:

```bash
apptainer pull docker://quay.io/biocontainers/hifiasm:0.24.0--h5ca1c30_0
apptainer exec hifiasm_0.24.0--h5ca1c30_0.sif hifiasm --version
```

## Overview of HiFiASM Read Assembly

HiFiasm can assemble high-quality, contiguous genome sequences from PacBio High-Fidelity (HiFi) reads. HiFi reads are long and highly accurate (99%+), making them ideal for assembling complex genomes, resolving repetitive regions, and distinguishing haplotypes in diploid or polyploid organisms.

The assembly workflow typically involves:

1. Preprocessing reads – filtering and quality-checking raw hifi reads
2. Read overlap detection – identifying how reads align to each other
3. Error correction – resolving sequencing errors while maintaining true haplotype differences
4. Graph construction – building an assembly graph to represent contig relationships
5. Contig generation – extracting the final set of contiguous sequences
6. Post-processing – refining assemblies by purging duplications or scaffolding

HiFiasm is optimized for this process, leveraging the high accuracy of HiFi reads to generate contigs with minimal fragmentation and greater haplotype resolution compared to traditional assemblers.

![HiFiasm assembler](https://github.com/user-attachments/assets/1ab2a17c-ac29-42c7-a890-5c86577e2f19)


## HiFiasm: basic workflow

To run HiFiasm, you need to provide the input HiFi reads in FASTA or FASTQ format. The basic command structure is as follows:

```bash
ml --force purge
ml biocontainers
ml hifiasm
hifiasm \
    -t ${SLURM_CPUS_ON_NODE} \
    -o Athaliana_hifiasm_default.asm \
    9994.q20.CCS-filtered.fastq
```

::: callout

In this command:

- `-t` specifies the number of threads to use
- `-o` specifies the output prefix for the assembly
-  last argument is the input HiFi reads file (fastq format)

The input can either be fastq or fasta, compressed or uncompressed. The output will be stored in the same directory with the specified prefix.

:::

## Understanding HiFiasm Output


The run generates several output files. Here are all the files and their descriptions:

| filename                                                | description |
|:-------|-------------|
| `Athaliana_hifiasm_default.asm.ec.bin`                  | error-corrected reads stored in binary format |
| `Athaliana_hifiasm_default.asm.ovlp.source.bin`         | source overlap data between reads in binary format |
| `Athaliana_hifiasm_default.asm.ovlp.reverse.bin`        | reverse overlap data between reads in binary format |
| `Athaliana_hifiasm_default.asm.bp.r_utg.noseq.gfa`      | assembly graph of raw unitigs (without sequence) |
| `Athaliana_hifiasm_default.asm.bp.r_utg.gfa`            | assembly graph of raw unitigs (with sequence) |
| `Athaliana_hifiasm_default.asm.bp.r_utg.lowQ.bed`       | low-quality regions in raw unitigs |
| `Athaliana_hifiasm_default.asm.bp.p_utg.noseq.gfa`      | assembly graph of purged unitigs (without sequence) |
| `Athaliana_hifiasm_default.asm.bp.p_utg.gfa`            | assembly graph of purged unitigs (with sequence) |
| `Athaliana_hifiasm_default.asm.bp.p_utg.lowQ.bed`       | low-quality regions in purged unitigs |
| `Athaliana_hifiasm_default.asm.bp.p_ctg.noseq.gfa`      | assembly graph of primary contigs (without sequence) |
| `Athaliana_hifiasm_default.asm.bp.p_ctg.gfa`            | assembly graph of primary contigs (with sequence) |
| `Athaliana_hifiasm_default.asm.bp.p_ctg.lowQ.bed`       | low-quality regions in primary contigs |
| `Athaliana_hifiasm_default.asm.bp.hap1.p_ctg.noseq.gfa` | haplotype 1 primary contigs (without sequence) |
| `Athaliana_hifiasm_default.asm.bp.hap1.p_ctg.gfa`       | haplotype 1 primary contigs (with sequence) |
| `Athaliana_hifiasm_default.asm.bp.hap2.p_ctg.noseq.gfa` | haplotype 2 primary contigs (without sequence) |
| `Athaliana_hifiasm_default.asm.bp.hap2.p_ctg.gfa`       | haplotype 2 primary contigs (with sequence) |
| `Athaliana_hifiasm_default.asm.bp.hap1.p_ctg.lowQ.bed`  | low-quality regions in haplotype 1 primary contigs |


:::::::::::::::::::::::::::::::::::::::  prereq

## Where are the assembly/contig sequences?

The `*_ctg.gfa` file contains the contigs (haplotype-resolved, and primary only) in GFA (Graphical Fragment Assembly) format.
You can extract the sequences from this file using `awk`.
The sequences are represented as lines starting with `S` followed by the contig ID and the sequence.


```bash
for ctg in *_ctg.gfa; do
    awk '/^S/{print ">"$2"\n"$3}' ${ctg} > ${ctg%.gfa}.fasta
done
```

:::::::::::::::::::::::::::::::::::::::


Let's take a look at the sats of this assembly:

```bash
ml --force purge
ml biocontainers
ml quast
quast.py \
    --fast \
    --threads ${SLURM_CPUS_ON_NODE} \
    -o quast_basic_stats \
    *p_ctg.fasta
```

::: callout

## Quast metrics

**Key metrics for assembly quality assessment**  

| **Metric** | **Description & Importance** |
|:---|-----------------------------|
| **# Contigs** | The number of contiguous sequences in the assembly. Fewer, larger contigs indicate a more contiguous assembly. |
| **Largest Contig** | The length of the longest assembled sequence. A larger value suggests better resolution of large genomic regions. |
| **Total Length** | The sum of all contig lengths. Should approximately match the expected genome size. |
| **N50** | The contig length at which 50% of the assembly is covered. Higher values indicate a more contiguous assembly. |
| **N90** | The contig length at which 90% of the assembly is covered. Provides insight into the distribution of smaller contigs. |
| **L50** | The number of contigs that make up 50% of the assembly. Lower values indicate higher contiguity. |
| **L90** | The number of contigs that make up 90% of the assembly. Lower values suggest fewer, larger contigs. |
| **auN** | Weighted average of contig lengths, emphasizing longer contigs. Higher values indicate better continuity. |
| **# N/100 kbp** | Measures the presence of gaps (`N`s) in the assembly. Ideally should be 0, meaning no unresolved bases. |

**How to interpret**  

- **High N50 and low L50** suggest a well-assembled genome with fewer, larger contigs.  
- **Total Length** should be close to the estimated genome size, ensuring completeness.  
- **Low # of contigs** indicates better continuity, meaning fewer breaks in the genome.  
- **No `N` bases** means the assembly is gap-free and doesn’t contain unresolved regions.  
:::




## Handling haplotype-resolved contigs

HiFiasm generates haplotype-resolved contigs. With the default options above, you saw that it generated `hap1.p_ctg`, `hap2.p_ctg` and `.p_ctg` GFA files, which corresponds to haplotype 1, haplotype 2, and primary contigs, respectively.
Although HiFiasm separates the haplotypes, it is unable to phase (assign the actual regions of hap1 and hap2 to their respective haplotypes consistently across the genome) them without additional data.
The haplotype-resolved contigs, as-is, is still valuable information, and can be used for downstream analyses requiring haplotype-specific information.
The primary contigs represent the consensus sequence, and is usually more complete than either of the haplotype only assemblies.

- Hifiasm purges haplotig duplications by default (to produce two sets of partially phased contigs)
- For inbred or homozygous genomes, you may disable purging with option `-l 0` ((`hifiasm -o prefix.asm -l 0 -t ${SLURM_CPUS_ON_NODE} input.fq.gz`)
- To get primary/alternate assemblies, the option `--primary` should be set (`hifiasm -o prefix.asm --primary -t ${SLURM_CPUS_ON_NODE} input.fq.gz`)
- For heterozygous genomes, you can set `-l 1`, `-l 2`, or `-l 3`, to adjust purging of haplotigs
    * `-l 1` to only purge contained haplotigs
    * `-l 2` to purge all types of haplotigs
    * `-l 3` to purge all types of haplotigs in the most aggressive way
- If you have parental kmer profiles, you can use them to resolve haplotypes


We can try running HiFiasm with various `-l` options to see how it affects the assembly quality.


::: tab

### purge `l=0`

```bash
ml --force purge
ml biocontainers
ml hifiasm
# purge level 0
mkdir -p hifiasm_purge_level_0
cd hifiasm_purge_level_0
ln -s ../9994.q20.CCS-filtered.fastq
hifiasm \
  -o Athaliana_hifiasm_purge_level_0.asm \
  -l 0 \
  -t ${SLURM_CPUS_ON_NODE} \
  9994.q20.CCS-filtered.fastq
```

### purge `l=1`

```bash
ml --force purge
ml biocontainers
ml hifiasm
# purge level 1
mkdir -p hifiasm_purge_level_1
cd hifiasm_purge_level_1
ln -s ../9994.q20.CCS-filtered.fastq
hifiasm \
  -o Athaliana_hifiasm_purge_level_1.asm \
  -l 1 \
  -t ${SLURM_CPUS_ON_NODE} \
  9994.q20.CCS-filtered.fastq
```

### purge `l=2`

```bash
ml --force purge
ml biocontainers
ml hifiasm
# purge level 2
mkdir -p hifiasm_purge_level_2
cd hifiasm_purge_level_2
ln -s ../9994.q20.CCS-filtered.fastq
hifiasm \
  -o Athaliana_hifiasm_purge_level_2.asm \
  -l 2 \
  -t ${SLURM_CPUS_ON_NODE} \
  9994.q20.CCS-filtered.fastq
```

### purge `l=3`

```bash
ml --force purge
ml biocontainers
ml hifiasm
# purge level 3
mkdir -p hifiasm_purge_level_3
cd hifiasm_purge_level_3
ln -s ../9994.q20.CCS-filtered.fastq
hifiasm \
  -o Athaliana_hifiasm_purge_level_3.asm \
  -l 3 \
  -t ${SLURM_CPUS_ON_NODE} \
  9994.q20.CCS-filtered.fastq
```

:::




::: callout
Each of these will run in about ~15 minutes with 32 cores. You can either run them in parallel or sequentially or request more cores to run them faster.
:::



:::::::::::::::::::::::::::::::::::::::  prereq

## Comparing assemblies

Convert GFA files to FASTA format

```bash
for dir in hifiasm_purge_level_{0..3}; do 
    cd ${dir}
    for ctg in *_ctg.gfa; do
        awk '/^S/{print ">"$2"\n"$3}' ${ctg} > ${ctg%.gfa}.fasta
    done
    cd ..
done
```

Run QUAST to compare the assemblies

```bash
mkdir -p quast_stats
for fasta in hifiasm_purge_level_{0..3}/*_p_ctg.fasta; do
    ln -s ${fasta} quast_stats/
done
cd quast_stats
quast.py \
    --fast \
    --threads ${SLURM_CPUS_ON_NODE} \
    -o quast_purge_level_stats \
    *_p_ctg.fasta
```


Run Compleasm to compare the assemblies


```bash
ml --force purge
ml biocontainers
ml compleasm
mkdir -p compleasm_stats
for fasta in hifiasm_purge_level_{0..3}/*_p_ctg.fasta; do
    ln -s ${fasta} compleasm_stats/
done
cd compleasm_stats
for fasta in *_p_ctg.fasta; do
    compleasm run \
       -a ${fasta} \
       -o ${fasta%.*} \
       -l brassicales_odb10 \
       -t ${SLURM_CPUS_ON_NODE}
done
```

Examining the results from QUAST and Compleasm, compare the assembly statistics and assess the impact of different purging levels on the assembly quality. Look for metrics like N50, L50, and total assembly size to evaluate the contiguity and completeness of the assemblies.


:::::::::::::::::::::::::::::::::::::::



## Improving Assembly Quality  

After the first round of assembly, you will have the files `*.ec.bin`, `*.ovlp.source.bin`, and `*.ovlp.reverse.bin`. Save these files and try various options to see if you can improve the assembly.
First, make a folder to move the .gfa, .fasta, and .bed files. 
These are the results from the first round of assembly. 
Second, adjust the parameters in the hifiasm command and run the assembler again.
Third, move results to a new folder and compare the results of the first folder.
You can re-run the assembly quickly and generate statistics for each of these folders and compare them to see if the changes improved the assembly.



## Alternative Assembler: Flye for HiFi   

Flye is another popular assembler specialized for ONT reads, offering a different approach to haplotype-resolved assembly. The latest version can also use HiFi reads to generate great quality assemblies. We will explore Flye in a separate episode to compare its performance with HiFiasm. But in this optional section, you can try running Flye with HiFi reads to see how it performs compared to HiFiasm.

### Running Flye with HiFi Reads

To run Flye with HiFi reads, you can use the following command structure:

```bash
ml --force purge
ml biocontainers
ml flye
flye \
  --pacbio-hifi 9994.q20.CCS-filtered-60x.fastq \
  --genome-size 135m \
  --out-dir flye_pcb \
  --threads ${SLURM_CPUS_ON_NODE}
```

::: callout

## Options used

In this command:

- `--pacbio-hifi` specifies the input HiFi reads file
- `--genome-size` provides an estimate of the genome size (optional)
- `--out-dir` specifies the output directory for Flye results
- `--threads` specifies the number of threads to use

The output will be stored in the specified directory, containing the assembly graph, contigs, and other relevant files.

With 64 cores, this will run in about ~40 mins. It needs about ~80-90Gb of memory.

:::


:::::::::::::::::::::::::::::::::::::::  prereq

## Quality metrics

Run quality metrics on Flye assembly:

```bash
ml --force purge
ml biocontainers
ml quast
quast.py \
    --fast \
    --threads ${SLURM_CPUS_ON_NODE} \
    -o quast_flye_stats \
    flye_pcb/assembly.fasta
ml compleasm
compleasm run \
  -a flye_pcb/assembly.fasta \
  -o flye_pcb \
  -l brassicales_odb10 \
  -t ${SLURM_CPUS_ON_NODE}
```

Which assembler did  a better job at assembling the genome? Compare the statistics from QUAST and Compleasm for Flye and HiFiasm assemblies to evaluate their performance.

:::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::: keypoints 

- **HiFiasm** is a specialized assembler for PacBio HiFi reads, providing high-quality, haplotype-resolved genome assemblies.
- It leverages the high accuracy of HiFi reads to generate phased assembly graphs, preserving haplotype information.
- HiFiasm is optimized for resolving complex regions and distinguishing haplotypes in diploid or polyploid organisms.
- The assembler generates primary contigs and haplotype-resolved contigs, offering valuable information for downstream analyses.
- By adjusting purging levels and using parental kmer profiles, users can improve haplotype resolution and assembly quality.


::::::::::::::::::::::::::::::::::::::::::::::::

