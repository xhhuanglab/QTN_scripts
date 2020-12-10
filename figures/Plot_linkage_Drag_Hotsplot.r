
library(karyoploteR)
library(BSgenome.Osativa.MSU.MSU7)
library(viridis)

setwd("C:\\0Analysis_Research\\Rice_Breeding_Navigation\\Supplementary_Figure_plot\\SubFigure5_linkage_drag_hotspot")
pdf("Chr7-12.LinkageDrag_hotspot_plot.pdf",10,5)
pp <- getDefaultPlotParams(plot.type = 4)
pp$data1inmargin <- 0
pp$bottommargin <- 20

kp <- plotKaryotype(genome="MSU7",ideogram.plotter = NULL, 
plot.type = 4,chromosomes = paste("Chr", 7:12, sep = ""),cex=0.5,
labels.plotter = NULL, plot.params = pp)

kpAddCytobandsAsLine(kp,lwd = 16, lend = 1)
kpAddChromosomeNames(kp, srt=0,cex = 0.8)
kpAddBaseNumbers(kp, tick.dist = 20000000, tick.len = 1, tick.col="black", cex=0.6,
                 minor.tick.dist = 10000000, minor.tick.len = 0.5, minor.tick.col = "black")



kpDataBackground(kp, data.panel = 1, r0=0, r1=0.45,color = "gray95")
kpAxis(kp, data.panel=1, ymin = 0, ymax = 1, r0=0, r1=0.45, numticks = 5)
#kpAddLabels(kp, labels = c("Distance between mutations (log10)"), srt=90, pos=1, label.margin = 0.04)


peakSNPs <- toGRanges("QTG_linkage_drag_population_fixation")

kp <- kpPoints(kp, data = peakSNPs,y=peakSNPs$percent,cex=0.7,lwd=0.5, ymax=1,r0=0, r1=0.45, col="deepskyblue3")


################

causal_genes <- toGRanges("Final_linkageDrag_QTG_Name")
kpPlotMarkers(kp, data=causal_genes, chr=causal_genes$seqnames, x=causal_genes$start, 
r0 = 0.45, r1 = 0.6, 
labels=causal_genes$genename,cex=0.7,
line.color = "gray",
label.color="black", 
label.dist=0.000,
ignore.chromosome.ends = FALSE, 
marker.parts = c(0.1,0.1,0.1),
text.orientation = "vertical",
max.iter = 1000
)


coord_flip()

#############

dev.off()

