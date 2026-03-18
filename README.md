# For RNA-seq analysis

RNAseq analysis pipeline for analysis of Illumina short-read paired-end sequencing data from *Candida auris* modified from **Jenull mBio (2022)** which was established by [Michael Tscherner](https://github.com/kakulab/RNAseq_analysis_Cauris). This script is used in the Kuchler lab (http://cdl.univie.ac.at/) at Max Perutz Labs Vienna ([https://www.mfpl.ac.at/de.html](https://www.maxperutzlabs.ac.at/)).

## Purpose of Forking
This repository was forked to modernize and extend the RNA-seq analysis pipeline for *Candida auris*, specifically to replicate and verify the findings of the GSE272878 dataset regarding the evolution of 5-Fluorocytosine (5FC) resistance. The fork provides a comprehensive, reproducible framework for downstream differential expression and functional analysis.

## Changes made to this repo
- **Refactored DGE Analysis Pipeline**: Implemented a modern `edgeR` and `tidyverse`-based downstream analysis suite in `for_RNA_seq/diff_expr_GSE272878/` for processing Illumina short-read data.
- **Enhanced Orthology Mapping**: Developed a robust orthology generation workflow using `finalize_ortho.py` and BLAST+ (`run_blast.sh`) to map *C. auris* B8441 genes to *C. albicans* SC5314 orthologs (`Ortho_v2.csv`).
- **Reference Genome V2 Support**: Integrated the *C. auris* B8441 V2 assembly (`GCA_002759435.2`) and implemented automated locus tag reconciliation (mapping `B9J08_` to `CJI97_`) for compatibility with legacy databases.
- **Custom Annotation Database**: Generated a custom Bioconductor `OrgDb` package (`org.Calbicans.Eupath.v68.eg.db`) using FungiDB-68 to enable high-resolution GO enrichment analysis.
- **Automated Results & Visualization**: Added comprehensive plotting scripts for generating PCA (using `ggbiplot`), Volcano, Smear, and Heatmap visualizations, as well as GO enrichment plots.
- **Verification of 5FC Resistance**: Confirmed that resistance in GSE272878 clones is driven by non-synonymous mutations in *FUR1* and *FCY2*, rather than transcriptional changes, as documented in `REPLICATION_SUMMARY.md`.
- **Project Structure Optimization**: Reorganized the repository for better data provenance, including raw counts, targets metadata, and a clear `TODO.md` for project tracking.

*C. auris* genome sequence and annotation file (obtained from Candida Genome Database) are provided. For the current version, see CGD.

## Tools required for analysis:

samtools (http://www.htslib.org/)

FastQC (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

MultiQC (https://multiqc.info/)

cutadapt (https://cutadapt.readthedocs.io/en/stable/)

NextGenMap (https://github.com/Cibiv/NextGenMap/wiki)

DeepTools (https://deeptools.readthedocs.io/en/develop/)

HTSeq (https://htseq.readthedocs.io/en/)

All the above-mentioned tools have to be included in your PATH environment.

## Usage:

Clone the repository by typing "git clone https://github.com/kakulab/CSP2024.git" and copy the raw data into the RNAseq_analysis directory.

Clone the repository and add the read files in the base directory.

Change the adapter sequence for read trimming in the `analysis_script.sh` file if necessary. By default, it contains the Illumina TrueSeq adapter.

Change into the required_files directory and run the analysis script (by typing: `bash analysis_script.sh`).

After the pipeline has finished, change into the diff_expr_analysis directory and use the `edgeR_analysis.R` script as a basis for differential expression analysis in R.

# For functional analysis in R
We utilized AnnotationForge to generate a GO database of *C. albicans* in a format compatible with BioConductor. Subsequently, we utilized the data available at http://www.candidagenome.org/download/homology/ to map gene IDs between *C. albicans* and *C. auris*. All functional analyses were performed using *C. albicans* GIDs. 
Please find example script for AnnotationForge in the file: `to_generate_C.albicansOrgDB.R`
