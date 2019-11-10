# Write Seurat 3 object into different file formats

#' Currently Loom and Seurat (as RDS) as supported as output formats.
#' It will fail with an error code 1 if the format is not recognised.
#' 
#' For using the method, you need to have loaded Seurat 3, scater and loomR 
#'
#' @param seurat_object The seurat object to be serialised
#' @param format The file format to write against: "loom", "seurat" or "singlecellexperiment"
#' @param assay The Seurat assay to use for writing; "RNA" by default.
#' @param verbose Only applicable to some formats, defaults to FALSE.
#'
#' @export
#'
#' @examples
#' > write_seurat3_object(tsne_object, format="loom")

write_seurat3_object <- function(seurat_object, format, output_path, verbose = FALSE, assay="RNA"){
  if(format == "loom") {
    as.loom(seurat_object, filename = output_path, verbose = verbose, assay = assay)
  } else if(format == "seurat" ) {
    saveRDS(seurat_object, file = output_path)
  } else if(format == "singlecellexperiment") {
    saveRDS(as.SingleCellExperiment(seurat_object, assay=assay), file = output_path)
  } else {
    cat("Format",format,"for output not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}

# Read Seurat 3 object from different file formats

#' Currently Loom, Seurat (as RDS), Single Cell Experiment and AnnData are supported as output formats.
#' It will fail with an error code 1 if the format is not recognised.
#' 
#' For using the method, you need to have loaded Seurat 3, scater and loomR 
#'
#' @param seurat_object The seurat object to be serialised
#' @param format The file format to write against: "loom", "seurat" or "singlecellexperiment"
#' @param verbose Only applicable to some formats, defaults to FALSE.
#'
#' @export
#'
#' @examples
#' > read_seurat3_object(input_file_loom, format="loom")
read_seurat3_object <- function(input_path, format, ident_for_adata = "louvain") {
  if(format == "loom") {
    loom_object <- connect(filename = input_path, mode = "r")
    return(as.Seurat(loom_object))
  } else if(format == "seurat") {
    return(readRDS(file = input_path))
  } else if(format == "singlecellexperiment") {
    singlecellexp_object<-readRDS(file = input_path)
    return(as.Seurat(singlecellexp_object))
  } else if(format == "anndata") {
    seurat_object<-ReadH5AD(file = input_path)
    if(! is.null(ident_for_adata)) {
      Idents(seurat_object)<-ident_for_adata  
    }
    return(seurat_object)
  } else {
    cat("Format",format,"for input not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}