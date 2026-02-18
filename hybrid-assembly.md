---
title: 'Hybrid Long Read Assembly (optional)'
teaching: 15
exercises: 30
---

:::::::::::::::::::::::::::::::::::::: questions 

- What is hybrid assembly, and how does it combine different sequencing technologies?
- How can you perform hybrid assembly using both types of long-read data?
- What are the key steps in hybrid assembly, including polishing and scaffolding?
- How do you evaluate the quality of a hybrid assembly using bioinformatics tools?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Understand the concept of hybrid assembly and its advantages in genome sequencing.
- Learn how to perform hybrid assembly using long-read sequencing data from PacBio and ONT platforms.
- Explore the key steps involved in hybrid assembly, including polishing and scaffolding.
- Evaluate the quality of a hybrid assembly using bioinformatics tools such as QUAST and Compleasm.

::::::::::::::::::::::::::::::::::::::::::::::::

## Flye for Hybrid Assembly

For hybrid assembly using `flye`, first, run the pipeline with all your reads in the --pacbio-raw mode (you can specify multiple files, no need to merge all you reads into one). Also add --iterations 0 to stop the pipeline before polishing.
Once the assembly finishes, run polishing using either PacBio or ONT reads only. Use the same assembly options, but add --resume-from polishing.
Here is an example of a script that should do the job:

```bash
ml --force purge
ml biocontainers
ml flye
# reads
PBREADS="../01_data-qc/At_pacbio-hifi-filtered.fastq"
ONTREADS="../01_data-qc/At_ont-reads-filtered.fastq"
# round 1
flye \
    --pacbio-raw $PBREADS $ONTREADS \
    --iterations 0 \
    --out-dir hybrid_flye_out \
    --genome-size 135m \
    --threads ${SLURM_CPUS_PER_TASK}
# round 2
flye \
   --pacbio-raw $PBREADS \
   --resume-from polishing \
   --out-dir hybrid_flye_out  \
   --genome-size 135m \
   --threads ${SLURM_CPUS_PER_TASK}

```

::: callout

## While you wait

The hybrid Flye assembly involves two rounds and may take 45-60 minutes total. While you wait, you can:

- Review your previous HiFiasm and Flye assemblies and compare their statistics
- Think about what advantages combining both data types might provide
- Discuss with your neighbor: when would a hybrid assembly approach be preferred over single-technology assembly?

:::


## Evaluating Assembly Quality

For quick evaluation, we will run `quast` and `compleasm` on the hybrid assembly output.

```bash
ml --force purge
ml biocontainers
ml quast
ml compleasm
fasta="hybrid_flye_out/assembly.fasta"
quast.py \
  --fast \
  --threads ${SLURM_CPUS_PER_TASK} \
  -o quast_basic \
    ${fasta}
compleasm run \
   -a ${fasta} \
   -o compleasm_out \
   -l brassicales_odb10  \
   -t ${SLURM_CPUS_PER_TASK}
```

:::::::::::::::::::::::::::::::::::::::::: spoiler

### Expected hybrid assembly results

**QUAST results**

| Metric | Hybrid Flye |
|--------|------------:|
| # Contigs | 336 |
| Largest contig (Mb) | 10.25 |
| Total length (Mb) | 121.11 |
| N50 (Mb) | 4.06 |
| L50 | 9 |
| auN (Mb) | 4.58 |
| N90 (Mb) | 0.16 |
| # N's per 100 kbp | 0.00 |

**Compleasm results (brassicales_odb10)**

| Category | Value |
|----------|------:|
| Single (S) | 98.50% |
| Duplicated (D) | 1.41% |
| Fragmented (F) | 0.02% |
| Missing (M) | 0.07% |

The hybrid assembly has more contigs (336) and a smaller total size (121.11 Mb) than either single-technology assembly, with a lower N50 (4.06 Mb). This is because the `--pacbio-raw` mode treats all reads as error-prone, which is suboptimal for HiFi reads. However, BUSCO completeness is excellent (98.50% single-copy). The Bionano scaffolding step will significantly improve contiguity.

::::::::::::::::::::::::::::::::::::::::::::::::::

## Scaffolding with Bionano


To scaffold the assembly using Bionano data, we will use the `bionano solve`. We can run the following script to scaffold the assembly:


```bash
ml --force purge
export PATH=$PATH:/apps/biocontainers/exported-wrappers/bionano/3.8.0
fasta="hybrid_flye_out/assembly.fasta"
run_hybridscaffold.sh \
  -c /opt/Solve3.7_10192021_74_1/HybridScaffold/1.0/hybridScaffold_DLE1_config.xml\
  -b ../05_scaffolding/Evry.OpticalMap.Col-0.cmap \
  -n ${fasta} \
  -u CTTAAG \
  -z results_bionano_hybrid_scaffolding.zip \
  -w log.txt \
  -B 2 \
  -N 2 \
  -g \
  -f \
  -r /opt/Solve3.7_10192021_74_1/RefAligner/1.0/sse/RefAligner \
  -p /opt/Solve3.7_10192021_74_1/Pipeline/1.0 \
  -o bionano_hybrid_scaffolding
```

