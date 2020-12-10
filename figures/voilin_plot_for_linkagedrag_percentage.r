# Libraries
library(ggplot2)
library(dplyr)
library(viridis)
library(scales)

setwd("path_to_dir")

pdf("voilin_linkage_drag_percentage.pdf",6,6)


data <- read.table("five_group_ratio",header=T,sep="\t")

data$Type = factor(data$Type, levels=c("ALL","TEJ","TRJ","BAS","AUS","IND"))


data$Type <- as.factor(data$Type)

p <- ggplot(data, aes(x=Type, y=Percent, color=Type)) + 
  geom_violin(trim=FALSE)+

scale_color_manual(values=c("black", "gold", "red","purple","darkgreen","royalblue")) +
scale_fill_manual(values=c("black", "gold", "red","purple","darkgreen","royalblue")) +

geom_boxplot(width=0.1,fill="white") +


theme_bw()+
theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),panel.background = element_blank())+

theme(axis.text.y  = element_text(angle=0,
                                       color="black",
                                       vjust=0.5,
                                       size=16)
           ) +
theme(axis.text.x  = element_text(colour="black",
                                       angle=0,
                                       vjust=0.5,
                                       size=16)
           )+
theme(legend.position="none")+
scale_y_continuous(labels=percent,limits=c(0,0.45))+


ylab("")+
xlab("")

p

dev.off()

