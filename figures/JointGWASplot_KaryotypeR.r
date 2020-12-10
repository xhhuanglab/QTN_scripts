
library(karyoploteR)
library(BSgenome.Osativa.MSU.MSU7)
library(viridis)

setwd("path_to_dir")

pdf("100k.69_Final_QTG_JointGWAS_plot.pdf",10,5)



pp <- getDefaultPlotParams(plot.type = 4)
pp$data1inmargin <- 0
pp$bottommargin <- 20

kp <- plotKaryotype(genome="MSU7",ideogram.plotter = NULL, 
plot.type = 4,chromosomes = paste("Chr", 1:12, sep = ""),cex=0.5,
labels.plotter = NULL, plot.params = pp)
kpAddCytobandsAsLine(kp,lwd = 16, lend = 1)
kpAddChromosomeNames(kp, srt=0,cex = 0.8)
kpAddBaseNumbers(kp, tick.dist = 20000000, tick.len = 1, tick.col="black", cex=0.6,
                 minor.tick.dist = 10000000, minor.tick.len = 0.5, minor.tick.col = "black")





kpAxis(kp, data.panel=1, ymin = 0, ymax = 50, r0=0, r1=0.4, numticks = 3)

peakSNPs <- toGRanges("470_raw_points.addcolor")

kp <- kpPoints(kp, data = peakSNPs,y=peakSNPs$pvalue, 
pch=peakSNPs$cohortid, col = as.character(peakSNPs$Color),cex=0.5,lwd=0.5, ymax=50, r0=0, r1=0.4)



################


kpDataBackground(kp, data.panel = 1, r0=0.45, r1=0.65,color = "gray95")
kpAxis(kp, data.panel=1, ymin = 0, ymax = 40, r0=0.45, r1=0.65, numticks = 3)

##File2: Region_plot_data_slim

region_info <- toGRanges("470_points_slim")


kpPlotRegions(kp, col = "gray33", data=region_info, layer.margin = 0.02, r0 = 0.45, r1 = 0.64)

##File3: GWAS_overlapped_QTGs
causal_genes <- toGRanges("69_QTGids.nonredun")
kpPlotMarkers(kp, data=causal_genes, chr=causal_genes$seqnames, x=causal_genes$start, 
r0 = 0.65, r1 = 0.8, 
labels=causal_genes$genename,cex=0.6,
label.color = as.character(causal_genes$linkcolor),
line.color = "gray",
label.dist=0.000,
ignore.chromosome.ends = FALSE, 
marker.parts = c(0.1,0.1,0.1),
text.orientation = "vertical",
max.iter = 1000

)


#############

dev.off()

