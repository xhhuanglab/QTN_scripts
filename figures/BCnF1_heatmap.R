library(pheatmap)
library(RColorBrewer)

setwd("path_to_dir")
#matrix <- read.table("filtered.trans.BC1F1_all_final_500.raw_geno",header = TRUE,sep="\t")
#matrix <- read.table("filtered.trans.BC2F1_all_final_1300.raw_geno",header = TRUE,sep="\t")
#matrix <- read.table("filtered.trans.BC3F1_all_final_1800.raw_geno",header = TRUE,sep="\t")
#matrix <- read.table("selected_samples.names.geno",header=TRUE,sep="\t")
matrix <- read.table("selected_samples.names.reverse_samples.geno",header=TRUE,sep="\t")
#matrix <- read.table("locate_17_GeneMarker.posi",header=TRUE,sep="\t")


#pdf("final.BC1F1_heatmap.pdf",8,9)
#pdf("final.BC2F1_heatmap.pdf",8,9)
#pdf("final.BC3F1_heatmap.pdf",8,9)
#pdf("final.selected.BC3F1_heatmap.pdf",8,9)
pdf("finalreverse.selected.BC3F1_heatmap.pdf",7,9)
#pdf("finalreverse.selected.BC3F1_heatmap.pdf",0.5,9)


breaksList = c("-0.5","0.5","1.5","2.5")

#datainfo <- matrix[3:463]
#datainfo <- matrix[3:910]
#datainfo <- matrix[3:1192]
datainfo <- matrix[2:272]
#rowid <- matrix[1:2]
#length(rowid)
#length(datainfo)
rownames(datainfo) = matrix$Final_Posi


het_color <- "gold" #rgb(255,234,155,max=255) #"gold" 
HHZ_color <- rgb(0,143,157,max=255) #"darkgreen" #rgb(236,107,161,max=255) # #rgb(222,222,222,max=255) 
Basmati_color <- "red"

#het_color <- "gold" #rgb(255,234,155,max=255) #"gold" 
#HHZ_color <- "gray" #"darkgreen" #rgb(236,107,161,max=255) # #rgb(222,222,222,max=255) 
#Basmati_color <- "black"

pic <- pheatmap(datainfo,
cellwidth = 1.7,
cellheight = 0.2,
#color = c("gray","gold","yellow","MEDIUM VIOLET RED","royalblue","royalblue"),
#color = c("gray",ref_color,"lightgreen",alt_color,"gold","gold"),
color=c(HHZ_color,het_color,Basmati_color),
breaks = breaksList,
show_rownames = FALSE,
show_colnames = FALSE,
show_lengend = TRUE,
cluster_rows = FALSE,
cluster_cols = FALSE,
#gaps_row = c(139,258,375,486,583,676,773,859,933,1013,1104), ## BC1F1
#gaps_row = c(142,255,371,472,558,654,750,833,901,963,1052),  ## BC2F1
#gaps_row = c(322,631,929,1193,1394,1621,1818,2029,2213,2353,2570),  ## BC3F1
gaps_row = c(322,631,929,1193,1394,1621,1818,2029,2213,2353,2570),

legend = FALSE,
width = 8,
height = 5,

)

dev.off()

