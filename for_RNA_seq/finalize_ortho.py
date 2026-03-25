import csv
import re

gff_path = 'cauris_v2/ncbi_dataset/data/GCA_002759435.2/genomic.gff'
blast_path = 'Ortho_v3_blast.txt'
alb_fasta_path = 'SC5314_fungiDB/FungiDB-68_CalbicansSC5314_AnnotatedProteins.fasta'
output_path = 'Ortho_v3.csv'

# Step 1: Extract Auris protein info from GFF (start, end, locus_tag)
# Example: PEKT02000007.1 Genbank CDS 2 1229 . - 0 ID=cds-PIS51016.1;...locus_tag=B9J08_002585;...protein_id=PIS51016.1;...
auris_info = {}
with open(gff_path, 'r') as f:
    for line in f:
        if line.startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) < 9:
            continue
        
        if cols[2] == 'CDS':
            attr = cols[8]
            pis_match = re.search(r'protein_id=([^;]+)', attr)
            locus_match = re.search(r'locus_tag=([^;]+)', attr)
            if pis_match and locus_match:
                pis_id = pis_match.group(1)
                auris_info[pis_id] = {
                    'start': cols[3],
                    'end': cols[4],
                    'geneID': locus_match.group(1)
                }

# Step 2: Extract Albicans Gene Names, Functions and Length from FungiDB
# Header example: >C1_00010W_A-T-p1 | ... | gene_product=Dubious open reading frame | ... | protein_length=112 | ...
alb_info = {}
with open(alb_fasta_path, 'r') as f:
    for line in f:
        if line.startswith('>'):
            full_id = line[1:].split()[0]
            gene_match = re.search(r'gene=([^ |]+)', line)
            product_match = re.search(r'gene_product=([^|]+)', line)
            len_match = re.search(r'protein_length=([0-9]+)', line)
            
            gene_id = gene_match.group(1) if gene_match else full_id.split('-')[0]
            product = product_match.group(1).strip() if product_match else "hypothetical protein"
            length = len_match.group(1) if len_match else "0"
            
            alb_info[full_id] = {
                'gene': gene_id,
                'product': product,
                'length': length
            }

# Step 3: Parse BLAST results and keep BEST HIT per Auris protein
# Original headers: protAlbicans,geneID,protAuris,start,end,ANNOT_GENE_NAME,function,length,Ident,Align,Mismatches,Gaps,qStart,qEnd,sStart,sEnd,EValue,Score,qCover,ANNOT_GENE_ENTREZ_ID
header = ['protAlbicans', 'geneID', 'protAuris', 'start', 'end', 'ANNOT_GENE_NAME', 'function', 'length', 'Ident', 'Align', 'Mismatches', 'Gaps', 'qStart', 'qEnd', 'sStart', 'sEnd', 'EValue', 'Score', 'qCover', 'ANNOT_GENE_ENTREZ_ID']

processed_auris = set()

with open(blast_path, 'r') as f_in, open(output_path, 'w', newline='') as f_out:
    reader = csv.reader(f_in, delimiter='\t')
    writer = csv.DictWriter(f_out, fieldnames=header)
    writer.writeheader()
    
    for row in reader:
        pis_id = row[0]
        if pis_id in processed_auris:
            continue
        
        full_alb_id = row[1]
        a_info = auris_info.get(pis_id, {'start': '0', 'end': '0', 'geneID': 'Unknown'})
        info = alb_info.get(full_alb_id, {'gene': full_alb_id.split('-')[0], 'product': 'Unknown', 'length': '0'})
        
        writer.writerow({
            'protAlbicans': full_alb_id,
            'geneID': a_info['geneID'],
            'protAuris': pis_id,
            'start': a_info['start'],
            'end': a_info['end'],
            'ANNOT_GENE_NAME': info['gene'],
            'function': info['product'],
            'length': info['length'],
            'Ident': row[2],
            'Align': row[3],
            'Mismatches': row[4],
            'Gaps': row[5],
            'qStart': row[6],
            'qEnd': row[7],
            'sStart': row[8],
            'sEnd': row[9],
            'EValue': row[10],
            'Score': row[11],
            'qCover': row[12],
            'ANNOT_GENE_ENTREZ_ID': '' # Leave blank or use a placeholder if not found
        })
        processed_auris.add(pis_id)

print(f"Finalized Ortho_v3.csv with {len(processed_auris)} best hits matching original headers.")
