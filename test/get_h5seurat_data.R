library(Seurat)
library(SeuratData)
library(SeuratDisk)

InstallData("pbmc3k")
data("pbmc3k.final")

args = commandArgs(trailingOnly=TRUE)

SaveH5Seurat(pbmc3k.final, filename = args[1])