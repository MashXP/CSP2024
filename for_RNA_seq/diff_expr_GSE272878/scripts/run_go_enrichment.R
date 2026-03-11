library(clusterProfiler)
library(org.Calbicans.Eupath.v68.eg.db)
library(dplyr)
library(ggplot2)
library(readr)

# Load DGE results
results <- read_tsv("../results/tables/I1_vs_S1_results_wNames.tsv", show_col_types = FALSE)

# Filter for DEGs (FDR < 0.05)
degs <- results %>% filter(FDR < 0.05)

# Upregulated genes - Use CGDID which matches the OrgDb IDs
up_genes <- degs %>% filter(logFC > 0) %>% pull(CGDID)
# Downregulated genes
down_genes <- degs %>% filter(logFC < 0) %>% pull(CGDID)

# Universe genes (all genes tested in DGE)
universe_genes <- results$CGDID

# Run GO enrichment for CC (Cellular Component)
ego_up <- enrichGO(gene          = up_genes,
                   universe      = universe_genes,
                   OrgDb         = org.Calbicans.Eupath.v68.eg.db,
                   keyType       = "GID",
                   ont           = "CC",
                   pAdjustMethod = "BH",
                   pvalueCutoff  = 1,
                   qvalueCutoff  = 1)

ego_down <- enrichGO(gene          = down_genes,
                     universe      = universe_genes,
                     OrgDb         = org.Calbicans.Eupath.v68.eg.db,
                     keyType       = "GID",
                     ont           = "CC",
                     pAdjustMethod = "BH",
                     pvalueCutoff  = 1,
                     qvalueCutoff  = 1)

# Save results
pdf("../results/plots/GO_enrichment_I1_vs_S1.pdf", width = 10, height = 8)

if (!is.null(ego_up) && nrow(as.data.frame(ego_up)) > 0) {
  p_up_dot <- dotplot(ego_up, showCategory = 20) + ggtitle("GO Enrichment CC - Upregulated in I1 vs S1")
  p_up_bar <- barplot(ego_up, showCategory = 20) + ggtitle("GO Enrichment CC - Upregulated in I1 vs S1")
  print(p_up_dot)
  print(p_up_bar)
  
  png("../results/plots/GO_UP_dotplot.png", width = 1000, height = 800, res = 120)
  print(p_up_dot)
  dev.off()
  
  png("../results/plots/GO_UP_barplot.png", width = 1000, height = 800, res = 120)
  print(p_up_bar)
  dev.off()
} else {
  message("No significant GO enrichment found for upregulated genes.")
}

if (!is.null(ego_down) && nrow(as.data.frame(ego_down)) > 0) {
  p_down_dot <- dotplot(ego_down, showCategory = 20) + ggtitle("GO Enrichment CC - Downregulated in I1 vs S1")
  p_down_bar <- barplot(ego_down, showCategory = 20) + ggtitle("GO Enrichment CC - Downregulated in I1 vs S1")
  print(p_down_dot)
  print(p_down_bar)
  
  png("../results/plots/GO_DOWN_dotplot.png", width = 1000, height = 800, res = 120)
  print(p_down_dot)
  dev.off()
  
  png("../results/plots/GO_DOWN_barplot.png", width = 1000, height = 800, res = 120)
  print(p_down_bar)
  dev.off()
} else {
  message("No significant GO enrichment found for downregulated genes.")
}

dev.off()

# Save tables
if (!is.null(ego_up)) write_tsv(as.data.frame(ego_up), "../results/tables/GO_UP_I1_vs_S1.tsv")
if (!is.null(ego_down)) write_tsv(as.data.frame(ego_down), "../results/tables/GO_DOWN_I1_vs_S1.tsv")
