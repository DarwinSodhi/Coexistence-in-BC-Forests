####script to create light data for Ph.D. 
rm(list=ls()) # remove everything currently held in the R memory
options(stringsAsFactors=FALSE)
setwd("~/Documents/GitHub/Coexistence-in-BC-Forests/Analyses/")

library(vegan)
library(tidyverse)
library(dbplyr)
library(tidyr)
library(reshape2)
library(data.table)
library(tibble)
library(dplyr)

#########################################################
#species-ambeint readings
#########################################################

LiCordatafinal <- read_csv("input/LiCordatafinalpsp.csv")

LiCordata_adult <- LiCordatafinal[LiCordatafinal$Species != 'AMBIENT',]

LiCordata_adult1 <- LiCordatafinal[LiCordatafinal$Species == 'AMBIENT',]

LiCordata_adult <- LiCordata_adult[,c(1:2,420,422,441)]
LiCordata_adult[, c(3:4)] <- sapply(LiCordata_adult[, c(3:4)], as.numeric)

LiCordata_adult1 <- LiCordata_adult1[,c(1:2,420,422,441)]
LiCordata_adult1[, c(3:4)] <- sapply(LiCordata_adult1[, c(3:4)], as.numeric)

LiCordata_adult <- LiCordata_adult[order(LiCordata_adult$Time),]

LiCordata_adult <- LiCordata_adult[-54,]

#makes rowsname species names 
rownames(LiCordata_adult) <- make.names(LiCordata_adult$Species, unique = TRUE)

#repeats each ambient reading three times in a new dataset
LiCordata_adult1 <- LiCordata_adult1 %>% slice(rep(1:n(), each = 3))

path <- unique(names(LiCordata_adult[,(3:4)]))
k2 <- (matrix(NA, nrow= nrow(LiCordata_adult[,(3:4)]), ncol = ncol(LiCordata_adult[,(3:4)])))
colnames(k2) <- colnames(LiCordata_adult[,(3:4)])
row.names(k2) <- rownames(LiCordata_adult)
for (n in 1:length(path)){ 
  k2[,n]<- as.matrix(LiCordata_adult[,(3:4)][,n] - LiCordata_adult1[,(3:4)][,n] + abs(min(LiCordata_adult1[,(3:4)][,n])))
}  
community_matrix <- as.matrix(k2) #creates matrix
example_NMDS=metaMDS(community_matrix, k=3, autotransform = FALSE) #runs NMDS
filename <- paste("output/NMDS_RambspcPSPST2",".pdf", sep = )
pdf(file= filename)
write.csv(k2, filename)
stressplot(example_NMDS)
plot(example_NMDS)
orditorp(example_NMDS,display="sites",cex= 0.5,air= 0.3)#labels points as best as we can
dev.off()

k2 <- as.data.frame(k2)
k2 <- rownames_to_column(k2)
write_csv(k2, "NMDS_RambspcPSPST2.csv")
