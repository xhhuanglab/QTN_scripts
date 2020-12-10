#if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")

#BiocManager::install("karyoploteR")


###################

setwd("path_to_dir")


library(karyoploteR)
library(BSgenome.Osativa.MSU.MSU7)
library(viridis)

pdf("Final.lablecolored.final_222_QTG_distribution.pdf", 20,25)

kp <- getDefaultPlotParams(plot.type = 2)

kp$ideogramheight <- 30
kp$chromosome.height <- 800
kp$data2height <- 100

#Or read them from a BED file if available
causal_genes <- toGRanges("final.all_222_nuc_QTGs.loci")

y_dis <- rnorm(220, mean=0.5, sd=0.25)

kp <- plotKaryotype(genome="MSU7",chromosomes = paste("Chr", 1:12, sep = ""), plot.params = kp,cex=3)


kpAddBaseNumbers(kp, tick.dist = 5000000, tick.len = 20, tick.col="black", cex=1.5,
                 minor.tick.dist = 1000000, minor.tick.len = 10, minor.tick.col = "black")

#kpPlotRegions(kp, data=causal_genes, r0=0, r1=0.3) #plot the genes
#kpText(kp, data = causal_genes, y=1, labels = italic(causal_genes$genename), r0=0.3, r1=1, cex=0.5, srt = 45 )


seg_color1 <- rgb(92,200,98,max=255)
seg_color2 <- rgb(51,71,133,max=255)
#genomeblock1 <- toGRanges("IND-JAP.old_to_new_position.2.new")
genomeblock1 <- toGRanges("IND-JAP.old_to_new_position.2.new_add")

kpBars(kp, data=genomeblock1, chr=genomeblock1$chr, 
x0=genomeblock1$start, x1=genomeblock1$end, y0=0, y1=1.4, 
col=viridis(5),
data.panel="ideogram",border=NA)

kpPlotMarkers(kp, data=causal_genes, chr=causal_genes$seqnames, x=causal_genes$start, y=0.5, 
labels=causal_genes$genename,cex=1.5,
line.color = as.character(causal_genes$linkcolor),
label.color="black", label.dist=0.008,
#line.color = "gray",
#label.color=as.character(causal_genes$linkcolor), label.dist=0.008,
ignore.chromosome.ends = TRUE, 
marker.parts = c(0,0.5,0.1), 
srt=45)

dev.off()





