---
title: Setup
---

## Instructors

1. **Arun Seetharaman, Ph.D.**: Arun is a lead bioinformatics scientist at Purdue University’s Rosen Center for Advanced Computing. With extensive expertise in comparative genomics, genome assembly, annotation, single-cell genomics,  NGS data analysis, metagenomics, proteomics, and metabolomics. Arun supports a diverse range of bioinformatics projects across various organisms, including human model systems.

2. **Charles Christoffer, Ph.D.**: Charles is a Senior Computational Scientist at Purdue University’s Rosen Center for Advanced Computing. He has a Ph.D. in Computer Science in the area of structural bioinformatics and has extensive experience in protein structure prediction. 


## Schedule

| **Time**  | **Session**  |
|:---|-------------|
| **8:30 AM** | Arrival & Setup  |
| **9:00 AM** | **Introduction & UNIX/HPC refresher** – Cluster setup and essential UNIX commands for assembly workflows |
| **10:30 AM** | **Break** |
| **10:40 AM** | **Introduction to Genome Assembly** – Overview of long-read assembly strategies, challenges, and tools  |
| **11:00 AM** | **Genome Assembly with HiFiasm/Flye** – Running HiFiasm on **RCAC clusters**, parameter selection, and best practices  |
| **12:00 PM** | **Lunch Break** |
| **1:00 PM** | **Hybrid Assembly (ONT + PacBio) and scaffolding** – Combining long-read technologies for improved assembly accuracy, and scaffolding with **Bionano optical maps** |
| **2:50 PM** | **Break** |
| **3:10 PM** | **Assembly Evaluation & Visualization** – QC metrics, polishing |
| **4:30 PM** | **Wrap-Up & Discussion** – Troubleshooting, Q&A, and next steps |


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

To copy only data:

```bash
rsync -avP /depot/workshop/data/genome-assembly/genome-assembly-data $RCAC_SCRATCH
```

The worked out folder is available at `/depot/workshop/data/genome-assembly/genome-assembly-data` on the training cluster. You can copy the data to your scratch space using the following command:

```bash
rsync -avP /depot/workshop/data/genome-assembly/genome-assembly-data $RCAC_SCRATCH
```

Only use this if you are unable to finish the exercises in the workshop.


## Software Setup


::::::::::::::::::::::::::::::::::::::: discussion

### Details

Setup for different systems can be presented in dropdown menus via a `solution`
tag. They will join to this discussion block, so you can give a general overview
of the software used in this lesson here and fill out the individual operating
systems (and potentially add more, e.g. online setup) in the solutions blocks.

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



