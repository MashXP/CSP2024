---
marp: true
theme: default
paginate: true
backgroundColor: #f0f7fe
color: #333
style: |
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }
  h1 {
    color: #2c3e50;
  }
  h2 {
    color: #34495e;
    border-bottom: 2px solid #3498db;
    padding-bottom: 10px;
  }
  code {
    background: #dbdbdb;
    color: #ea4040;
  }
---

<!-- Use Marp extension - (marp-team.marp-vscode) to view -->

# Regeneration of Orthology Mapping & Functional Annotation
## Candida auris v2 vs C. albicans SC5314

**Date:** March 18, 2026

---

## 1. Project Overview
* **Goal**: Update functional annotations for *Candida auris* by mapping the latest v2 genome (B9J08 locus tags) to *Candida albicans* SC5314.
* **Key Components**:
  1. Orthology Mapping (BLASTp)
  2. Custom OrgDB Generation (AnnotationForge)
  3. Differential Expression & Functional Enrichment

---

## 1.1 Previous Weeks Recap: Manual Phase & Replication Success
* **Last 2 Weeks**: Analysis was initially conducted by manual ID-by-ID mapping of new locus tags into the legacy `Ortho.xlsx`.
* **Validation**: This work culminated in a **[Replication Comparison](diff_expr_GSE272878/presentation.md)** against the original **Phan-Canh et al. (2025)** study.
* **Outcome**: Successfully achieved **100% consistency** with the published results:
  - Reproduced the exact PCA variance (PC1: 28.2%, PC2: 22.5%).
  - Confirmed "membrane-related" GO enrichment for the tolerant phenotype.
* **Transition**: To ensure scalability and remove human error from ID mapping, the project developed the current **BLAST-based automated pipeline** for *C. auris* v2.

---

## 2. Deep Dive: `run_blast.sh` (The Engine)
This script automates the high-throughput sequence alignment.

* `set -e`: **Safety First.** Ensures the script stops immediately if any command fails.
* `makeblastdb`: Converts the *C. albicans* FASTA file into a binary format optimized for BLAST searches.
* `blastp`:
  - `-query`: Uses *C. auris* v2 proteins as the "search terms."
  - `-outfmt "10 ..."`: The most critical part. It requests **CSV output (10)** with custom columns (`qseqid`, `sseqid`, `pident`, etc.) to match the requirements of the downstream Python script.
  - `-num_threads 4`: Parallelizes the search for speed.
* **Output**: Saves the sequence alignment results to **`Ortho_v2_blast.txt`**.

---

## 2.1 Data Sourcing: The Origins
Where do the sequences come from in `run_blast.sh`?

* **Candida albicans SC5314**:
  - Source: **FungiDB (Release 68)**.
  - Action: Automatically downloaded via `wget` if not present.
  - URL: `https://fungidb.org/common/downloads/Current_Release/CalbicansSC5314/fasta/data/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta`
* **Candida auris v2**:
  - Source: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_002759435.2/
  - Path: `cauris_v2/ncbi_dataset/data/GCA_002759435.2/protein.faa`

---

## 3. Deep Dive: `finalize_ortho.py` (Logic)

### Step 1: GFF Parsing
Uses **Regular Expressions** (`re.search`) to scan the NCBI GFF file. It extracts the link between `protein_id` (used by BLAST) and `locus_tag` (used in RNA-seq).
```python
locus_match = re.search(r'locus_tag=([^;]+)', attr)
```

### Step 2: FASTA Header Extraction
Scans the FungiDB protein headers to get the "Product Name" and "Length." It handles inconsistent headers by defaulting to "hypothetical protein."

---

## 4. Deep Dive: `finalize_ortho.py` (Merging)

### Step 3: Best-Hit Filtering
BLAST often finds multiple hits for one protein. We only want the best one.
```python
processed_auris = set()
for row in reader:
    pis_id = row[0]
    if pis_id in processed_auris:
        continue # Skip if we already saw this protein
    ...
    processed_auris.add(pis_id)
```
* **Logic**: Since BLAST results are sorted by E-value (lowest first), the first time we see a `pis_id`, it is mathematically the **Best Hit**.

---

