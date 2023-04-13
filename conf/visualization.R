# Load packages
library(tidyverse)
library(ggplot2)

# Read the krona report from SOURMASH TAX METAGENOME
SRR19888796 <- read.table('/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/sourmash_results/tax_metagenome/SRR19888796_tax.krona.tsv', header=TRUE, sep="\t")
SRR19888810 <- read.table('/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/sourmash_results/tax_metagenome/SRR19888810_tax.krona.tsv', header=TRUE, sep="\t")
SRR19888832 <- read.table('/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/sourmash_results/tax_metagenome/SRR19888832_tax.krona.tsv', header=TRUE, sep="\t")

# Using add_column with sample ID
SRR19888796 <- SRR19888796 %>%
  add_column(sampleID = "SRR19888796")

SRR19888810 <- SRR19888810 %>%
  add_column(sampleID = "SRR19888810")

SRR19888832 <- SRR19888832 %>%
  add_column(sampleID = "SRR19888832")

# merge 3 krona output from 3 sample
data.frame <- rbind(SRR19888796, SRR19888810, SRR19888832)
dim(data.frame)
table(data.frame$sampleID)
data.frame <- data.frame[!(data.frame$species == "unclassified"), ]


# barplot geom_bar official 
ggplot(data.frame, aes(fill=phylum, y=fraction, x=sampleID)) +
  geom_bar(position="fill", stat="identity") +
  xlab("sampleID") +
  ylab("fraction") +
  ggtitle("Phylum-level Metagenomic Data") +
  ## color 
  scale_fill_manual(values = c("darkblue", "darkgoldenrod1", "darkseagreen", "darkorchid", "darkolivegreen1", "lightskyblue", "darkgreen", "deeppink", "khaki2", "firebrick", "brown1", "darkorange1", "cyan1", "royalblue4", "darksalmon", "darkblue",
                             "royalblue4", "dodgerblue3", "steelblue1", "lightskyblue", "darkseagreen", "darkgoldenrod1", "darkseagreen", "darkorchid", "darkolivegreen1", "brown1", "darkorange1", "cyan1", "darkgrey")) +
  theme(legend.position="bottom") + guides(fill=guide_legend(nrow=5)) +
  coord_flip()  #convert vertical --> horizontal barplot