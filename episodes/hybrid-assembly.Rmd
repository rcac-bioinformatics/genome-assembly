---
title: 'Hybrid Long Read Assembly (optional)'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- to do


::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- to do

::::::::::::::::::::::::::::::::::::::::::::::::

### Flye for Hybrid Assembly

For hybrid assembly using `flye`, first, run the pipeline with all your reads in the --pacbio-raw mode (you can specify multiple files, no need to merge all you reads into one). Also add --iterations 0 to stop the pipeline before polishing.
Once the assembly finishes, run polishing using either PacBio or ONT reads only. Use the same assembly options, but add --resume-from polishing.
Here is an example of a script that should do the job:

```bash
ml --force purge
ml biocontainers
ml flye
PBREADS="9994.q20.CCS-filtered-60x.fastq"
ONTREADS="basecalled_2025-02-12-filtered_60x.fastq"

flye \
    --pacbio-raw $PBREADS $ONTREADS \
    --iterations 0 \
    --out-dir hybrid_flye_out \
    --genome-size 135m \
    --threads ${SLURM_CPUS_ON_NODE}
flye \
   --pacbio-raw $PBREADS \
   --resume-from polishing \
   --out-dir hybrid_flye_out  \
   --genome-size 135m \
   --threads ${SLURM_CPUS_ON_NODE}
```


### Evaluating Assembly Quality

### Common Issues and Troubleshooting

### Further Reading and Additional Resources




::::::::::::::::::::::::::::::::::::: keypoints 


- point 1
- point 2
- point 3

::::::::::::::::::::::::::::::::::::::::::::::::



