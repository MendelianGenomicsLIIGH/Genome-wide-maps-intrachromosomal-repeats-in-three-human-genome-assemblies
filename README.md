# Genome-wide maps of highly similar intrachromosomal repeats that mediate ectopic recombination in three human genome assemblies

Here, you will find the **code** necessary to reproduce the analyses and the **data** from our paper: [**Genome-wide maps of highly-similar intrachromosomal repeats that mediate ectopic recombination in three human genome assemblies**](https://www.biorxiv.org/content/10.1101/2024.01.29.577884v1).


We explored direct and inverted repeats in three human genome assemblies—**GRCh37**, **GRCh38**, and **T2T-CHM13**—to understand their role in mediating ectopic recombination and structural rearrangements. This repository is organized into two main sections: 

1. **Code**: Scripts and pipelines for repeat detection and analysis.  
2. **Data**: Resulting datasets in BED file format, compatible with the UCSC Genome Browser.

---


## Key Features of This Repository

- **Direct and Inverted Repeat Detection**:  
  Using **LastZ**, we identified highly similar direct and inverted repeats across genome assemblies.  
- **Repeat Consolidation Algorithm**:  
  A custom algorithm consolidates overlapping or closely spaced repeats while retaining high sequence identity (≥80%).  
- **Accessible Outputs**:  
  Processed outputs are available in BED format, enabling easy visualization and downstream analysis.

---

## Getting Started

### 1. **Run LastZ**

[LastZ](https://www.bx.psu.edu/~rsharris/lastz/) is a sequence alignment tool optimized for large genomes. This study implemented **LastZ_32** feature to handle whole genome sequence comparison.  
The scripts for running LastZ with parameters optimized for this study are available in the [**Code** section](https://github.com/MendelianGenomicsLIIGH/Genome-wide-maps-intrachromosomal-repeats-in-three-human-genome-assemblies/tree/main/code).

#### Important:
- Refer to the [LastZ manual](https://www.bx.psu.edu/~rsharris/lastz/README.lastz-1.04.15.html#adv_whole_genome) for detailed parameter descriptions.  
- LastZ outputs can be customized using the `--format` option to fit downstream requirements.

---

### 2. **Modify LastZ Output**

The raw output from LastZ must be reformatted for further analysis. The script **`Modify_lastz_output.R`** processes the alignment data, preparing it for repeat consolidation and annotation.  

---

### 3. **Consolidate Direct and Inverted Repeats**

Due to LastZ’s reporting behavior, multiple alignments with slightly different boundaries may be reported as separate pairs. To address this:  
- We developed **`consolidation.R`**, which consolidates overlapping or nearby repeats while ensuring sequence identity remains ≥80%.  

This step refines the dataset and enhances the accuracy of downstream analyses.  

---

### 4. **Generate BED Files**

The final consolidated datasets are formatted into **BED files** for visualization in genome browsers such as UCSC.  
- Use the script **`2Bed.R`** to generate BED files directly from the consolidated outputs.

---

## Accessing Data

The [**Data** section](https://github.com/MendelianGenomicsLIIGH/Genome-wide-maps-intrachromosomal-repeats-in-three-human-genome-assemblies/tree/main/data) contains the resulting BED files for direct and inverted repeats in **GRCh37**, **GRCh38**, and **T2T-CHM13**. These files can be loaded directly into the UCSC Genome Browser for visualization and further exploration.

---

## Citation

If you use this repository or its components in your research, please cite our preprint:  
> *Genome-wide maps of highly similar intrachromosomal repeats that mediate ectopic recombination in three human genome assemblies*  
> [DOI: 10.1101/2024.01.29.577884v1](https://www.biorxiv.org/content/10.1101/2024.01.29.577884v1)


This repository provides a comprehensive framework for detecting and analyzing repetitive sequences, contributing to a deeper understanding of genome dynamics and structural variation. For any questions or issues, feel free to open an issue or contact us via GitHub.

