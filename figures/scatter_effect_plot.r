library(ggplot2)
library(viridis)

setwd("path_to_dir")

pdf("plant_height.effect.scatter_with_SE.pdf",4,7)
#pdf("GrainNumPerPanicle.effect.scatter_with_SE.pdf",4,5)
#pdf("heading_date.effect.scatter_with_SE.pdf",4,5)
#pdf("GrainLen.effect.scatter_with_SE.pdf",4,5)
#pdf("Grain_Width.effect.scatter_with_SE.pdf",4,5)


df3 <- read.table("PlantHeight_raw.addcolor",header=TRUE,sep="\t")
#df3 <- read.table("GrainNum_raw.addcolor",header=TRUE,sep="\t")
#df3 <- read.table("HeadingDate_raw.addcolor",header=TRUE,sep="\t")
#df3 <- read.table("GrainLen_raw.addcolor",header=TRUE,sep="\t")
#df3 <- read.table("GrainWidth_raw.addcolor",header=TRUE,sep="\t")


# Change color by groups
# Add error bars
p <- ggplot(df3, aes(x=Gene, y=Effect))+ 
    geom_errorbar(aes(ymin=Effect-SE, ymax=Effect+SE), width=0.2, 
    position=position_dodge(0.05),color="gray50") +
    geom_point(size=2,color = df3$Color)+
theme_bw()+
theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),panel.background = element_blank())+
xlab(" ") +
ylab(" ") +
theme(axis.text.y  = element_text(face="italic",angle=0,
                                       color="black",
                                       vjust=0.5,
                                       size=16) 
           ) +
theme(axis.text.x  = element_text(colour="black",
                                       angle=0,
                                       vjust=0.5,
                                       size=16) 
           )+
geom_hline(yintercept = 0,color="gray50") +
coord_flip()
p
dev.off()