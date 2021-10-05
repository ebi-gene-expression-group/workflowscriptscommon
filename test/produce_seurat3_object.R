#!/usr/bin/env Rscript
suppressPackageStartupMessages(require(Seurat))

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])

source(paste0(dirname(script.name),"/../R/seurat_io.R"))


sc_matrix <- Read10X(data.dir = input_path,
                     unique.features = TRUE,
                     gene.column = 2)


seurat_object <- CreateSeuratObject(sc_matrix)

# For Loom export to work
seurat_object <- FindVariableFeatures(object = seurat_object)

write_seurat3_object(seurat_object, format="seurat", output_path = output_path)
