#install.packages("UpSetR")

library(UpSetR)

setwd("path_to_dir")

data <- read.table("Final_Final_99QTG_matrix",header=T,sep="\t")

upset(data,
nsets = 30,
mainbar.y.label = " ",
text.scale = c(1.5, 1.5, 1.5, 1.5, 2, 2),
sets = c("JAP_dom", "JAP_imp", "IND_dom","IND_imp"), 
mb.ratio = c(0.7, 0.3),
order.by = "freq",keep.order=TRUE
)