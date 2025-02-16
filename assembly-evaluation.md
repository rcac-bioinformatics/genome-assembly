---
title: 'Assembly Assessment'
teaching: 10
exercises: 2
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
ml compleasm
mkdir -p quast_evaluation
# ln -s ../assembly1.fasta all_assemblies/assembly1.fasta
# ln -s ../assembly2.fasta all_assemblies/assembly2.fasta
# ln -s ../assembly3.fasta all_assemblies/assembly3.fasta
# link any other assemblies you want to compare
# ln -s ../pacbio/9994.q20.CCS-filtered-60x.fastq
# donwload the reference genome
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-60/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
gunzip Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
quast.py \
   --output-dir quast_complete_stats \
   --no-read-stats \
   -r  Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
   --threads ${SLURM_CPUS_ON_NODE} \
   --eukaryote \
   --pacbio 9994.q20.CCS_ge20Kb.fasta \
   assembly1.fasta assembly2.fasta assembly3.fasta
```

This will generate a detailed report in the `quast_complete_stats` directory, including key metrics for each assembly and a summary of their quality. You can use this information to compare different assemblies and select the best one for downstream analysis.


## Compleasm for genome completeness (gene-space)

Similarly, you can use `compleasm` to assess the completeness of your genome assembly in terms of gene-space representation. This tool compares the assembly against a set of conserved genes to estimate the level of completeness and identify missing or fragmented genes.


```bash
ml --force purge
ml biocontainers
ml compleasm
mkdir -p compleasm_evaluation
# ln -s ../assembly1.fasta all_assemblies/assembly1.fasta
# ln -s ../assembly2.fasta all_assemblies/assembly2.fasta
# ln -s ../assembly3.fasta all_assemblies/assembly3.fasta
# link any other assemblies you want to compare
# ln -s ../quast_evaluation/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa # reference
for fasta in *.fasta; do
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
# ln -s ../assembly1.fasta all_assemblies/assembly1.fasta
# ln -s ../assembly2.fasta all_assemblies/assembly2.fasta
# ln -s ../assembly3.fasta all_assemblies/assembly3.fasta
# link any other assemblies you want to compare
# ln -s ../quast_evaluation/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa # reference
# ln -s ../pacbio/9994.q20.CCS-filtered-60x.fastq # pacbio reads
meryl \
   count k=21 \
   threads=${SLURM_CPUS_ON_NODE} \
   memory=8g \
   output 9994.q20.CCS-filtered.meryl\
   9994.q20.CCS-filtered.fastq
merqury \
   -a assembly1.fasta \
   -r 9994.q20.CCS-filtered.meryl \
   -o merqury_evaluation/assembly1
merqury.sh \
   9994.q20.CCS-filtered.meryl 
   assembly1.fasta assembly2.fasta assembly3.fasta
   merqury_evaluation_output
```

This will generate numberous files with `merqury_evaluation_output` prefix, including k-mer spectra, completeness metrics, and consensus quality estimates for each assembly. You can use these results to evaluate the accuracy, completeness, and structural integrity of your genome assemblies.


## Assembly graph visualization using Bandage

Bandage is a tool for visualizing assembly graphs, which represent the connections between contigs or scaffolds in a genome assembly. By visualizing the graph structure, you can identify complex regions, repetitive elements, and potential misassemblies that may affect the genome reconstruction.


To visualize the assembly graph using Bandage:

1. Open a web browser and navigate to [desktop.negishi.rcac.purdue.edu]().
2. Log in with your Purdue Career Account username and password, but append ",push" to your password.
3. Lauch the terminal and run the following command:

```bash
ml --force purge
ml biocontainers
ml bandage
Bandage
```

4. In the Bandage interface, navigate to your assembly folder (hifiasm or flye), and load your assembly graph (e.g., `assembly1.fasta`) .
5. Explore the graph structure, identify complex regions, and visualize connections between contigs or scaffolds.

![Bandage interface](https://github.com/user-attachments/assets/172513cc-d43b-401d-afbe-239d415d12bb)




::::::::::::::::::::::::::::::::::::: keypoints 


- **QUAST** evaluates assembly contiguity and quality metrics.
- **Compleasm** assesses gene-space completeness in genome assemblies.
- **Merqury** provides reference-free evaluation based on k-mer analysis.
- **Bandage** visualizes assembly graphs for structural assessment.

::::::::::::::::::::::::::::::::::::::::::::::::


