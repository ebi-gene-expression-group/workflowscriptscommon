suppressPackageStartupMessages(require(Seurat))
suppressPackageStartupMessages(require(SeuratData))
suppressPackageStartupMessages(require(SeuratDisk))

InstallData("pbmc3k")
data("pbmc3k.final")

args = commandArgs(trailingOnly=TRUE)

saveRDS(pbmc3k.final, args[1])