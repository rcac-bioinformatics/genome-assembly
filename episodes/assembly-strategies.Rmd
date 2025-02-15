---
title: 'Assembly Strategies'
teaching: 10
exercises: 2
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


### Assembly Strategies

Genome assembly involves choosing the right approach based on sequencing technology, read type, genome complexity, and research objectives. This chapter introduces key factors influencing assembly strategy selection, from read length and coverage requirements to computational trade-offs. We will explore different methods—PacBio HiFi with HiFiasm, ONT with Flye, and hybrid assemblies—along with scaffolding techniques like Bionano Optical Genome Mapping (OGM) and Hi-C, which help improve genome continuity and organization. Finally, we’ll discuss assembly evaluation tools such as BUSCO and QUAST to assess the completeness and quality of assembled genomes.

#### Factors Influencing the Choice of Strategy

- **Read length**: Affects the ability to resolve repeats; short reads struggle with complex regions, while long reads improve contiguity.  
- **Coverage depth**: Crucial for assembly accuracy, with HiFi requiring 20-30x, ONT needing 50-100x, and hybrid assemblies depending on short-read support for polishing.  
- **Genome complexity**: Includes repeat content, heterozygosity, and polyploidy, which influence assembly success and determine whether specialized tools or additional scaffolding methods are needed.  
- **Computational resources**: Vary across assembly strategies, with HiFiasm being RAM-intensive, Flye being more lightweight, and hybrid assemblies requiring additional processing for polishing.  
- **Sequencing budget**: Plays a role, as HiFi sequencing is costlier but highly accurate, ONT is cheaper but requires more data for error correction, and hybrid approaches balance cost and quality.  
- **Downstream analyses**: Structural variation detection, gene annotation, or chromosome-level assemblies influence the choice of assembler and the need for scaffolding methods like Hi-C or Bionano OGM.

#### Comparative Assembly Strategies

| Factor                      | PacBio HiFi             | ONT                        | Hybrid (ONT + Illumina)         |
|-----------------------------|-------------------------|----------------------------|---------------------------------|
| **Read length**             | ~15-20kb                | 10-100kb+                   | Mix of short & long            |
| **Read accuracy**           | High (~99%)             | Moderate (~90%)            | High (after polishing)         |
| **Coverage needed**         | 20-30x                  | 50-100x                     | ONT: 50x + Illumina: 30x       |
| **Cost per Gb**             | Expensive               | Lower                       | Medium                         |
| **Error profile**           | Random errors, low indels | Higher error rate, systematic errors | ONT errors corrected by Illumina |
| **Computational requirements** | High RAM required  | Moderate RAM required       | Moderate                       |
| **Best for**                | High-accuracy assemblies | Ultra-long contigs         | Combines advantages of both    |
| **Repeat resolution**       | Good                     | Very good                  | Very good                      |
| **Scaffolding needed**      | Rarely needed           | May be needed               | Sometimes needed               |
| **Polishing required**      | Not required            | Required (Racon + Medaka)   | Required (Pilon)               |
| **Structural variant detection** | Good             | Excellent                   | Good                           |
| **Haplotype phasing**       | Excellent               | Good                        | Moderate                       |
| **Genome size suitability** | Suitable for large and small genomes | Best for large genomes | Best for complex genomes     |
| **Downstream applications** | Reference-quality genome assembly, annotation | Structural variation analysis, de novo assembly | Genome correction, variant calling, scaffolding |

#### **Contig vs. Scaffold vs. Chromosome-Level Assembly**  

Genome assemblies progress through different levels of completeness and organization:  

- **Contig-level assembly**: The raw output of assemblers, consisting of contiguous sequences without known order or orientation. Longer contigs indicate better assembly continuity.  
- **Scaffold-level assembly**: Contigs linked together using additional data (e.g., long-range mate-pair reads, optical maps, or Hi-C). Gaps (represented as ‘N’s) remain where connections exist but sequence information is missing.  
- **Chromosome-level assembly**: The highest-quality assembly, where scaffolds are further ordered and oriented into full chromosomes using genetic maps, Hi-C data, or synteny with a reference genome.  

Higher levels of assembly provide better genome context, but require additional scaffolding methods beyond de novo assembly.

#### Workflow for Various Assemblies

