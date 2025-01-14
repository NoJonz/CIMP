# import and process data
library(DESeq2)
library(ggplot2)
library(dplyr)
library(ggpubr)
setwd("C:/Users/JonFe/Desktop/diff_exp")
posnegcountData <- read.table("output/countData-posneg.txt", sep="\t", header=TRUE)
colnames(posnegcountData) <- gsub("\\.", "-", colnames(posnegcountData))
posnegcolData <- read.table("output/colData-posneg.txt", sep="\t", header=TRUE)
dds <- DESeqDataSetFromMatrix(countData=posnegcountData, colData=posnegcolData, design=~class, tidy=TRUE)
dds$class <- relevel(dds$class, "CIMPnegative" )
dds <- DESeq(dds)
# get and process results
res <- results(dds, independentFiltering=FALSE, tidy=TRUE)
res <- na.omit(res)
res <- res[res$padj < .05, ]
# output results
write.table(res, "output/posvsnegDEA.csv", row.names=FALSE, sep=",")
# sort by fdr
fdrasc <- res[order(res$log2FoldChange),]
fdrasc <- head(fdrasc,15)
row.names(fdrasc) <- 1:15
fdrdesc <- res[order(-res$log2FoldChange),]
fdrdesc <- head(fdrdesc,15)
row.names(fdrdesc) <- 1:15
# plot gene expression
ascplots <- vector("list",10)
for(i in 1:15){
	myplot <- plotCounts(dds, gene=fdrasc$row[i], intgroup="class", returnData=TRUE) %>% ggplot(aes(class, count)) + geom_boxplot(aes(fill=class)) + scale_y_log10() + ggtitle(strsplit(fdrasc$row[i],"[|]")[[1]][1])
	ascplots[[i]] <- myplot
}
ggarrange(plotlist=ascplots,ncol=3,nrow=5)
ggsave("output/posnegasc.png")
descplots <- vector("list",10)
for(i in 1:15){
	myplot <- plotCounts(dds, gene=fdrdesc$row[i], intgroup="class", returnData=TRUE) %>% ggplot(aes(class, count)) + geom_boxplot(aes(fill=class)) + scale_y_log10() + ggtitle(strsplit(fdrdesc$row[i],"[|]")[[1]][1])
	descplots[[i]] <- myplot
}
ggarrange(plotlist=descplots,ncol=3,nrow=5)
ggsave("output/posnegdesc.png")

