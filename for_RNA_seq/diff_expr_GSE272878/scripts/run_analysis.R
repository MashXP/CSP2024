library(edgeR)
library(tidyverse)
library(ggbiplot)
library(RCurl)
library(readxl)
library(readr)

pval = 0.01 
pval_adjust = "BH"  
cutoff = c(-1,1)  

# Import the data in the Targets.txt file
targets <- readTargets(file = "../data/Targets.txt")

# Read in the count data
d <- readDGE(targets, path = "../data", header = FALSE)

# Filter low expression tags (cpm<1)
keep <- rowSums(cpm(d)> 1) >= 3 
d <- d[keep,] 
d$samples$lib.size <- colSums(d$counts) 

# Normalization (TMM)
d <- calcNormFactors(d) 

# Estimating the dispersions
d <- estimateCommonDisp(d, verbose=FALSE) 
d <- estimateTagwiseDisp(d) 

pdf("../results/plots/dispersion_plot.pdf")
plotBCV(d)
dev.off()

# Differential expression
groups_to_test <- c('R1', 'S1', 'R2', 'I1')
results_list <- list()

for (group in groups_to_test) {
  et <- exactTest(d, pair=c('WT', group))
  de <- decideTestsDGE(et, p=pval, adjust=pval_adjust)
  detags <- rownames(d)[as.logical(de)]
  
  # Export results
  res <- as.data.frame(topTags(et, n=Inf))
  results_list[[group]] <- res
  
  # Smear plot
  pdf(paste0('../results/plots/smear_', group, '_vs_WT.pdf'))
  plotSmear(et, de.tags=detags, xlab = "Average log2 counts per million", ylab = "log2 fold change", main = paste(group, "vs WT"))
  abline(h = cutoff, col = "blue")
  dev.off()
}

# Special contrasts
extra_contrasts <- list(
  'I1_vs_S1' = c('S1', 'I1'),
  'R2_vs_S1' = c('S1', 'R2'),
  'R1_vs_S1' = c('S1', 'R1')
)

for (contrast_name in names(extra_contrasts)) {
  pair <- extra_contrasts[[contrast_name]]
  et <- exactTest(d, pair=pair)
  results_list[[contrast_name]] <- as.data.frame(topTags(et, n=Inf))
  
  de <- decideTestsDGE(et, p=pval, adjust=pval_adjust)
  detags <- rownames(d)[as.logical(de)]
  
  pdf(paste0('../results/plots/smear_', contrast_name, '.pdf'))
  plotSmear(et, de.tags=detags, xlab = "Average log2 counts per million", ylab = "log2 fold change", main = contrast_name)
  abline(h = cutoff, col = "blue")
  dev.off()
}

groups_for_export <- c(groups_to_test, names(extra_contrasts))

# Consolidate results
res_combined <- results_list[[1]]
colnames(res_combined) <- paste0(colnames(res_combined), "_", names(results_list)[1])
for (i in 2:length(results_list)) {
  tmp <- results_list[[i]]
  colnames(tmp) <- paste0(colnames(tmp), "_", names(results_list)[i])
  res_combined <- merge(res_combined, tmp, by=0)
  rownames(res_combined) <- res_combined$Row.names
  res_combined$Row.names <- NULL
}

# Add geneID column for easier TSV processing
res_combined$geneID <- rownames(res_combined)
write_tsv(res_combined, '../results/tables/all_results.tsv')

# Volcano plots
for (group in groups_for_export) {
  logFC_col <- paste0("logFC_", group)
  FDR_col <- paste0("FDR_", group)
  
  pdf(file = paste0("../results/plots/volcano_", group, ".pdf"))
  p <- ggplot(res_combined, aes_string(x = logFC_col, y = paste0("-log10(", FDR_col, ")"))) +
    geom_point(alpha=0.4) +
    geom_hline(yintercept = -log10(pval), colour='red') +
    geom_vline(xintercept = cutoff, colour='blue') +
    xlab('Log2 FC') + ylab('-Log10 FDR') +
    ggtitle(paste(group))
  print(p)
  dev.off()
}

# CPM export
cpm_data = as.data.frame(cpm(d))
cpm_export <- cpm_data
cpm_export$geneID <- rownames(cpm_export)
write_tsv(cpm_export, '../results/tables/cpm.tsv')

# PCA analysis
cpmill_transp <- t(cpm_data)
cpmill_transp.pca <- prcomp(cpmill_transp, center = TRUE, scale. = TRUE)
strain_colors <- c("WT"="green", "S1"="blue", "R1"="red", "R2"="magenta", "I1"="purple")

plot_pca <- ggbiplot(cpmill_transp.pca, var.axes = FALSE, groups = d$samples$group) +
  scale_color_manual(values = strain_colors) +
  xlab("PC1 (28.2% explained variance)") +
  ylab("PC2 (22.5% explained variance)") +
  theme_minimal() +
  theme(legend.title = element_blank())

pdf(file = "../results/plots/PCA.pdf")
print(plot_pca + geom_text(aes(label=d$samples$description), vjust = 1.5, size = 3))
dev.off()

# Ortholog mapping
CaOrth_path <- "../../Ortho_v3.csv"
IDtable_path <- "../../A22_A19_names.txt"

if (file.exists(CaOrth_path) && file.exists(IDtable_path)) {
  CaOrth <- read_csv(CaOrth_path)
  # protAlbicans(1), geneID(2), ANNOT_GENE_NAME(6), function(7)
  CaOrth <- CaOrth[,c(1,2,6,7)]
  colnames(CaOrth) <- c("protAlbicans", "geneID", "albGeneName", "function")
  
  IDtable <- read_tsv(IDtable_path)
  
  for (group in groups_for_export) {
    res <- results_list[[group]]
    res$geneID <- rownames(res)
    
    # Merge with Ortho_v2
    resCa <- merge(res, CaOrth, by = "geneID")
    
    # Strip suffix from protAlbicans to match IDtable
    resCa$CGDID <- gsub("-T-p[0-9]+", "", resCa$protAlbicans)
    
    # Merge with IDtable for final GeneName
    resNames <- merge(resCa, IDtable, by = "CGDID", all.x = TRUE)
    
    suffix <- ifelse(grepl("vs", group), "", "_vs_WT")
    write_tsv(resNames, paste0("../results/tables/", group, suffix, "_results_wNames.tsv"))
  }
}
