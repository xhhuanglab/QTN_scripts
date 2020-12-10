
setwd("path_to_dir")

pdf("diff_strategy_popsize.pdf",6,3)

par( mar=c(2,3,1,2), mgp=c(4.5,1,0))


percentage_data <- read.table("summary_values_for_plotting",header=TRUE,sep="\t")

plot(percentage_data$het_region_size ~ as.numeric(percentage_data$Group) , type="b" , lwd=3 , 
col=rgb(52,180,85,255,max=255), 
pch=19, 
xlab="" , ylab="" ,  
ylim=c(0,1), 
cex.axis=1.5 )

lines(percentage_data$het_region_num ~ as.numeric(percentage_data$Group) , col=rgb(194,53,57,255,max=255), lwd=3 , pch=19 , type="b" )
lines(percentage_data$breakpoint_number ~ as.numeric(percentage_data$Group) , col=rgb(48,101,170,255,max=255) , lwd=3 , pch=19 , type="b" )
lines(percentage_data$het_pct ~ as.numeric(percentage_data$Group) , col=rgb(112,48,160,255,max=255) , lwd=3, pch=19 , type="b" )



#abline(h=seq(0,1,0.2) , col="gray", lwd=0.8)

# Add a legend
legend("topleft", 
  legend = c("het. region size", "No. het. regions","No. breakpoints","het. pct."), 
 # title="No. Individuals",
  col = c(rgb(52,180,85,255,max=255),rgb(194,53,57,255,max=255),rgb(48,101,170,255,max=255),rgb(112,48,160,255,max=255)), 
  box.lty=2, box.lwd=1, box.col="gray",
  pch = 19, 
  bty = "n", 
  pt.cex = 2, 
  cex = 1.5, 
  text.col = "black", 
  horiz = F , 
  inset = c(0.02, 0.02)
)



dev.off()