library(tibble)
library(tidyverse)
library(seqinr)
library(RecordLinkage)
library(stringi)
library(Biostrings)
setwd("/home/luis/Documentos/Identical repeats project/")
#load dataframe
#gen = read.table("direct_repeats/gen_wide_dir2_wo_out.txt", header = TRUE)
gen = read.table("T2T/direct_repeats/modified_output/chrYdirmod.txt", header = TRUE)
#load fasta sequence of the desired chromosome
chr_seq = read.fasta(file = "chroms/xx23", as.string = TRUE)
#filter columns that belong to a specific chromosome, just change the number
colnames(gen)<-c("id","start","end","strand","length","id.1","start.1","end.1","strand.1","length.1","match","distance")
chr = gen %>% filter(grepl("^chrYdir",id))

#choose max distance between end[i] and start[j], it is arbitrary
dist = 2500

#create new data frame to write new collapsed pairs
data = data.frame(id = character(), start = double(), end = double(), strand = character(),
                  len = double(), id.1 = character(), start.1 = double(), end.1 = double(),
                  strand.1 = character(), len.1 = double(), match... = double(), distance = double(),
                  ida = character(), idb = character())


a = 1
#idx = 
for (i in 1:nrow(chr)){
  if (i == nrow(chr)){
    break
  }
  if (i == 1){
    idx = 1
  }
  # else{
  #   idx = j
  # }
  if (idx >= nrow(chr)){
    data = rbind(data, cbind(chr[idx,],"ida"="not","idb"="not"))
    break
  }
  #print(as.numeric(i))
  new_line = chr[idx,]
  for (j in as.numeric(idx)+1:nrow(chr)){
    print(paste0("idx",idx))
    print(paste0("j",j))
    if (j > nrow(chr)){
      if("ida" %in% names(new_line)){
        data = rbind(data, new_line)
      }
      stop()
    }
    if (idx >= nrow(chr)){
      data = rbind(data, cbind(chr[idx,],"ida"="not","idb"="not"))
      break
    }
    coord = sort(c(a_s = new_line$start, a_e = new_line$end, b_s = new_line$start.1, b_e = new_line$end.1,
                   a1_s = chr$start[j], a1_e = chr$end[j], b1_s = chr$start.1[j], b1_e = chr$end.1[j]))
    
    #now that we have ordered the coordinates, we need to divide the regions in 2 main
    #cases, overlapping regions or separated regions, in the 1st part i'll address
    #the overlapping regions
    #1. Overlapping regions, since we have 2 pairs of sequences (a-b, a'-b'), we
    #have 8 coordinates. To check if a region overlaps with another, we have named 
    #the coordinates by their start (s) or end (e); then, if there are overlaps,
    #we should find that one (or both) s or e is surrounded by a pair of s-e, then part
    #of that sequence is overlapped (example: a_s...a1_s...a_e, a_s...a1_s...a1_e...a_e)
    #so, how to check if a region is overlapped? with the help of the names!
    #since we entered the names in an arbitrary order corresponding to a-b,a'-b',
    #we can make use of this by checking an order just like the examples above
    print(coord)
    print("inicio")
    # if (j == 250){
    #   stop()
    # }
    #1st case, a_s...a1_s...a_e 
    if (which(names(coord) == "a1_s") <= which(names(coord) == "a_e") && 
        which(names(coord) == "a1_s") >= which(names(coord) == "a_s")){
      new_start = new_line$start #unname(coord[which(names(coord) == "a_s")])
      new_end = max(new_line$end, chr$end[j]) #it could be within the same boundary or the limit, so just select the biggest end
    }
    #2nd case, a1_s...a_s...a1_e
    else if (which(names(coord) == "a_s") <= which(names(coord) == "a1_e") && 
             which(names(coord) == "a_s") >= which(names(coord) == "a1_s")){
      new_start = chr$start[j]
      new_end = max(new_line$end, chr$end[j])
    }
    #no overlap in a-a_1, so check if the distance is correct for a a_s-a_e...a1_s-a1_e
    #to check the distance, we can substract them)
    else if (abs(coord[which(names(coord) == "a1_s")] - coord[which(names(coord) == "a_e")]) <= dist){
      new_start = min(coord[which(names(coord) == "a_s")],coord[which(names(coord) == "a1_s")])
      new_end = max(coord[which(names(coord) == "a_e")],coord[which(names(coord) == "a1_e")])
    }
    #we break assuming that if this pair did not overlap, then the 
    #following will not either
    else{
      print("hola1")
      if ("ida" %in% names(new_line)){
        data = rbind(data, new_line)
      }
      else{
        print("aquitoi1")
        data = rbind(data, cbind(new_line, "ida" = "not", "idb" = "not"))
      }
      idx = j 
      break 
    }
    #now for b's
    print("now b's")
    #3rd case, b_s...b1_s...b_e
    if (which(names(coord) == "b1_s") <= which(names(coord) == "b_e") && 
        which(names(coord) == "b1_s") >= which(names(coord) == "b_s")){
      new_start.1 = new_line$start.1
      new_end.1 = max(new_line$end.1, chr$end.1[j])
    }
    #4th case, b1_s...b_s...b1_e
    else if (which(names(coord) == "b_s") <= which(names(coord) == "b1_e") && 
             which(names(coord) == "b_s") >= which(names(coord) == "b1_s")){
      new_start.1 = chr$start.1[j]
      new_end.1 = max(new_line$end.1, chr$end.1[j])
    }
    #no overlap in b-b_1, so check if the distance is correct for b b_s-b_e...b1_s-b1_e
    #or for the distance for b1_s-b1_e...bs_be
    #to check the distance, we can substract them)  
    else if (abs(coord[which(names(coord) == "b1_s")] - coord[which(names(coord) == "b_e")]) <= dist ||
             abs(coord[which(names(coord) == "b_s")] - coord[which(names(coord) == "b1_e")]) <= dist){
      new_start.1 = min(coord[which(names(coord) == "b_s")],coord[which(names(coord) == "b1_s")])
      new_end.1 = max(coord[which(names(coord) == "b_e")],coord[which(names(coord) == "b1_e")])
    }
    else{
      print("hola2")
      if ("ida" %in% names(new_line)){
        data = rbind(data, new_line)
      }
      else{
        print("aquitoi1")
        data = rbind(data, cbind(new_line, "ida" = "not", "idb" = "not"))
      }
      idx = j 
      break 
    }
    #if you are here it means you can collapse until now (only by base position)
    ida = chr$id[idx]
    idb = chr$id[j]
    #obtain distance between new pairs:
    d = new_start.1 - new_end
    seqa = str_sub(chr_seq[1],new_start,new_end)
    seqb = str_sub(chr_seq[1],new_start.1,new_end.1)
    if (chr$strand.1[j] == "-"){
      #we need the reverse complement of this string
      seqb = stri_reverse(chartr("acgtACGT", "tgcaTGCA", seqb))
    }
    print("voy aqui")
    m = levenshteinSim(seqa, seqb)*100
    if (m < 80){
      print("no_homo")
      #if there is no homology, then only add the last repeat compared
      #if it does not exist already 
      # idx = j + 1
      data = rbind(data, cbind(chr[j,], "ida" = "not", "idb" = "not"))
      next
    }
    else{
      #if we get here then it means that we can try another collapse
      new_line = data.frame(id = paste0("chrYdirdup", formatC(a, width = 6, format = "d",flag = "0"),"a"),
                            start = new_start, end = new_end, strand = "+", length = new_end - new_start + 1,
                            id.1 = paste0("chrYdirdup", formatC(a, width = 6, format = "d",flag = "0"),"b"),
                            start.1 = new_start.1, end.1 = new_end.1, strand.1 = "+",
                            length.1 = new_end.1 - new_start.1 + 1, match = m,
                            distance = d, ida = ida, idb = idb)
      print(new_line)
      #we can try and collapse this line with the next chr repeat,
      #so we indicate to change indexes
      #idx = j + 1
      next
    }
  }
}

