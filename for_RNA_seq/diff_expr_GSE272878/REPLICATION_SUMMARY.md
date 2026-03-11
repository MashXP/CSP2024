# RNA-seq Downstream Analysis Summary: GSE272878 Replication

## 1. Objective
This document summarizes the downstream differential gene expression (DGE) analysis of *Candida auris* RNA-seq data (GSE272878), replicating and verifying the findings related to 5-Fluorocytosine (5FC) resistance.

## 2. Experimental Setup & Metadata
The analysis was performed using the `edgeR` package in R, comparing four derivative strains against a Wild-Type (WT) control.

| Accession (GSM) | Sample Name | Strain Category | Metadata Description | PCA Color |
| :--- | :--- | :--- | :--- | :--- |
| 8413969-971 | S4, S5, S6 | **WT** | Wild-Type control | Green |
| 8413972-974 | F1, F2, F3 | **R1** | 5FC resistant clone | Red |
| 8413975-977 | F4, F5, F6 | **S1** | 5FC susceptible clone | Blue |
| 8413978-980 | F7, F8, F9 | **R2** | 5FC resistant clone | Magenta |
| 8413981-983 | F10, F11, F12 | **I1** | 5FC derivative clone | Purple |

### 3. Genomic Locus Tag Reconciliation
A technical challenge was encountered due to a version mismatch between the genomic reference used for read quantification and the database used for ortholog mapping.

- **Quantification Reference (B8441 V2 / GCA_002759435.2):** The RNA-seq counts utilized the updated assembly version, which employs the `B9J08_` locus tag prefix (e.g., `B9J08_002435`).
- **Annotation Resource (B8441 V1 / GCA_002759435.1):** The ortholog dictionary (`Ortho.xlsx`) was indexed using the legacy `CJI97_` locus tag prefix.
- **Mapping Strategy:** Validation against known resistance drivers (*FUR1*, *FCY2*) confirmed a 1:1 numeric suffix conservation between the V1 and V2 assemblies. To reconcile these datasets, a systematic identifier translation was implemented in the R pipeline, substituting the `B9J08_` prefix with `CJI97_` to enable successful joins with the orthology and annotation databases.

## 4. Verification of Consistency
The replication was verified against the research paper ("Rapid in vitro evolution of flucytosine resistance in *Candida auris*") by checking the primary resistance drivers:

### Key Gene Mapping
| Gene | B9J08 ID (Data) | CJI97 ID (Map) | C. albicans Ortholog | Status |
| :--- | :--- | :--- | :--- | :--- |
| **FUR1** | `B9J08_004144` | `CJI97_004144` | `orf19.2640` | **Verified** |
| **FCY2** | `B9J08_002435` | `CJI97_002435` | `orf19.1573` | **Verified** |

### Expression vs. Mutation
Consistency check confirmed that **FUR1** and **FCY2** did not show significant differential expression (LogFC ≈ 0, FDR > 0.05) in resistant strains. This aligns perfectly with the paper’s conclusion that resistance in these clones is driven by **non-synonymous mutations (SNPs/Indels)** rather than transcriptional upregulation/downregulation.

## 5. PCA Analysis
The Principal Component Analysis (PCA) was updated to match the paper's visualization standards:
- **PC1:** 28.2% explained variance.
- **PC2:** 22.5% explained variance.
- **Clustering:** Samples grouped tightly by biological replicates, with distinct separation between the WT and derivative strains.

## 6. SNP/Variant Calling
Verified that SNP calling has been performed using the GATK-based pipeline.
- **Location:** Results found in `5FC-Evo-2024/SNP_annotation/filtered/`.
- **Findings:** Confirmed functional mutations in *FUR1* (R214T in R1, Q30* truncation in R2) and *FCY2* (as detailed in Table 1 of the paper).

## 7. GO Enrichment Analysis
Replicated the GO enrichment analysis for the **I1 vs S1** contrast using `clusterProfiler`.
- **Database:** Created a custom *C. albicans* OrgDB (`org.Calbicans.Eupath.v68.eg.db`) using the latest FungiDB-68 annotation.
- **Results:** 
    - **Upregulated terms:** Linked to the "plasma membrane" (GO:0005886) and "cell surface" (GO:0009986).
    - **Downregulated terms:** Associated with "vesicle" (GO:0031982), "vacuole" (GO:0005773), and "endosome" (GO:0005768).

## 8. Verification Status
1. **[DONE]** Genomic Locus Tag Reconciliation.
2. **[DONE]** DGE Analysis (Verified *FUR1*/*FCY2* expression).
3. **[DONE]** PCA Visualization (Correct variance and colors).
4. **[DONE]** SNP/Variant Calling Verification.
5. **[DONE]** GO Enrichment Analysis (I1 vs S1 contrast).

## 9. Output Files
All results are located in `CSP2024/for_RNA_seq/diff_expr_GSE272878/`:
- `I1_vs_S1_results_wNames.tsv`: DGE results including *C. albicans* orthologs.
- `GO_enrichment_I1_vs_S1.pdf`: Visual plots (dotplot/barplot).
- `GO_UP_I1_vs_S1.tsv` / `GO_DOWN_I1_vs_S1.tsv`: Tabular results.
- `*_vs_WT_results_wNames.tsv`: Detailed DGE tables with gene symbols and orthologs.
- `all_results.xlsx`: Consolidated results for all comparisons.
- `PCA.pdf`: Visual representation of sample relationships.
- `smear_*.pdf` & `volcano_*.pdf`: Statistical visualization of gene changes.
- `analysis.R`: The exact code used for this replication.