Once this completes, you can generate the final scaffold-level assembly by merging placed and unplaced contigs in the `bionano_hybrid_scaffolding/hybrid_scaffolds` directory.


```bash
cd bionano_hybrid_scaffolding/hybrid_scaffolds
cat *HYBRID_SCAFFOLD_NCBI.fasta *HYBRID_SCAFFOLD_NOT_SCAFFOLDED.fasta \
   > ../../assembly_scaffolds.fasta
cd ../..
```

You can evaluate the final assembly using `quast` and `compleasm` as before.

```bash
ml --force purge
ml biocontainers
ml quast
ml compleasm
fasta="assembly_scaffolds.fasta"
quast.py \
  --fast \
  --threads ${SLURM_CPUS_PER_TASK} \
  -o quast_scaffolds \
    ${fasta}
compleasm run \
   -a ${fasta} \
   -o compleasm_scaffolds_out \
   -l brassicales_odb10  \
   -t ${SLURM_CPUS_PER_TASK}
```

:::::::::::::::::::::::::::::::::::::::::: spoiler

### Expected scaffolded hybrid assembly results

**QUAST results (after Bionano scaffolding)**

| Metric | Before scaffolding | After scaffolding |
|--------|-------------------:|------------------:|
| # Sequences | 336 | 310 |
| Total length (Mb) | 121.11 | 133.07 |
| N50 (Mb) | 4.06 | 14.14 |
| L50 | 9 | 5 |
| Largest sequence (Mb) | 10.25 | 15.77 |
| # N's per 100 kbp | 0.00 | 8,976.53 |

**Compleasm results (after scaffolding)**

| Category | Before | After |
|----------|-------:|------:|
| Single (S) | 98.50% | 98.48% |
| Duplicated (D) | 1.41% | 1.44% |
| Missing (M) | 0.07% | 0.07% |

Bionano scaffolding dramatically improved N50 from 4.06 Mb to 14.14 Mb and increased total length from 121 Mb to 133 Mb (closer to expected ~135 Mb) by incorporating previously unplaced sequence into scaffolds. The scaffold gaps (N's) are expected. BUSCO scores remain virtually unchanged.

::::::::::::::::::::::::::::::::::::::::::::::::::

## Hybrid Assembly Summary

In this section you have learned how to perform a hybrid assembly using Flye, polish the assembly, scaffold it using Bionano, and evaluate the final assembly quality. This workflow combines the advantages of ONT and PacBio sequencing, improves structural accuracy with Bionano scaffolding, and ensures a high-quality genome assembly. The steps involved are:

1. **Run Hybrid Assembly with Flye**  
   - Use **Flye** in `--pacbio-raw` mode to assemble both PacBio and ONT reads.  
   - Set `--iterations 0` to stop before polishing.  

2. **Polishing the Assembly**  
   - Polish the assembly using **either PacBio or ONT reads** by resuming Flye with `--resume-from polishing`.  

3. **Evaluate Assembly Quality**  
   - Run **QUAST** for basic assembly metrics (contig count, N50, genome size, misassemblies).  
   - Use **Compleasm** to assess genome completeness based on conserved single-copy genes.  

4. **Scaffold Assembly with Bionano Optical Mapping**  
   - Use **Bionano Solve** to integrate optical maps and scaffold the assembly.  
   - Run `run_hybridscaffold.sh` with the reference `.cmap` optical map file.  

5. **Generate Final Scaffold-Level Assembly**  
   - Merge placed and unplaced contigs from the Bionano scaffolding output to create the final genome assembly.  

6. **Final Evaluation of Scaffolds**  
   - Re-run **QUAST and Compleasm** to validate improvements and ensure genome completeness after scaffolding.  


::::::::::::::::::::::::::::::::::::: keypoints 


- Hybrid assembly with Flye combines ONT and PacBio reads to leverage long-read continuity and high-accuracy sequencing, with separate polishing steps to refine base-level errors.  
- Assembly quality assessment using QUAST and Compleasm provides critical insights into contiguity, completeness, and potential misassemblies, ensuring reliability before scaffolding.  
- Bionano Optical Genome Mapping (OGM) improves hybrid assemblies by scaffolding contigs, resolving misassemblies, and enhancing genome continuity, leading to chromosome-scale assemblies.
- Final scaffolding validation and quality assessment ensure the integrity of the genome assembly, with QUAST and Compleasm used to confirm improvements after Bionano integration.  

::::::::::::::::::::::::::::::::::::::::::::::::