## 5. Deep Dive: `to_generate_C.albicansOrgDB.R`
This R script builds a Bioconductor-compatible database package.

* `read.delim(..., skip = 1)`: Skips the GAF file header.
* `dplyr::distinct(...)`: **Data Cleaning.** Ensures no redundant Gene-to-GO mappings, which would break the database build.
* `makeOrgPackage(...)`:
  - `gene_info`: Basic mapping (ID to Symbol).
  - `go`: The GO annotation table.
  - `tax_id="5314"`: Assigns the correct NCBI Taxonomy ID for *C. albicans*.

---

## 6. Downstream Analysis Workflow
Integration of orthology results into the biological discovery pipeline.

1. **Differential Expression**: `run_analysis.R`
2. **GO Enrichment**: `run_go_enrichment.R`
3. **Advanced Visualization**: `run_heatmap_gen.R`

---

## 6.1 Deep Dive: `run_analysis.R` (DGE)
This script implements a rigorous `edgeR` pipeline for identifying transcriptomic shifts.

* **Filtering & Normalization**: Removes low-expression tags (CPM < 1 in < 3 samples).
  ```R
  keep <- rowSums(cpm(d)> 1) >= 3 
  d <- d[keep,] 
  d <- calcNormFactors(d) # TMM Normalization
  ```
---
* **Statistical Modeling**: Estimates `Common` and `Tagwise` dispersions to account for biological variance beyond Poisson noise.
* **Exact Tests**: Performs pairwise comparisons using a negative binomial distribution.
  ```R
  et <- exactTest(d, pair=c('WT', group))
  ```
* **Multi-stage Visualization**: Generates **Smear plots**, **Volcano plots**, and **PCA**.
* **Annotation Integration**: Automatically merges DGE statistics with the orthology map.
  ```R
  resCa <- merge(res, CaOrth, by = "geneID")
  ```

---

## 6.2 Deep Dive: `run_go_enrichment.R` (GO)
Translates gene lists into biological processes using Over-Representation Analysis (ORA).

* **Input**: Significant DEGs (FDR < 0.05) from the `I1 vs S1` comparison.
* **Background Selection**: Uses all tested genes as the **Universe**.
* **Custom Database**: Leverages `org.Calbicans.Eupath.v68.eg.db` to map functions.
  ```R
  ego <- enrichGO(gene = up_genes, universe = universe_genes, 
                  OrgDb = org.Calbicans.Eupath.v68.eg.db, ont = "CC")
  ```
* **Focus**: Concentrates on **Cellular Component (CC)**.
* **Outputs**: High-fidelity PDF/PNG visualizations including `dotplots` and `barplots`.

---

## 6.3 Deep Dive: `run_heatmap_gen.R` (Heatmap)
A high-density visualization of the phenotypic landscape across multiple conditions.

* **Selection Strategy**: Extracts the top 70 DEGs.
* **Stability Fix**: Caps LogFC values at `[-1, 2]` to preserve contrast.
  ```R
  mat_logfc[mat_logfc < -1] <- -1
  mat_logfc[mat_logfc > 2] <- 2
  ```
* **Significance Markers**: Injects `grid.circle` overlays (black dots) via `cell_fun`.
  ```R
  if(!is.na(mat_fdr[i, j]) && mat_fdr[i, j] < 0.05) {
    grid.circle(x = x, y = y, r = unit(0.8, "mm"))
  }
  ```
* **Clustering Analysis**: Uses **Pearson Correlation** distance.

---

## 7. How to Reproduce

### 1. BLAST & Orthology
```bash
mamba activate blast_env
./run_blast.sh
python3 finalize_ortho.py
```

### 2. DGE & Functional Analysis
```bash
# Differential Expression
mamba activate cauris_downstream
Rscript run_analysis.R

# GO Enrichment & Heatmaps
mamba activate cauris_go
Rscript run_go_enrichment.R
Rscript run_heatmap_gen.R
```

---

## 8. Summary of Improvements
* **Locus Tag Accuracy**: Verified 1:1 mapping for B9J08 tags.
* **Database Versioning**: Upgraded to **FungiDB-68** for both BLAST and GO.
* **Visualization**: Automated PDF reporting of enrichment results.
* **Reproducibility**: Entire pipeline is scripted and container-ready.
