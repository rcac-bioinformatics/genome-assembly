---
title: 'Assembly Assessment'
teaching: 20
exercises: 30
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why is evaluating genome assembly quality important?
- What tools can be used to assess assembly completeness, accuracy, and structural integrity?
- How do you interpret key metrics from assembly evaluation tools?
- What are the main steps in evaluating a genome assembly using bioinformatics tools?



::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Understand the importance of evaluating genome assembly quality.
- Learn about tools for assessing assembly completeness, accuracy, and structural integrity.
- Interpret key metrics from assembly evaluation tools to guide further analysis.
- Evaluate a genome assembly using bioinformatics tools such as QUAST, Compleasm, Merqury, and Bandage.

::::::::::::::::::::::::::::::::::::::::::::::::

## Evaluating Assembly Quality  

Assessing genome assembly quality is essential to ensure completeness, accuracy, and structural integrity before downstream analyses. Different tools provide complementary insights—**QUAST** evaluates assembly contiguity, **Compleasm** assesses gene-space completeness, **Merqury** validates k-mer consistency, and **Bandage** visualizes assembly graphs for structural assessment. Together, these methods help identify errors, improve genome reconstruction, and ensure high-quality results.  

**Why is Assembly Evaluation Important?**  

- **Detects misassemblies and structural errors**: Identifies fragmented, misjoined, or incorrectly placed contigs that can impact genome interpretation.  
- **Measures completeness and accuracy**: Ensures that essential genes and expected genome regions are properly assembled and not missing or duplicated.  
- **Validates sequencing data quality**: Confirms whether sequencing errors, biases, or artifacts affect the final assembly.  
- **Guides further refinement**: Helps decide whether additional polishing, scaffolding, or reassembly is needed for better genome reconstruction.  


## Quast for quality metrics

You can run `quast` to evaluate the quality of your genome assembly. It is also useful for comparing multiple assemblies to identify the best one based on key metrics such as contig count, N50, and misassemblies.


```bash
ml --force purge
ml biocontainers
ml quast
mkdir -p quast_evaluation
# Link your assemblies to a common directory for comparison
mkdir -p all_assemblies
ln -s ../hifiasm_default/At_hifiasm_default.asm.bp.p_ctg.fasta all_assemblies/hifiasm_assembly.fasta
ln -s ../flye_ont/assembly.fasta all_assemblies/flye_ont_assembly.fasta
# link any other assemblies you want to compare (e.g., hybrid, scaffolded)
# Download the reference genome
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-60/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
gunzip Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
quast.py \
   --output-dir quast_complete_stats \
   --no-read-stats \
   -r Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
   --threads ${SLURM_CPUS_ON_NODE} \
   --eukaryote \
   --pacbio At_pacbio-hifi-filtered.fastq \
   all_assemblies/*.fasta
```

This will generate a detailed report in the `quast_complete_stats` directory, including key metrics for each assembly and a summary of their quality. You can use this information to compare different assemblies and select the best one for downstream analysis.


## Compleasm for genome completeness (gene-space)

Similarly, you can use `compleasm` to assess the completeness of your genome assembly in terms of gene-space representation. This tool compares the assembly against a set of conserved genes to estimate the level of completeness and identify missing or fragmented genes.


```bash
ml --force purge
ml biocontainers
ml compleasm
mkdir -p compleasm_evaluation
cd compleasm_evaluation
# Use the same assemblies linked in the all_assemblies directory
for fasta in ../all_assemblies/*.fasta; do
  compleasm run \
    -a ${fasta} \
    -o ${fasta%.*}_out \
    -l brassicales_odb10  \
    -t ${SLURM_CPUS_ON_NODE}
done
```

This will generate a detailed report for each assembly in the  directory, highlighting the completeness of conserved genes and potential gaps in the genome reconstruction.
The assessment result by compleasm is saved in the file `summary.txt` in the `compleasm_evaluation/assemblyN_out` (specified in output `-o` option) folder. These BUSCO genes are categorized into the following classes:

- `S` (Single Copy Complete Genes): The BUSCO genes that can be entirely aligned in the assembly, with only one copy present.
- `D` (Duplicated Complete Genes): The BUSCO genes that can be completely aligned in the assembly, with more than one copy present.
- `F` (Fragmented Genes, subclass 1): The BUSCO genes which only a portion of the gene is present in the assembly, and the rest of the gene cannot be aligned.
- `I` (Fragmented Genes, subclass 2): The BUSCO genes in which a section of the gene aligns to one position in the assembly, while the remaining part aligns to another position.
- `M` (Missing Genes): The BUSCO genes with no alignment present in the assembly.


## Merqury for evaluating genome assembly

Merqury is a tool for reference-free assembly evaluation based on efficient k-mer set operations. It provides insights into various aspects of genome assembly, offering a comprehensive view of genome quality without relying on a reference sequence. Specifically, Merqury can generate the following plots and metrics:

- **Copy Number Spectrum (Spectra-cn Plot):**  
  - A **k-mer-based analysis** that detects heterozygosity levels and genome repeats by identifying peaks in k-mer coverage.  
  - Helps estimate genome size, detect missing regions, and distinguish between homozygous and heterozygous k-mers in an assembly.  

- **Assembly Spectrum (Spectra-asm Plot):**  
  - Compares k-mers between different assemblies or between an assembly and raw sequencing reads.  
  - Useful for detecting missing sequences, shared regions, and assembly-specific k-mers that may indicate errors or haplotype-specific variations.  

