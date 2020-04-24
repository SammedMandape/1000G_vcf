library(tidyverse)
library(dplyr)
library(rlang)
dataDir = "Homopolymeric_region"
hpFile <- Sys.glob(paste(dataDir,"*.bed", sep = "/"))



inFile <- function(x){
  inFile1 <- readr::read_delim(x, delim = "\t", col_names = c("chr","startP", "endP",
                                              "Locus", "chr_1","startOrig","endOrig","HomoPol"))
  inFile1$FileName <- x
  return(inFile1)
  }

hpListFile <- map(hpFile, inFile)
map(hpListFile, 
    function(x){
      if(nrow(x)!=0){     # or !is.null(x)
        paste0(x$FileName[1],".final") -> y
        x %>% 
          mutate(HomopolymerLen = endP - startP) %>%
          select(-c(chr_1:endOrig)) %>%
          arrange(desc(HomopolymerLen)) %>%
          write_tsv(path = y)
          
      }
    }
    ) 