chr=data[,1:12]
#code to change ids (for a and b repeats); just change chr number and repeat direction
data$id = paste0("chrYdircoll", formatC(1:nrow(data), width = 6, format = "d",flag = "0"),"a")
data$id.1 = paste0("chrYdircoll", formatC(1:nrow(data), width = 6, format = "d",flag = "0"),"b")


#keep or discard repeats with negative distance
#if the overlapped distance is palindromic, keep the repeat
#if not, discard
#chr_seq = read.fasta(file = "chr/chr25.fa", as.string = TRUE)
#data = read.table("./collapses/chr25dircoll.txt", header = TRUE)
porsi<-data
#data<-porsi
data_pal = data %>% filter(distance <= 0)
for (x in 1:nrow(data_pal)){
  seq_ovrlp_bs_ae = str_sub(chr_seq[1],data_pal$start.1[x],data_pal$end[x])
  seq_ovrlp_rvrse = stri_reverse(seq_ovrlp_bs_ae)
  if (seq_ovrlp_bs_ae != seq_ovrlp_rvrse){
    #if we get here it means the sequence is NOT palindrome
    #then remove from data
    data = data[-which(data$id == data_pal$id[x]),]
  }
}
#13464
#code to change ids (for a and b repeats); just change chr number and repeat direction
data$id = paste0("chrYdircoll", formatC(1:nrow(data), width = 6, format = "d",flag = "0"),"a")
data$id.1 = paste0("chrYdircoll", formatC(1:nrow(data), width = 6, format = "d",flag = "0"),"b")
write.table(data, file ="T2T/direct_repeats/colapsos/chrYdircol.txt", sep = "\t", 
            row.names = FALSE, col.names = FALSE, quote = FALSE)


####Run this part before the collapsing one only if you are workin with direct repeats
#Do not run this part for inverted repeats
data_pal = chr %>% filter(distance <= 0)
for (x in 1:nrow(data_pal)){
  seq_ovrlp_bs_ae = str_sub(chr_seq[1],data_pal$start.1[x],data_pal$end[x])
  seq_ovrlp_rvrse = stri_reverse(seq_ovrlp_bs_ae)
  if (seq_ovrlp_bs_ae != seq_ovrlp_rvrse){
    #if we get here it means the sequence is NOT palindrome
    #then remove from data
    chr = chr[-which(chr$id == data_pal$id[x]),]
  }
}
chr$id = paste0("chrYdir", formatC(1:nrow(chr), width = 6, format = "d",flag = "0"),"a")
chr$id.1 = paste0("chrYdir", formatC(1:nrow(chr), width = 6, format = "d",flag = "0"),"b")