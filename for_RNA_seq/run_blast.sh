#!/bin/bash

# Exit on error
set -e

# Environment name
ENV_NAME="blast_env"

# File paths
ALBICANS_FASTA="SC5314_fungiDB/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta"
AURIS_FASTA="cauris_v2/ncbi_dataset/data/GCA_002759435.2/protein.faa"
DB_DIR="SC5314_fungiDB/blast_db"
OUTPUT_FILE="Ortho_v2_blast.txt"

echo "Step 1: Checking for required protein files..."

# Check if C. albicans proteins exist, download if not
if [ ! -f "$ALBICANS_FASTA" ]; then
    echo "Downloading C. albicans proteins..."
    mkdir -p "SC5314_fungiDB"
    wget -O "$ALBICANS_FASTA" https://fungidb.org/common/downloads/Current_Release/CalbicansSC5314/fasta/data/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta
else
    echo "C. albicans proteins already present."
fi

# Note: C. auris v2 proteins are assumed to be present in cauris_v2 directory
if [ ! -f "$AURIS_FASTA" ]; then
    echo "Error: C. auris v2 proteins not found at $AURIS_FASTA"
    exit 1
fi

echo "Step 2: Creating BLAST database for C. albicans..."
mkdir -p "$DB_DIR"
mamba run -n "$ENV_NAME" makeblastdb \
    -in "$ALBICANS_FASTA" \
    -dbtype prot \
    -out "$DB_DIR/Calbicans_db"

echo "Step 3: Running blastp (C. auris v2 vs C. albicans)..."
# Using outfmt 10 (CSV) with specific columns
# qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs
mamba run -n "$ENV_NAME" blastp \
    -query "$AURIS_FASTA" \
    -db "$DB_DIR/Calbicans_db" \
    -out "$OUTPUT_FILE" \
    -outfmt "10 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs" \
    -num_threads 4

echo "Step 4: BLAST completed. Output saved to $OUTPUT_FILE"
head -n 5 "$OUTPUT_FILE"
