suppressPackageStartupMessages(require(Seurat))
suppressPackageStartupMessages(require(SeuratData))
suppressPackageStartupMessages(require(SeuratDisk))

InstallData("pbmc3k")
data("pbmc3k.final")

args = commandArgs(trailingOnly=TRUE)

SaveH5Seurat(pbmc3k.final, filename = args[1])