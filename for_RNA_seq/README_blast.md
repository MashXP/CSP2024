# BLAST Orthology Analysis for C. auris v2

This directory contains the results of a BLASTp analysis mapping the newer C. auris v2 proteins (B9J08 locus tags) to C. albicans SC5314 proteins.

## Files Created
- `run_blast.sh`: Shell script to download proteins, build BLAST database, and run blastp.
- `finalize_ortho.py`: Python script to merge BLAST results with GFF locus tags and FungiDB gene descriptions.
- `Ortho_v2_blast.txt`: Raw BLAST output (CSV format).
- `Ortho_v2.csv`: Final processed orthology table with the following columns:
  - `protAlbicans`: C. albicans protein ID.
  - `geneID`: C. auris v2 locus tag (B9J08_XXXXXX).
  - `protAuris`: C. auris protein ID (PISXXXXX.X).
  - `ANNOT_GENE_NAME`: C. albicans gene name.
  - `function`: C. albicans protein function.
  - `Ident`, `Align`, `EValue`, etc.: BLAST metrics.

## Usage
To regenerate the results, ensure the `blast_env` mamba environment is activated:
```bash
mamba activate blast_env
./run_blast.sh
python3 finalize_ortho.py
```
