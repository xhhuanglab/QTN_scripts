library(ggplot2)
library(gridExtra)
library(dplyr)

pdf("frag.pdf",3,4)


setwd("path_to_dir")

my_dat <- read.table("fragance_data",header=T,sep="\t")



data_stat <- summarise(group_by(my_dat, Sample),
                    my_mean = mean(data),
                    my_sd = sd(data))

p1 <- ggplot(data_stat) + 
  geom_bar(aes(y = my_mean, x = Sample), stat="identity", width=0.75, color="gray66",fill="gray66") + 
  geom_errorbar(aes(x = Sample,
                    ymin = my_mean - my_sd,
                    ymax = my_mean + my_sd),
                    stat="identity", width=0.2) + 
geom_point(data = my_dat, aes(y = data, x = Sample),
position=position_jitter(width=0.25, height=0), 
size=1,color=rgb(227,23,13,80,max=255)) +

theme_classic() + 
scale_x_discrete(
labels = c("","")
) +

theme(axis.text.y  = element_text(angle=0,
                                      color="black",
                                      vjust=0.5,
                                      size=16)
          ) +
theme(axis.text.x  = element_text(color="black",
                                       angle=0,
                                       vjust=0.8,
                                       size=16) 
          )+
scale_y_continuous(limits=c(0,2.5))+
ylab("")+
xlab("")
p1

dev.off()
