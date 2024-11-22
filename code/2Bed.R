###################################FOR BED FILES#############################################
##Create bed files of the repeat data before consolidating, to compare and visualize the differences after consolidation
###Set the path where your file is saved
library(tidyverse)
library(dplyr)
library(gtools)
setwd("/home/luis/Documentos/Identical repeats project/annotation/colapsed_datasets")

###Load the txt file already modified
gen = read.table("t2t_dir_col.txt", header = FALSE)

##Add column names to the file. If it is the collapsed one add this two names "ida,idb"
colnames(gen)<-c("id","start","end","strand","length",
                 "id.1","start.1","end.1","strand.1","length.1","match","distance","ida","idb")

gen$id2<-gsub("col.*", "", gen$id)
gen$name<-gsub("dir.*", "", gen$id)

names_chr<-unique(gen$id2)
names_chr<-mixedsort(names_chr)



##Be sure that the path that you set is the one where you want all your files to be saved
for (i in 1:24) {
  
  chr<-names_chr[i]
  gen1 = gen %>% filter(grepl(chr,id))
  inv<-as.data.frame(cbind(gen1$name,gen1$start,gen1$end,gen1$id,rep(0,nrow(gen1)),gen1$strand))
  inv1<-as.data.frame(cbind(gen1$name,gen1$start.1,gen1$end.1,gen1$id.1,rep(0,nrow(gen1)),gen1$strand.1))
  ##Add colors to the bed file
  inv$V7 = rep("6,185,174",nrow(gen1))
  inv1$V7 = rep(" 10,182,37 ",nrow(gen1))
  inv_rep<-rbind(inv,inv1)
  inv_rep$V8<-inv_rep$V2
  inv_rep$V9<-inv_rep$V3
  inv_rep<-inv_rep[,c(1,2,3,4,5,6,8,9,7)]
  write.table(inv_rep, file =chr_names[i], sep = "\t", 
              row.names = FALSE, col.names = FALSE, quote = FALSE)
  
}
