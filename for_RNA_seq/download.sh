# Define the list of SRX accessions
ACCESSIONS=(
    SRR29929698
    SRR29929699
    SRR29929700
    SRR29929701 
    SRR29929702
    SRR29929703
    SRR29929704
    SRR29929705
    SRR29929706
    SRR29929707
    SRR29929708
    SRR29929709
    SRR29929710
    SRR29929711
    SRR29929712
)

# Loop through each accession, download, and extract
for ACC in "${ACCESSIONS[@]}"; do
  echo "Downloading $ACC..."
  prefetch -v "$ACC"
  
  echo "Extracting FASTQ for $ACC..."
  # --split-files separates forward and reverse reads if the data is paired-end
  fasterq-dump "$ACC" --split-files --threads 4 
done

echo "All files downloaded and extracted."