In this workshop, we will use HiFiasm for PacBio HiFi assemblies, Flye for ONT assemblies, and Flye in hybrid mode for ONT + Illumina assemblies, followed by quality assessment using BUSCO and QUAST to evaluate completeness and accuracy.


##### PacBio HiFi Assembly with HiFiasm


- **PacBio HiFi reads**: Highly accurate long reads with low error rates, suitable for de novo assembly without polishing.
- **HiFiasm**: A specialized assembler for HiFi data, leveraging read accuracy and length to resolve complex regions and produce high-quality contigs.
- **Workflow**: Run HiFiasm with HiFi reads, adjust parameters based on genome size and complexity, and evaluate the assembly using Compleasm and QUAST.


![PacBio Assembly](https://github.com/user-attachments/assets/652b2211-f5d1-4264-8b82-cd0925f62408)


##### ONT Assembly with Flye

- **ONT reads**: Ultra-long reads with higher error rates, requiring additional error correction and polishing steps.
- **Flye**: A de novo assembler optimized for long reads, capable of resolving complex repeats and generating high-quality assemblies.
- **Workflow**: Run Flye with ONT reads, adjust parameters based on genome size and complexity, and polish the assembly using Medaka for basecalling and consensus polishing.

![ONT assembly](https://github.com/user-attachments/assets/3dc7bbcc-a875-4d75-8bb7-2b56d82bf5ff)


##### Hybrid (ONT + PacBio) Assembly with Flye

- **Hybrid assembly**: Combines the strengths of both technologies for improved accuracy and contiguity.
- **Workflow**: Run Flye with both ONT and PacBio reads, adjust parameters for hybrid mode, and polish the assembly using ONT or PacBio reads for error correction and consensus polishing.

![Hybrid assembly](https://github.com/user-attachments/assets/f7fae4ec-0a07-4835-8836-20acc99aadb1)


#### Assembly Evaluation 

- Why assessing genome assembly quality is crucial before downstream analyses.  
- Metrics to determine assembly completeness, accuracy, and contiguity.  

##### **1. BUSCO (Benchmarking Universal Single-Copy Orthologs)**  

- Evaluates genome completeness using a conserved set of single-copy orthologs.  
- Reports four categories:
  - **Complete (Single-Copy/Duplicated)**: Genes present and intact.  
  - **Fragmented**: Genes partially recovered but not fully intact.  
  - **Missing**: Genes absent, indicating potential assembly gaps.  
- How to interpret BUSCO scores for genome assemblies.  
- Example BUSCO command and output format.  

##### **2. QUAST (Quality Assessment Tool for Genome Assemblies)**  

- Provides summary statistics such as **N50, L50, number of contigs, GC content, genome size estimates, and misassemblies**.  
- Can compare multiple assemblies to assess improvement with different strategies.  
- Example QUAST command and output interpretation.  

##### **3. Additional Considerations for Evaluation**  

- **K-mer-based methods (e.g., Merqury)** for **comparing assemblies to raw reads** (especially useful when no reference genome is available).  
- **Dot plots and synteny analysis** to visualize structural correctness.  

#### **Bionano and Hi-C Reads in Genome Assembly**  

**Bionano Optical Genome Mapping (OGM)** provides ultra-long, label-based maps of DNA molecules, helping to scaffold contigs, detect misassemblies, and resolve large structural variations. It improves genome continuity by linking fragmented sequences, especially in repeat-rich or complex genomes.  

**Hi-C sequencing** captures chromatin interactions, allowing scaffolding of contigs into chromosome-scale assemblies based on physical proximity in the nucleus. It helps in ordering and orienting scaffolds, identifying misassemblies, and resolving haplotypes, making it essential for generating **chromosome-level genome assemblies**.


::::::::::::::::::::::::::::::::::::: keypoints 

- **Genome assembly** reconstructs complete genome sequences from fragmented DNA reads.
- **De novo** assembly builds genomes without a reference, while **reference-guided** assembly uses existing genomes.
- **Sequencing technologies** like Illumina, PacBio HiFi, and Oxford Nanopore offer different read lengths and error rates.
- **Challenges** include repetitive elements, heterozygosity, and error correction.
- **Tools** many programs are available for data QC, assembly, post-processing, and evaluation - choice depends on data type and research goals.


::::::::::::::::::::::::::::::::::::::::::::::::

