library(ComplexHeatmap)
library(dplyr)
library(circlize)
library(readr)

# Load consolidated results from TSV
res_all_raw <- read_tsv("../results/tables/all_results.tsv", show_col_types = FALSE)
# Use geneID column as rownames for the rest of the logic
res_all <- as.data.frame(res_all_raw)
rownames(res_all) <- res_all$geneID

# Load name mapping from the results table
mapping <- read_tsv("../results/tables/I1_vs_S1_results_wNames.tsv", show_col_types = FALSE) %>%
  select(geneID, GeneName) %>%
  distinct()

# 1. Identify notable genes: Top 50 Up and Top 50 Down
# Based on the I1 vs S1 comparison
sig_res <- res_all %>% 
  filter(FDR_I1_vs_S1 < 0.05) %>%
  arrange(desc(logFC_I1_vs_S1))

gen_lim <- 35
top_up <- head(sig_res, gen_lim) %>% pull(geneID)
top_down <- tail(sig_res, gen_lim) %>% pull(geneID)

# Combine
genes_to_plot <- unique(c(top_up, top_down))

# 2. Prepare LogFC matrix
cols_logfc <- c("logFC_R2_vs_S1", "logFC_I1", "logFC_I1_vs_S1", "logFC_R1", "logFC_S1", "logFC_R2", "logFC_R1_vs_S1")
mat_logfc <- res_all[genes_to_plot, cols_logfc]

# CAP values to [-1, 2] for better contrast
mat_logfc[mat_logfc < -1] <- -1
mat_logfc[mat_logfc > 2] <- 2

# Rename columns for display
colnames(mat_logfc) <- c("R2 vs S1", "T1 vs WT", "T1 vs S1", "R1 vs WT", "S1 vs WT", "R2 vs WT", "R1 vs S1")

# 3. Prepare FDR matrix for dots
cols_fdr <- c("FDR_R2_vs_S1", "FDR_I1", "FDR_I1_vs_S1", "FDR_R1", "FDR_S1", "FDR_R2", "FDR_R1_vs_S1")
mat_fdr <- res_all[genes_to_plot, cols_fdr]

# 4. Get Gene Names for row labels, fallback to geneID if GeneName is NA
row_labels <- mapping$GeneName[match(genes_to_plot, mapping$geneID)]
row_labels[is.na(row_labels) | row_labels == ""] <- genes_to_plot[is.na(row_labels) | row_labels == ""]

# 5. Color scale
col_fun = colorRamp2(c(-1, 0, 2), c("blue", "white", "red"))

# 6. Generate Heatmap
h <- Heatmap(as.matrix(mat_logfc), 
        name = "Log2 FC",
        col = col_fun,
        cluster_rows = TRUE,
        cluster_columns = TRUE, 
        clustering_distance_rows = "pearson",
        row_labels = row_labels,
        row_names_gp = gpar(fontsize = 9),
        column_names_gp = gpar(fontsize = 9),
        column_title = "Strain and Phenomenon Comparisons (Top DEGs)",
        
        cell_fun = function(j, i, x, y, width, height, fill) {
          if(!is.na(mat_fdr[i, j]) && mat_fdr[i, j] < 0.05) {
            grid.circle(x = x, y = y, r = unit(0.8, "mm"), 
                        gp = gpar(fill = "black", col = "black"))
          }
        }
)

# Save
pdf("../results/plots/Heatmap_Tolerant_vs_Sensitive.pdf", width = 8, height = 12)
draw(h)
dev.off()

png("../results/plots/Heatmap_Tolerant_vs_Sensitive.png", width = 900, height = 1200, res = 120)
draw(h)
dev.off()

