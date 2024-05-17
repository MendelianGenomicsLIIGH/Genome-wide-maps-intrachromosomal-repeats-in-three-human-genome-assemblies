###Set the path where your output files from LastZ are saved
###We need to modify the output from lastz, so the consolidation algorithm can work with the data.
###Just a lottle of data wrangling
setwd("/home/luis/Documentos/Identical repeats project/hg19/direct_repeats/mod_outpu/")
###Load the txt file from LastZ
gen = read.table("Inverted_repeats/modified_output/wg_inv_rep_mod.txt", header = FALSE)

###assign names to the columns
colnames(gen)<-c("id","start","end","strand","length",
                 "id.1","start.1","end.1","strand.1","length.1","number","identity","match_wg","idPct","match","gaps")

#calculate the distance. This is important for the consolidation algorithm
for (s in 1:nrow(gen)) {
  gen$distance[s]<-gen$start.1[s]-gen$end[s]
  
}

##remove and modify columns
gen<-gen[,c(1,2,3,4,5,6,7,8,9,10,15,17)]
gen$match<-as.numeric(gen$match)
gen$start<-as.numeric(gen$start)
gen$start.1<-as.numeric(gen$start.1)
gen$end.1<-as.numeric(gen$end.1)
gen$end<-as.numeric(gen$end)

##Create a vector with the names of each chromosome
chr_names<-unique(gen$id)

###Create another vector with the name of the chromosomes indicating wether it is dir(direct) or inv(inverted)
chr_names_extra <- paste(chr_names, "dir", sep="")

##Modify the id & id.1 columns. dir for direct repeats and inv for inverted repeats
gen$id.1<-paste(gen$id.1, "dir", sep="")

##Be sure that the path that you set is the one where you want all your files to be saved
for (i in 1:24) {
  
  chr<-chr_names_extra[i]
  gen1 = gen %>% filter(grepl(chr,id))
  gen1$id = paste0(chr, formatC(1:nrow(gen1), width = 6, format = "d",flag = "0"),"a")
  gen1$id.1 = paste0(chr, formatC(1:nrow(gen1), width = 6, format = "d",flag = "0"),"b")
  write.table(gen1, file =chr, sep = "\t", 
              row.names = FALSE, col.names = FALSE, quote = FALSE)
  
}

###Once you are done, make a cat of all the files

###################################FOR BED FILES#############################################
##Create bed files of the repeat data before consolidating, to compare and visualize the differences after consolidation
###Set the path where your file is saved
setwd("/home/luis/Documentos/Identical repeats project/hg19/direct_repeats/mod_outpu/")

###Load the txt file already modified
gen = read.table("Inverted_repeats/modified_output/wg_inv_rep_mod.txt", header = FALSE)

##Add column names to the file. If it is the collapsed one add this two names "ida,idb"
colnames(gen)<-c("id","start","end","strand","length",
                 "id.1","start.1","end.1","strand.1","length.1","match","distance")

##Create a vector with the names of each chromosome
chr_names<-unique(gen$id)

###Create another vector with the name of the chromosomes indicating wether it is dir(direct) or inv(inverted)
##dircoll or invcoll if it is the collapsed one
chr_names_extra <- paste(chr_names, "dir", sep="")

##Be sure that the path that you set is the one where you want all your files to be saved
for (i in 1:24) {
  
  chr<-chr_names_extra[i]
  gen1 = gen %>% filter(grepl(chr,id))
  gen1$name= paste0(chr_names[i]) 
  
  ###Separate by pair a and pair b
  inv<-as.data.frame(cbind(gen1$name,gen1$start,gen1$end,gen1$id,rep(0,nrow(gen1)),gen1$strand))
  inv1<-as.data.frame(cbind(gen1$name,gen1$start.1,gen1$end.1,gen1$id.1,rep(0,nrow(gen1)),gen1$strand.1))
  
  ##Add colors to the bed file
  inv$V7 = rep("6,185,174",nrow(gen1))
  inv1$V7 = rep(" 10,182,37 ",nrow(gen1))
  
  ##Join and organize the order of the columns
  inv_rep<-rbind(inv,inv1)
  inv_rep$V8<-inv_rep$V2
  inv_rep$V9<-inv_rep$V3
  inv_rep<-inv_rep[,c(1,2,3,4,5,6,8,9,7)]
  
  #Save the bed file
  write.table(inv_rep, file =chr_names[i], sep = "\t", 
              row.names = FALSE, col.names = FALSE, quote = FALSE)
  
}


