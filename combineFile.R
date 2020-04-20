setwd("~/JianyeGe")
myJGfiles <- list.files(pattern = ".*20181129\\.txt$")
footestbar<- list.files(pattern = ".txt$")
myJGdata<-purrr::map(myJGfiles, ~readr::read_delim(file = .,delim = "\t", 
         col_names = c("chr", "LocusStart", "LocusStop", "Locus","chr_1","Pos","ID","Ref","Alt","Qual","Filter","Info")))
names(myJGdata) <- stringr::str_replace(myJGfiles, 
         pattern = "(^ALL\\.chr[:digit:]{1,2}\\.shapeit2_integrated_v1a.GRCH38.20181129)\\.txt$", replacement = "\\1")
myJGdata_comb <- myJGdata %>% purrr::map_dfr(~ .x, .id="Group")

head(grepl("AC=198",myJGdata_comb))

#myJGdata_comb1 <- myJGdata_comb %>% dplyr::select(-c(chr_1)) %>% 
#  separate(Info, into = c("AlleleCount","TotalAlleles","Depth","AlleleFreq",
#                          "EastAsian_AF","European_AF","African_AF","AdMixAmer_AF","SouthAsian_AF"), sep = ";", extra = "drop")

myJGdata_comb %>% 
  separate_rows(Info, sep = ";") %>% 
  separate(Info, into = c("Info", "Numbers"), sep = "=") %>% 
  filter(grepl(".*_AF$", Info)) ->myJGdata_comb1


tidyr::spread(myJGdata_comb1, key = Info, value = Numbers, convert=T) -> myJGdata_comb2
myJGdata_comb2 %>% group_by(Locus) %>% summarise("Count of SNPs" = n())

myJGdata_comb3<-filter(myJGdata_comb2, between (AFR_AF, 0.1,0.9), between(AMR_AF, 0.1,0.9), 
                       between(EAS_AF, 0.1,0.9), between(EUR_AF, 0.1,0.9), between(SAS_AF, 0.1,0.9)) 


myJGdata_comb3<-filter(myJGdata_comb2, between (AFR_AF, 0.05,0.95), 
                       between(AMR_AF, 0.05,0.95), between(EAS_AF, 0.05,0.95), between(EUR_AF, 0.05,0.95), between(SAS_AF, 0.05,0.95)) 

myJGdata_comb2 %>%
  ggplot(aes(x=Locus)) + geom_bar() + theme(axis.text.x = element_text(angle = 45))
 
# working with phase information
Fmyphasedata <- list.files(pattern = "*_all.txt")
myphasedat <-purrr::map(Fmyphasedata, ~readr::read_delim(file=.,delim = "\t",col_names = F))
names(myphasedat) <- stringr::str_replace(Fmyphasedata, pattern = "(.*)\\.txt$", replacement = "\\1")
myphasedat1 <- purrr::map_dfr(myphasedat, ~.x, .id = "Group")
#colnames(myphasedat1)[2:2562]<-c("chr", "LocusStart", "LocusStop", "Locus","chr_1","Pos","ID","Ref","Alt","Qual","Filter","Info",
#                                 "Format",paste0("Ind",1:2548))
sampnames <- as.character(readr::read_delim("samplenames.txt", delim = "\t",col_names = F))

colnames(myphasedat1)[2:2518]<-c("chr", "LocusStart", "LocusStop", "Locus","chr_1","Pos","ID","Ref","Alt","Qual","Filter","Info",
                                 "Format",sampnames[10:2513])
tail(colnames(myphasedat1),2)
myphasedat2<-myphasedat1 %>% 
  dplyr::select(-c(chr_1,ID,Qual,Filter))



