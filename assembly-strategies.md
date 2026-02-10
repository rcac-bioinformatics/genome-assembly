---
title: 'Assembly Strategies'
teaching: 20
exercises: 0
---

:::::::::::::::::::::::::::::::::::::: questions 

- What factors influence the choice of genome assembly strategy?
- How do different assembly methods compare in terms of read length, accuracy, and computational requirements?
- What are the key steps in evaluating genome assemblies using BUSCO and QUAST?
- How do Bionano OGM and Hi-C sequencing improve genome continuity and organization?


::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Understand factors influencing the choice of genome assembly strategy.
- Compare different assembly methods based on read length, accuracy, and computational requirements.
- Learn how to evaluate genome assemblies using BUSCO and QUAST.
- Explore the role of Bionano OGM and Hi-C sequencing in improving genome continuity.

::::::::::::::::::::::::::::::::::::::::::::::::


## Assembly Strategies

Genome assembly involves choosing the right approach based on sequencing technology, read type, genome complexity, and research objectives. This chapter introduces key factors influencing assembly strategy selection, from read length and coverage requirements to computational trade-offs. We will explore different methods—PacBio HiFi with HiFiasm, ONT with Flye, and hybrid assemblies—along with scaffolding techniques like Bionano Optical Genome Mapping (OGM) and Hi-C, which help improve genome continuity and organization. Finally, we’ll discuss assembly evaluation tools such as BUSCO and QUAST to assess the completeness and quality of assembled genomes.


:::::::::::::::::::::::::::::::::::::::  prereq

## Factors Influencing the Choice of Strategy

- **Read length**: Affects the ability to resolve repeats; short reads struggle with complex regions, while long reads improve contiguity.  
- **Coverage depth**: Crucial for assembly accuracy, with HiFi requiring 20-30x, ONT needing 50-100x, and hybrid assemblies depending on short-read support for polishing.  
- **Genome complexity**: Includes repeat content, heterozygosity, and polyploidy, which influence assembly success and determine whether specialized tools or additional scaffolding methods are needed.  
- **Computational resources**: Vary across assembly strategies, with HiFiasm being RAM-intensive, Flye being more lightweight, and hybrid assemblies requiring additional processing for polishing.  
- **Sequencing budget**: Plays a role, as HiFi sequencing is costlier but highly accurate, ONT is cheaper but requires more data for error correction, and hybrid approaches balance cost and quality.  
- **Downstream analyses**: Structural variation detection, gene annotation, or chromosome-level assemblies influence the choice of assembler and the need for scaffolding methods like Hi-C or Bionano OGM.

:::::::::::::::::::::::::::::::::::::::

## Comparative Assembly Strategies

| Factor                      | PacBio HiFi             | ONT                        | Hybrid (ONT + PacBio HiFi)      |
|-----------------------------|-------------------------|----------------------------|---------------------------------|
| **Read length**             | ~15-20kb                | 10-100kb+                   | Mix of ultra-long & accurate   |
| **Read accuracy**           | High (~99%)             | Variable: ~90% (R9/fast) to ~99% (R10.4/HAC/SUP) | High (after polishing)         |
| **Coverage needed**         | 20-30x                  | 50-100x                     | ONT: 50x + HiFi: 20-30x        |
| **Cost per Gb**             | Expensive               | Lower                       | Medium                         |
| **Error profile**           | Random errors, low indels | Systematic errors in homopolymers; greatly reduced with R10.4+ | ONT errors corrected by HiFi reads |
| **Computational requirements** | High RAM required  | Moderate RAM required       | Moderate                       |
| **Best for**                | High-accuracy assemblies | Ultra-long contigs         | Combines advantages of both    |
| **Repeat resolution**       | Good                     | Very good                  | Very good                      |
| **Scaffolding needed**      | Rarely needed           | May be needed               | Sometimes needed               |
| **Polishing required**      | Not required            | Required (Medaka)           | Polish with HiFi reads         |
| **Structural variant detection** | Good             | Excellent                   | Good                           |
| **Haplotype phasing**       | Excellent               | Good                        | Moderate                       |
| **Genome size suitability** | Suitable for large and small genomes | Best for large genomes | Best for complex genomes     |
| **Downstream applications** | Reference-quality genome assembly, annotation | Structural variation analysis, de novo assembly | Genome correction, variant calling, scaffolding |

## Contig vs. Scaffold vs. Chromosome-Level Assembly  

Genome assemblies progress through different levels of completeness and organization:  

