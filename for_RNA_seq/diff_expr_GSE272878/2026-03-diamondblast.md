---
marp: true
theme: default
paginate: true
backgroundColor: #f9f9f9
color: #333
style: |
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }
  h1 {
    color: #2c3e50;
  }
  h2 {
    color: #3498db;
  }
  code {
    background: #eef2f7;
    color: #d63031;
  }
---

# Optimization of Orthology Pipeline
## Transitioning from BLAST to DIAMOND Algorithmic Mapping

**Project Update:** March 25, 2026

---

## 1. Why the Change?
**The Problem**: Traditional BLASTp, while accurate, is computationally expensive and slow for large-scale eukaryotic proteome matching.

**The Solution**: Implementation of **DIAMOND** (Double Index Alignment of Next-generation DOLphin).

*   **Speed**: DIAMOND is up to 20,000x faster than BLAST on large datasets.
*   **Sensitivity**: Maintains BLAST-like sensitivity for protein-to-protein searches.
*   **Efficiency**: Optimized for modern CPU architectures and high-throughput pipelines.

---

## 2. Technical implementation
New script: `run_blast_diamond.sh`

**Workflow Highlights**:
1.  **Database Build**: `diamond makedb --in Calbicans_proteins.fasta`.
2.  **Sensitive Search**: `diamond blastp --query C_auris_v2.faa --db Calbicans_db`.
3.  **Custom Format**: Matches downstream `finalize_ortho.py` requirements:
    ```bash
    --outfmt 6 qseqid sseqid pident length mismatch gapopen \
               qstart qend sstart send evalue bitscore qcovhsp
    ```
4.  **Parsing Safety**: `--no-parse-seqids` used to ensure ID matching between NCBI and FungiDB remains intact.

---

## 3. Replication Summary (`2026-03-18_ortho_regen.md`)
The new pipeline was validated against the **Phan-Canh et al. (2025)** study.

**Key Achievements**:
*   **100% Parameter Consistency**: Reproduced the exact Published PCA variance (PC1: 28.2%, PC2: 22.5%).
*   **Biological Cluster Match**: Confirmed "membrane-related" GO enrichment for the tolerant phenotype.
*   **Automation**: Reduced manual ID-by-ID mapping of v2 locus tags to zero.

---

## 4. Conclusion: State of the Project
### Current Status: **Semi-Successful**

**Why Semi-Successful?**
*   **Success**: Technical replication of published statistics (PCA variance) is mathematically precise.
*   **Visual Discrepancy**: Generated graphs are not yet 1:1 consistent with the published figures, suggesting differences in visualization parameters or subsetting.
