# Write Seurat object into different file formats

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
#' > write_seurat_object(tsne_object, format="loom")

write_seurat4_object <- function(seurat_object, format, output_path, verbose = FALSE, assay="RNA", ...){
  if(format == "loom") {
    as.loom(seurat_object, filename = output_path, verbose = verbose, assay = assay)
  } else if(format == "seurat" ) {
    saveRDS(seurat_object, file = output_path)
  } else if(format == "singlecellexperiment") {
    saveRDS(as.SingleCellExperiment(seurat_object, assay=assay), file = output_path)
  } else if(format == "h5Seurat") {
    SaveH5Seurat(seurat_object, filename = output_path, ...)
  } else {
    cat("Format",format,"for output not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}

# Write Seurat 3 object into different file formats.

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

write_seurat3_object <- function(seurat_object, format, output_path, verbose = FALSE, assay="RNA", ...){
  return(write_seurat_object(seurat_object, format, output_path, verbose, assay, ...))
}

# Read Seurat 4 object from different file formats.

#' Currently Loom, Seurat (as RDS), Single Cell Experiment, Matrix (as RDS), h5Seurat and AnnData are supported as output formats.
#' It will fail with an error code 1 if the format is not recognised.
#' 
#' For using the method, you need to have loaded Seurat 3, scater and loomR 
#'
#' @param seurat_object The seurat object to be serialised
#' @param format The file format to write against: "loom", "seurat", "rds_matrix", "anndata" or "singlecellexperiment"
#' @param verbose Only applicable to some formats, defaults to FALSE.
#' @param assay Seurat assay to use, RNA by default.
#' @param loom_normalized_path Path within /layers in loom to find the normalised data.
#' @param loom_scaled_path Path within /layers in loom to find the scaled data.
#'
#' @export
#'
#' @examples
#' > read_seurat3_object(input_file_loom, format="loom")
read_seurat4_object <- function(input_path, format, 
                               ident_for_adata = "louvain", assay="RNA", 
                               loom_normalized_path="/norm_data",
                               loom_scaled_path="/scale_data", ...) {
  if(format == "loom") {
    loom_object <- Connect(filename = input_path, mode = "r")
    return(as.Seurat(loom_object, 
                     assay=assay, 
                     normalized=loom_normalized_path,
                     scaled=loom_scaled_path))
  } else if(format == "seurat") {
    return(readRDS(file = input_path))
  } else if(format == "singlecellexperiment") {
    singlecellexp_object<-readRDS(file = input_path)
    return(as.Seurat(singlecellexp_object, assay=assay, ...))
  } else if(format == "anndata") {
    # Note that convert relies on the file extension of the given file
    if(!endsWith(".h5ad")) {
      cat("If transforming h5ad AnnData to H5Seurat, file needs to end with .h5ad")
      quit(status = 1)
    }
    # create link with correct extension in working directory
    Convert(input_path, dest = "h5seurat", overwrite = TRUE)
    seurat_object <- LoadH5Seurat(sub(".h5ad", "h5seurat", input_path))
    if(! is.null(ident_for_adata)) {
      Idents(seurat_object)<-ident_for_adata  
    }
    return(seurat_object)
  } else if(format == "rds_matrix") {
    return(CreateSeuratObject(readRDS(file = input_path)))
  } else if(format == "h5Seurat") {
    return(LoadH5Seurat(file=input_path, ... ))
  } else {
    cat("Format",format,"for input not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}


# Read Seurat 3 object from different file formats.

#' Currently Loom, Seurat (as RDS), Single Cell Experiment and AnnData are supported as output formats.
#' It will fail with an error code 1 if the format is not recognised.
#' 
#' For using the method, you need to have loaded Seurat 3, scater and loomR 
#'
#' @param seurat_object The seurat object to be serialised
#' @param format The file format to write against: "loom", "seurat" or "singlecellexperiment"
#' @param verbose Only applicable to some formats, defaults to FALSE.
#' @param assay Seurat assay to use, RNA by default.
#' @param loom_normalized_path Path within /layers in loom to find the normalised data.
#' @param loom_scaled_path Path within /layers in loom to find the scaled data.
#'
#' @export
#'
#' @examples
#' > read_seurat3_object(input_file_loom, format="loom")
read_seurat3_object <- function(input_path, format, 
                                ident_for_adata = "louvain", assay="RNA", 
                                loom_normalized_path="/norm_data",
                                loom_scaled_path="/scale_data", ...) {
  return(read_seurat_object(input_path, format, ident_for_adata, assay, loom_normalized_path, loom_scaled_path, ...))
}