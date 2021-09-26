suppressPackageStartupMessages(require(Seurat))
suppressPackageStartupMessages(require(SeuratDisk))
suppressPackageStartupMessages(require(scater))  

args = commandArgs(trailingOnly=TRUE)
input_paths = args[1]
input_format = args[2]
output = args[3]

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])

source(paste0(dirname(script.name),"/../R/seurat_io.R"))

inputs <- unlist(strsplit(input_paths, split = ","))

seurat_objects <- read_multiple_seurat4_objects(input_path_list = inputs, format = input_format)

if( length(inputs) != length(seurat_objects) ) {
  message("List of seurat objects doesn't match list of inputs given")
  q(status = 1)
}

saveRDS(seurat_objects, file = output)