- **Contig-level assembly**: The raw output of assemblers, consisting of contiguous sequences without known order or orientation. Longer contigs indicate better assembly continuity.  
- **Scaffold-level assembly**: Contigs linked together using additional data (e.g., long-range mate-pair reads, optical maps, or Hi-C). Gaps (represented as ‘N’s) remain where connections exist but sequence information is missing.  
- **Chromosome-level assembly**: The highest-quality assembly, where scaffolds are further ordered and oriented into full chromosomes using genetic maps, Hi-C data, or synteny with a reference genome.  

Higher levels of assembly provide better genome context, but require additional scaffolding methods beyond de novo assembly.

![Assembly levels](https://github.com/user-attachments/assets/4b7406b6-747a-4a34-b816-e1de2cf444a9)

## Workflow for Various Assemblies

In this workshop, we will use HiFiasm for PacBio HiFi assemblies, Flye for ONT assemblies, and Flye in hybrid mode for ONT + PacBio HiFi assemblies, followed by quality assessment using Compleasm and QUAST to evaluate completeness and accuracy.


### PacBio HiFi Assembly with HiFiasm


- **PacBio HiFi reads**: Highly accurate long reads with low error rates, suitable for de novo assembly without polishing.
- **HiFiasm**: A specialized assembler for HiFi data, leveraging read accuracy and length to resolve complex regions and produce high-quality contigs.
- **Workflow**: Run HiFiasm with HiFi reads, adjust parameters based on genome size and complexity, and evaluate the assembly using Compleasm and QUAST.

![PacBio Assembly](https://github.com/user-attachments/assets/1f87d81a-707b-44ff-a8e1-49648f61de95)


### ONT Assembly with Flye

- **ONT reads**: Ultra-long reads with higher error rates, requiring additional error correction and polishing steps.
- **Flye**: A de novo assembler optimized for long reads, capable of resolving complex repeats and generating high-quality assemblies.
- **Workflow**: Run Flye with ONT reads, adjust parameters based on genome size and complexity, and polish the assembly using Medaka for basecalling and consensus polishing.

![ONT assembly](https://github.com/user-attachments/assets/9864ae7d-a893-4aec-ad4a-ea57170c8c27)


### Hybrid (ONT + PacBio) Assembly with Flye

- **Hybrid assembly**: Combines the strengths of both technologies for improved accuracy and contiguity.
- **Workflow**: Run Flye with both ONT and PacBio reads, adjust parameters for hybrid mode, and polish the assembly using ONT or PacBio reads for error correction and consensus polishing.

![Hybrid assembly](https://github.com/user-attachments/assets/9b51523d-2358-4ad3-b6b3-bfe5d0189e4d)


## Assembly Evaluation 

- Why assessing genome assembly quality is crucial before downstream analyses.  
- Metrics to determine assembly completeness, accuracy, and contiguity.  

**1. BUSCO (Benchmarking Universal Single-Copy Orthologs)/ Compleasm**

- [Compleasm](https://github.com/huangnengCSU/compleasm) is a faster alternative to BUSCO for assessing genome completeness based on single-copy orthologs. It evaluates genome completeness by checking for highly conserved, single-copy genes expected to be present in nearly all members of a given lineage. These genes are essential for basic cellular functions, making them reliable markers for assessing genome assembly quality.

- We expect these genes to be present in our organism because they are evolutionarily conserved and critical for survival. If many BUSCO genes are missing or fragmented, it suggests gaps, misassemblies, or sequencing errors, which can compromise downstream analyses like gene annotation and functional studies. A high BUSCO completeness score indicates a well-assembled genome with minimal missing data.

- The BUSCO reports provide detailed statistics on the number of complete, fragmented, and missing BUSCO genes, as well as the percentage of genome completeness. The output helps identify areas for improvement and guide further optimization steps in the assembly process.

<img width="1030" alt="BUSCO genes" src="https://github.com/user-attachments/assets/e4c7951f-f4f1-4395-974c-abd6716d8cd1" />

**2. QUAST (Quality Assessment Tool for Genome Assemblies)**  


- **Comprehensive Assembly Statistics**: QUAST provides detailed metrics beyond N50 and L50, including **total number of contigs, GC content, genome size estimation, and misassembly rates**, allowing in-depth evaluation of genome continuity and structure.  

- **Reference-Based and Reference-Free Evaluation**: It can assess assemblies against a reference genome (identifying misassemblies, inversions, and duplications) or work in **reference-free mode**, making it useful for de novo assemblies without a known genome sequence.  

- **Structural Error Detection and Gene Feature Analysis**: QUAST integrates gene annotation tools like **BUSCO and GeneMark**, highlights misassemblies based on alignment breaks, and detects **gaps, relocations, and translocations**, making it particularly useful for validating scaffolding approaches and hybrid assemblies.


**3. Merqury: K-mer based assembly evaluation**  

- **Assembly Accuracy Check**: Merqury compares k-mers from sequencing reads to the assembled genome, identifying mismatches, missing k-mers, and sequencing errors without requiring a reference genome.  
- **Haplotype Purity and Phasing**: It calculates **QV (quality value)** scores and provides **completeness metrics for haplotypes**, helping assess whether an assembly accurately represents both parental haplotypes or contains chimeric sequences.  
- **Consensus and Read Support Validation**: By analyzing k-mer spectra, Merqury detects **underrepresented or overrepresented regions**, highlighting assembly errors, collapsed repeats, or sequencing biases that may impact downstream analyses.

![kmer spectra](https://github.com/user-attachments/assets/042f0ad9-e06e-4aa0-8faf-51f0d42e2983)

## Bionano and Hi-C Reads in Genome Assembly  

**Bionano Optical Genome Mapping (OGM)** provides ultra-long, label-based maps of DNA molecules, helping to scaffold contigs, detect misassemblies, and resolve large structural variations. It improves genome continuity by linking fragmented sequences, especially in repeat-rich or complex genomes.  

**Hi-C sequencing** captures chromatin interactions, allowing scaffolding of contigs into chromosome-scale assemblies based on physical proximity in the nucleus. It helps in ordering and orienting scaffolds, identifying misassemblies, and resolving haplotypes, making it essential for generating **chromosome-level genome assemblies**.

![Bionano and HiC for assembly improvement](https://github.com/user-attachments/assets/7f983713-7ea7-4522-8540-349955a9f12e)

[ref](https://doi.org/10.1038/ng.3802)


## Resource Requirements

The table below provides approximate resource requirements for the main assembly tools used in this workshop, based on the _A. thaliana_ (~135 Mb) genome:

| Tool | Threads | RAM | Wall Time | Notes |
|------|---------|-----|-----------|-------|
| **hifiasm** | 32 | ~32 GB | ~15-30 min | Scales well with threads |
| **Flye (ONT)** | 32 | ~16 GB | ~30-60 min | Use `--genome-size` for guidance |
| **Flye (HiFi)** | 64 | ~80-90 GB | ~40 min | Higher RAM than ONT mode |
| **Medaka** | 16 | ~16 GB | ~30 min | GPU accelerates significantly |
| **Meryl + Merqury** | 16 | ~8 GB | ~10 min | Memory scales with k-mer DB size |
| **QUAST** | 16 | ~8 GB | ~5-10 min | Reference mode uses more RAM |
| **Compleasm** | 16 | ~4 GB | ~5 min | Faster alternative to BUSCO |
| **Bionano Solve** | 16 | ~16 GB | ~30-60 min | Depends on genome map complexity |

::: callout

These are approximate values for the _A. thaliana_ genome (~135 Mb). Larger genomes will require proportionally more resources. Always check cluster queue limits and request appropriate resources in your SLURM job scripts.

:::

## Emerging Assemblers and Approaches

The field of genome assembly is rapidly evolving. Two notable recent developments:

- **Verkko** (v2.2+): Developed by the Telomere-to-Telomere (T2T) consortium, Verkko combines HiFi and ultra-long ONT reads to produce telomere-to-telomere assemblies. It uses a graph-based approach that leverages the accuracy of HiFi reads with the spanning capability of ONT reads to resolve complex repeats and centromeric regions.

- **hifiasm ONT-only mode** (v0.19.0+): hifiasm now supports assembling ONT reads alone using the `--ont` flag, expanding its use beyond PacBio HiFi data. This was validated in a [2024 Nature Methods publication](https://doi.org/10.1038/s41592-024-02279-w) showing competitive results with dedicated ONT assemblers.

These tools represent the current frontier of genome assembly and may be worth exploring for projects requiring the highest contiguity and completeness.


::::::::::::::::::::::::::::::::::::: keypoints

- Genome assembly strategy depends on read type, genome complexity, and computational resources, with PacBio HiFi, ONT, and hybrid approaches offering different advantages in accuracy, cost, and contiguity.  
- Assembly evaluation is critical for assessing completeness and accuracy, using tools like **BUSCO for gene completeness, QUAST for structural integrity, and Merqury for k-mer-based validation**.  
- Scaffolding methods like Bionano OGM and Hi-C improve genome organization, resolving large structural variations and ordering contigs into chromosome-level assemblies.  
- A well-assembled genome is essential for downstream applications such as annotation, comparative genomics, and structural variation analysis, with missing or misassembled regions potentially leading to incorrect biological conclusions.


::::::::::::::::::::::::::::::::::::::::::::::::

