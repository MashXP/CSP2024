#!/bin/bash

# Exit on error
set -e

# Environment name
ENV_NAME="blast_env"

# File paths
ALBICANS_FASTA="SC5314_fungiDB/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta"
AURIS_FASTA="cauris_v2/ncbi_dataset/data/GCA_002759435.2/protein.faa"

DB_DIR="SC5314_fungiDB/blast_db"
OUTPUT_FILE="Ortho_v3_blast.txt"

echo "Step 1: Checking for required protein files..."

# Check if C. albicans proteins exist, download if not
if [ ! -f "$ALBICANS_FASTA" ]; then
    echo "Downloading C. albicans proteins..."
    mkdir -p "SC5314_fungiDB"
    wget -O "$ALBICANS_FASTA" https://fungidb.org/common/downloads/Current_Release/CalbicansSC5314/fasta/data/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta
else
    echo "C. albicans proteins already present."
fi

echo "Step 2: Creating DIAMOND database for C. albicans..."
mkdir -p "$DB_DIR"
# This deletion is critical so the database rebuilds with default parsing rules
rm -f "$DB_DIR/Calbicans_db.dmnd"
mamba run -n "$ENV_NAME" diamond makedb \
    --in "$ALBICANS_FASTA" \
    --db "$DB_DIR/Calbicans_db" \
    --no-parse-seqids

echo "Step 3: Running diamond blastp (C. auris v2 vs C. albicans)..."
mamba run -n "$ENV_NAME" diamond blastp \
    --query "$AURIS_FASTA" \
    --db "$DB_DIR/Calbicans_db" \
    --out "$OUTPUT_FILE" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovhsp \
    --threads 4 \
    --no-parse-seqids

echo "Step 4: BLAST completed. Output saved to $OUTPUT_FILE"
head -n 5 "$OUTPUT_FILE"