suppressPackageStartupMessages(require(Seurat))
suppressPackageStartupMessages(require(SeuratDisk))
suppressPackageStartupMessages(require(scater))

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1]
input_format <- args[2]

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])

source(paste0(dirname(script.name), "/../R/seurat_io.R"))

print(paste0("Reading file ", input_path, " for ", input_format, " conversion to Seurat"))
params <- list(input_path = input_path, format = input_format)
if (input_format == "singlecellexperiment") {
  params$counts <- "counts"
  params$data <- "logcounts"
} else if (input_format == "loom") {
  params$loom_normalized_path <- NULL
  params$loom_scaled_path <- NULL
} else if (input_format == "seurat") {
  params$update_seurat_object <- TRUE
}

so <- do.call(read_seurat4_object, params)
print(paste0("Read file."))

ext <- list(loom = "loom", singlecellexperiment = "sce.rds", seurat = "rds", h5seurat = "h5seurat", anndata = "h5ad")

for (format in c("loom", "singlecellexperiment", "seurat", "anndata", "h5seurat")) {
  print(paste0("Writing file to format ", format))
  write_seurat4_object(so, format = format, output_path = paste0(input_path, ".", ext[format]))
}