- **K-mer Completeness:**  
  - Measures how many **reliable k-mers** (those likely to be real and not sequencing errors) are present in both the sequencing reads and the assembly.  
  - Helps identify missing regions, misassemblies, and sequencing biases affecting genome reconstruction.  

- **Consensus Quality (QV) Estimation:**  
  - Uses **k-mer agreement between the assembly and the read set** to estimate base-level accuracy.  
  - Higher QV scores indicate a more accurate consensus sequence, but results depend on read quality and coverage depth.  

- **Misassembly Detection with K-mer Positioning:**  
  - Identifies **unexpected k-mers** or **false duplications** in assemblies, reporting their positions in `.bed` and `.tdf` files for visualization in genome browsers.  
  - Helps pinpoint structural errors such as collapsed repeats, chimeric joins, or large insertions/deletions.  

This **k-mer-based approach** in Merqury provides **reference-free genome quality evaluation**, making it highly effective for **de novo assemblies and structural validation**.


```bash
ml --force purge
ml biocontainers
ml merqury
ml meryl
mkdir -p merqury_evaluation
cd merqury_evaluation
# Step 1: Build a meryl k-mer database from the reads
meryl \
   count k=21 \
   threads=${SLURM_CPUS_ON_NODE} \
   memory=8g \
   output At_pacbio-hifi-filtered.meryl \
   ../At_pacbio-hifi-filtered.fastq
# Step 2: Run merqury to evaluate assemblies
# Syntax: merqury.sh <read-db.meryl> <asm1.fasta> [asm2.fasta] <output_prefix>
# For a single assembly:
merqury.sh \
   At_pacbio-hifi-filtered.meryl \
   ../hifiasm_default/At_hifiasm_default.asm.bp.p_ctg.fasta \
   merqury_hifiasm
# For comparing multiple assemblies:
merqury.sh \
   At_pacbio-hifi-filtered.meryl \
   ../hifiasm_default/At_hifiasm_default.asm.bp.p_ctg.fasta \
   ../flye_ont/assembly.fasta \
   merqury_comparison
```

::: callout

## Merqury syntax

Note that `merqury.sh` uses **positional arguments** (not flags):

```
merqury.sh <read-db.meryl> <assembly1.fasta> [assembly2.fasta] <output_prefix>
```

The output prefix determines the names of all generated files. When comparing two assemblies, provide both FASTA files before the output prefix.

:::

This will generate numerous files with the specified output prefix, including k-mer spectra plots, completeness metrics, and consensus quality (QV) estimates for each assembly. You can use these results to evaluate the accuracy, completeness, and structural integrity of your genome assemblies.


## Assembly graph visualization using Bandage

Bandage is a tool for visualizing assembly graphs, which represent the connections between contigs or scaffolds in a genome assembly. By visualizing the graph structure, you can identify complex regions, repetitive elements, and potential misassemblies that may affect the genome reconstruction.


To visualize the assembly graph using Bandage:

1. Open a web browser and navigate to [desktop.negishi.rcac.purdue.edu]().
2. Log in with your Purdue Career Account username and password, but append ",push" to your password.
3. Launch the terminal and run the following command:

```bash
ml --force purge
ml biocontainers
ml bandage
Bandage
```

4. In the Bandage interface, navigate to your assembly folder and load your assembly graph in GFA format (e.g., `At_hifiasm_default.asm.bp.p_ctg.gfa` for hifiasm, or `assembly_graph.gfa` for Flye).
5. Explore the graph structure, identify complex regions, and visualize connections between contigs or scaffolds.

::: callout

## Bandage input format

Bandage requires assembly **graph** files (`.gfa` format), not FASTA files. HiFiasm outputs `.gfa` files directly, while Flye produces `assembly_graph.gfa` in its output directory.

:::

![Bandage interface](https://github.com/user-attachments/assets/172513cc-d43b-401d-afbe-239d415d12bb)




## Unified Assembly Comparison

After running all evaluation tools, compile your results into a summary table to compare assemblies side by side:

| Metric | HiFiasm (HiFi) | Flye (ONT) | Hybrid (Flye) | HiFiasm + Bionano | Flye + Bionano |
|--------|----------------|------------|----------------|-------------------|----------------|
| # Contigs | | | | | |
| Total size (Mb) | | | | | |
| N50 (Mb) | | | | | |
| L50 | | | | | |
| BUSCO Complete (%) | | | | | |
| BUSCO Duplicated (%) | | | | | |
| Merqury QV | | | | | |
| K-mer completeness (%) | | | | | |

::: callout

## Interpreting your results

When comparing assemblies, consider these questions:

1. Which assembly has the highest N50 and lowest number of contigs?
2. Which assembly has the best BUSCO completeness?
3. How do the Merqury QV scores compare? (Higher QV = fewer base-level errors)
4. Did Bionano scaffolding improve contiguity (N50) compared to the unscaffolded assemblies?
5. Is the total assembly size close to the expected genome size (~135 Mb for _A. thaliana_)?

Fill in the table above with your actual results and discuss which assembly strategy produced the best outcome for this dataset.

:::

::::::::::::::::::::::::::::::::::::: keypoints


- **QUAST** evaluates assembly contiguity and quality metrics.
- **Compleasm** assesses gene-space completeness in genome assemblies.
- **Merqury** provides reference-free evaluation based on k-mer analysis.
- **Bandage** visualizes assembly graphs for structural assessment.

::::::::::::::::::::::::::::::::::::::::::::::::


