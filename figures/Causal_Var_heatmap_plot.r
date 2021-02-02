library(pheatmap)
library(RColorBrewer)

setwd("path_to_dir")
matrix <- read.table("CausalHeatmap.matrix",header = TRUE,sep="\t")


pdf("causalvar_heatmap.pdf",6,8)

breaksList = c("-10","-1","0.5","1.5","2.5","3.5")

datainfo <- matrix[2:405]
#rowid <- matrix[1:2]
rownames(datainfo) = matrix$ID


ref_color <- rgb(80,187,195,max=255)
alt_color <- rgb(11,78,162,max=255)


pic <- pheatmap(datainfo,

cellwidth = 1,
cellheight = 1.5,
color = c("gray",ref_color,"lightgreen",alt_color,"gold"),
breaks = breaksList,
show_rownames = FALSE, fontsize_row = 1,
show_colnames = FALSE,
show_lengend = TRUE,
cluster_rows = FALSE,
cluster_cols = FALSE,
gaps_row = c(68,116,145,170,186,203,279,322),
legend = FALSE,

)

dev.off()