# # code to separate and extract phase information - Method 1
myphasedat_10<-myphasedat2[,1:20]
# 
# myphasedat_10Nam <- names(myphasedat_10[11:20])
# myphasedat_10Nam1 <- expand.grid(myphasedat_10Nam, 1:2) %>% unite("V", Var1, Var2, sep = ".") %>%
#   pull() %>% sort()
# 
# myphasedat_10[11:20] %>% unite("v",myphasedat_10Nam) %>%
#   separate(v, myphasedat_10Nam1, convert = T)
# 
# 
# # code to separate and extract phase information - Method 2
# f = function(x) {
#   myphasedat_10 %>% dplyr::select(Pos, x) %>%
#     separate(x, paste0(x,c(".1",".2")))
# }
# 
# names(myphasedat_10)[11:20] %>%
#   map(f) %>%
#   purrr::reduce(left_join, by="Pos") -> myphasedat_10_wide
# 
# myphasedat_10_wide %>% rownames_to_column %>% tidyr::gather(var, value, -rowname) %>% tidyr::spread(rowname, value)
# 
# rownames(myphasedat_10_wide) <- myphasedat_10_wide$Pos # cannot set rownames to tibble

# code to extract phase information and concat as one string to give final phase info

# read in the population info file
readr::read_delim("./../IdsWithSuperpops.tsv", delim = "\t") -> Idswithpop

myphasedat2 %>%
#myphasedat_10 %>% 
  dplyr::select(-c(Group:LocusStop,Pos:Format)) %>% 
  group_by(Locus) %>%
  gather("ID","Phase", -Locus) %>%
  #left_join(Idswithpop, by="ID") %>% 
  separate(Phase, into = c("value1","value2"), sep="[:|]", extra="drop") %>% # -> foo
  mutate(value1 = if_else(value1 > 1, paste0(";",value1,";"),value1), 
         value2 = if_else(value2 > 1, paste0(";",value2,";"), value2)) %>%
  # summarise_at puts them together..so tokenization would
  # have to be done before this step
  # foo %>% filter(value1 == 3 | value2 ==3) %>% modify_at(c("value1","value2"),function(x){paste0(";",x,";")})
  group_by(Locus, ID) %>%
  summarise_at(vars(starts_with('value')),str_c,collapse="") %>%
  gather("Value","Phase", -ID, -Locus) %>%
  left_join(Idswithpop, by="ID") %>% 
  mutate(ID=make.unique(ID)) %>% 
  select(-Value) %>%
  arrange(Locus, ID)-> myphasedat4_final

# calculating frequency of phases per locus
myphasedat6_final <- myphasedat4_final %>% count(Locus, Phase) %>% arrange(Locus, desc(n))
readr::write_delim(myphasedat6_final, path = "./phaseInfo_Snp_STR_PerLocus_tokenized.txt", delim = "\t")

# ploting # of phases per locus
myphasedat6_final %>% ggplot(mapping = aes(x=Locus)) + geom_bar(stat = "count", fill="orange", colour="black")+
  theme_dark()+labs(title = "Number of phases per locus", y = "Frequency of phases" )+
  theme(axis.text.x = element_text(angle = 45, colour = "black"), title = element_text(color = "blue"))

#############################################################################
# different approach where df is nested per locus and map is
# applied with the function extracting the phase info
#############################################################################

extractphase <- function(df){
  df %>%
  dplyr::select(-c(Group:Format)) %>%
  gather("ID","Phase") %>%
  separate(Phase, into = c("value1","value2")) %>% 
  group_by(ID) %>%
  summarise_at(vars(starts_with('value')),str_c,collapse="") %>%
  gather("Value","Phase", -ID) %>%
  left_join(Idswithpop, by="ID") %>%
  mutate(ID=make.unique(ID)) %>% 
  select(-Value) %>%
  arrange(ID)
}
myphasedat3_final<-myphasedat2 %>% 
  group_by(Locus) %>%
  nest() %>% mutate(phase=map(data,extractphase))

# calculating frequency of phases per locus
myphasedat3_final %>% arrange(Locus) %>% mutate(phase=map(phase, function(df){df %>% count(Phase) %>% arrange(desc(n))}))->myphasedat5_final
myphase

# tallying if above formula worked
myphasedat5_final$phase[[1]] %>% tally(n)
myphasedat5_final %>% mutate(total = map(phase, function(df){df %>% tally(n)}))



