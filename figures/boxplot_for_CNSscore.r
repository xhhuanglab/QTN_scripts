# Libraries
library(ggplot2)
library(dplyr)
#library(hrbrthemes)
library(viridis)
library(scales)

setwd("path_to_dir")


pdf("Nogrid.CNS_score.all_fourtypes.combined_QTN_rho.pdf",12,3)

data <- read.table("Grouped_CNS_score",header=T,sep="\t")

data$Category = factor(data$Category, levels=c("Promoter","UTR","NonSYN","LoF"))
data$Category <- as.factor(data$Category)

#data$Percent
p <- ggplot(data, aes(x=Category, y=rho_score, fill=data$Type),position_dodge(0.9)) + 

geom_boxplot(outlier.shape=NA,width=0.6) +
scale_fill_manual(values = c("gray", "red3")) +

theme_classic()+
theme(axis.text.y  = element_text(angle=0,
                                      color="black",
                                      vjust=0.5,
                                      size=16) 
          ) +
theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())+
theme(legend.position="none")+
scale_y_continuous(limits=c(0,1))+

theme(axis.text=element_text(size=25),
        axis.title=element_text(size=25))+

ylab("conservation score")+
xlab("")


p

dev.off()

