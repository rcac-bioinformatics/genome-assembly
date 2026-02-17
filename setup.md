---
title: Setup
---

## Instructors

1. **Arun Seetharam, Ph.D.**: Arun is a lead bioinformatics scientist at Purdue University’s Rosen Center for Advanced Computing. With extensive expertise in comparative genomics, genome assembly, annotation, single-cell genomics,  NGS data analysis, metagenomics, proteomics, and metabolomics. Arun supports a diverse range of bioinformatics projects across various organisms, including human model systems.



## Schedule

| **Time** | **Session** |
|:---|-------------|
| **9:00 AM** | **Introduction to Genome Assembly** – Sequencing technologies, assembly concepts, and workshop overview |
| **9:30 AM** | **Assembly Strategies** – Comparing approaches, evaluation metrics, and resource planning |
| **9:50 AM** | **Data Quality Control** – NanoPlot, Filtlong, KMC, and GenomeScope2 for read QC |
| **10:30 AM** | **Morning Break** |
| **10:45 AM** | **PacBio HiFi Assembly** – HiFiasm assembly, purge levels, GFA conversion, and Flye for HiFi |
| **12:00 PM** | **Lunch Break** |
| **1:00 PM** | **Oxford Nanopore Assembly** – Flye assembler, Medaka polishing, and HiFiasm for ONT |
| **1:45 PM** | **Hybrid Assembly** – Combining ONT + HiFi reads with Flye, Bionano scaffolding |
| **2:30 PM** | **Afternoon Break** |
| **2:45 PM** | **Scaffolding with Optical Genome Mapping** – Bionano Solve for HiFiasm and Flye assemblies |
| **3:15 PM** | **Assembly Evaluation** – QUAST, Compleasm, Merqury, Bandage, and comparative analysis |
| **3:50 PM** | **Wrap-Up & Discussion** – Summary, Q&A, and next steps |
| **4:00 PM** | **Dismissal** |


## What is not covered

1. Short read assembly
2. Hi-C scaffolding
3. Annotation
4. Comparative analyses

## Pre-requisites

1. Basic knowledge of genomics
2. Basic knowledge of command line interface
3. Basic knowledge of bioinformatics tools



## Data Sets

To copy the data to your scratch space:

```bash
rsync -avP /depot/workshop/data/genome-assembly/genome-assembly-data $RCAC_SCRATCH
```

The worked-out results folder is also available at `/depot/workshop/data/genome-assembly/genome-assembly-data` on the training cluster. Only use this if you are unable to finish the exercises in the workshop.


## Software Setup


::::::::::::::::::::::::::::::::::::::: discussion

### Details

SSH key setup for different systems is detailed in the expandable sections below.

:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: solution

### Windows

Open a terminal and run:

```sh
ssh-keygen -b 4096 -t rsa
type .ssh\id_rsa.pub | ssh trainXX@negishi.rcac.purdue.edu "mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys"
```

:::::::::::::::::::::::::

:::::::::::::::: solution

### MacOS

Open Terminal and run
```sh
ssh-keygen -b 4096 -t rsa
cat .ssh/id_rsa.pub | ssh trainXX@negishi.rcac.purdue.edu "mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys"
```

:::::::::::::::::::::::::


:::::::::::::::: solution

### Linux

Open a terminal and run:
```sh
ssh-keygen -b 4096 -t rsa
cat .ssh/id_rsa.pub | ssh trainXX@negishi.rcac.purdue.edu "mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys"
```

:::::::::::::::::::::::::



