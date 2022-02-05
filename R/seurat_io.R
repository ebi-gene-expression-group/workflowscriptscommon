
#' Loads packages for seurat4 IO based on a list of formats given
#'
#' Reading/writing from/to different formats in Seurat 4 requires various packages.
#' To avoid loading them all everytime, this convenience function deals with this part.
#'
#' @param formats Either a single string or a list of strings with one or more of the following formats: loom, singlecellexperiment, h5seurat, anndata
#'
#' @examples
#' load_seurat4_packages_for_format(formats = c("loom", "anndata"))
#' load_seurat4_packages_for_format(formats = "loom")
#'
#' @export
load_seurat4_packages_for_format <- function(formats) {
  if ("singlecellexperiment" %in% formats ) {
    suppressPackageStartupMessages(require(scater))
  }
  if ("h5seurat" %in% formats | "anndata" %in% formats | "loom" %in% formats ) {
    suppressPackageStartupMessages(require(SeuratDisk))
  }
}

#' Change completely empty columns to "NONE
#'
#' For loom output we need to check if metadata columns are
#' completely empty or not (all values "" for a column), if they are we need to add a non-zero
#' length string instead. This avoids errors like:
#' Error in self$set_size(size) : HDF5-API Errors:
#'    error #000: H5T.c in H5Tset_size(): line 2376: size must be positive
#'
#' @param seurat_object the object for which metadata to check
#'
#' @export
#'
#' @return the fixed seurat object with "NONE" in all columns that had only empty values.
change_completely_empty_metadata_cols <- function(seurat_object) {
  so <- seurat_object
  empty <- c()
  for (c in 1:ncol(so@meta.data)) {
    u <- unique(so@meta.data[, c])
    if (length(u) == 1 && (toString(u) == "" || is.na(u))) {
      print(paste0("Column ", colnames(so@meta.data)[c], " is all empty or NA, setting to NONE"))
      empty <- append(empty, c)
    }
  }
  if (length(empty) > 0)
    so@meta.data[, empty] <- "NONE"
  return(so)
}

#' Write Seurat object into different file formats
#'
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
#' @examples
#' write_seurat_object(tsne_object, format="loom")
write_seurat4_object <- function(seurat_object, format, output_path, verbose = FALSE, assay="RNA", ...){
  if(format == "loom") {
    as.loom(seurat_object, filename = output_path, verbose = verbose)
  } else if (format == "seurat") {
    saveRDS(seurat_object, file = output_path)
  } else if (format == "singlecellexperiment") {
    saveRDS(as.SingleCellExperiment(seurat_object, assay=assay), file = output_path)
  } else if (format == "h5seurat") {
    SaveH5Seurat(seurat_object, filename = output_path, ...)
  } else if (format == "anndata") {
    tmpFile <- gsub(pattern = ".h5ad", replacement = ".h5seurat", x = output_path)
    SaveH5Seurat(seurat_object, filename = tmpFile)
    Convert(tmpFile, dest = "h5ad")
    if (file.exists(tmpFile)) {
      file.remove(tmpFile)
    }
  } else {
    cat("Format", format, "for output not recognised, failing now.", file = stderr())
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
#' @param ... additional arguments to as.loom or as.SingleCellExperiment, depending on input format
#'
#' @export
#'
#' @examples
#' write_seurat3_object(tsne_object, format="loom")
write_seurat3_object <- function(seurat_object, format, output_path, verbose = FALSE, assay="RNA", ...){
  if (format == "loom") {
    if (length(seurat_object@assays[[assay]]@var.features) == 0) {
      # Find variable features needs to be calculated for a loom export
      # if not already there.
      cat("Writing to Loom requires @assays$", assay, "@var.features to be set... running FindVariableFeatures with defaults.")
      seurat_object <- FindVariableFeatures(seurat_object, assay=assay)
    }
    seurat_object <- change_completely_empty_metadata_cols(seurat_object)
    as.loom(seurat_object, filename = output_path, verbose = verbose, assay = assay, ...)
  } else if (format == "seurat") {
    saveRDS(seurat_object, file = output_path)
  } else if (format == "singlecellexperiment") {
    saveRDS(as.SingleCellExperiment(seurat_object, assay=assay, ...), file = output_path)
  } else {
    cat("Format", format, "for output not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}

# Read Seurat 4 object from different file formats.

#' Currently Loom, Seurat (as RDS), Single Cell Experiment, Matrix (as RDS), h5Seurat and AnnData are supported as output formats.
#' It will fail with an error code 1 if the format is not recognised.
#'
#' For using the method, you need to have loaded Seurat 3, scater and loomR.
#'
#' Currently, due to conflicts in libgfortran version, reading AnnData for
#' Seurat 4 is not working.
#'
#' @param seurat_object The seurat object to be serialised
#' @param format The file format to write against: "loom", "seurat", "rds_matrix", "anndata" or "singlecellexperiment"
#' @param verbose Only applicable to some formats, defaults to FALSE.
#' @param assay Seurat assay to use, RNA by default.
#' @param loom_normalized_path Path within /layers in loom to find the normalised data.
#' @param loom_scaled_path Path within /layers in loom to find the scaled data.
#' @param ... passed to Loom -> as.Seurat, singlcellexperiment -> as.Seurat, CreateSeuratObject or LoadH5Seurat, depending on input format.
#'
#' @export
#'
#' @examples
#' read_seurat4_object(input_file_loom, format="loom")
read_seurat4_object <- function(input_path, format,
                               ident_for_adata = "louvain", assay="RNA",
                               update_seurat_object = FALSE, ...) {
  if (format == "loom") {
    loom_object <- Connect(filename = input_path, mode = "r")
    return(as.Seurat(loom_object,
                     assay = assay, ...))
  } else if (format == "seurat") {
    so <- readRDS(file = input_path)
    if (update_seurat_object) {
      so <- UpdateSeuratObject(so)
    }
    return(so)
  } else if (format == "singlecellexperiment") {
    singlecellexp_object <- readRDS(file = input_path)
    return(as.Seurat(singlecellexp_object, assay=assay, ...))
  } else if (format == "anndata") {
    # Currently reading AnnData for Seurat 4 is not working due to
    # conflicts with the libgfortran library between hdf5 lib and R 4.0
    # But this is the logic that would work.
    # Note that convert relies on the file extension of the given file
    if (!endsWith(input_path, ".h5ad")) {
      cat("If transforming h5ad AnnData to H5Seurat, file needs to end with .h5ad")
      quit(status = 1)
    }
    # create link with correct extension in working directory
    Convert(input_path, dest = "h5seurat", overwrite = TRUE, assay=assay)
    seurat_object <- LoadH5Seurat(sub(".h5ad$", ".h5seurat", input_path))
    if (!is.null(ident_for_adata)) {
      Idents(seurat_object)<-ident_for_adata
    }
    return(seurat_object)
  } else if (format == "rds_matrix") {
    return(CreateSeuratObject(readRDS(file = input_path), ...))
  } else if (format == "h5seurat") {
    return(LoadH5Seurat(file = input_path, ... ))
  } else {
    cat("Format", format, "for input not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}

#' Read multiple Seurat 4 objects to a list
#'
#' Receives a list of paths to seurat objects or accepted formats (a single format for all paths is expected)
#' and produced a list of those seurat object or their converted form into Seurat objects.
#'
#' @param input_path_list The list of paths to read, all in the same format. If NULL is given, it returns null instead of list. This can be a string with paths comma separated, or an actual R list with paths.
#' @param format A single string for either "loom", "seurat", "singlecellexperiment", "anndata", "h5seurat" or "rds_matrix". Defaults to "seurat".
#' @param ident_for_adata If using format "anndata", which ident should be used. Defaults to "louvain".
#' @param assay Which assay to use, defaults to "RNA"
#' @param update_seurat_object Boolean to whether update the read seurat object or not.
#' @param ... passed to read_seurat4_object, used based on the format set.
#'
#' @return A list of Seurat objects. Can be NULL if the passed list of paths is NULL.
#'
#' @export
read_multiple_seurat4_objects <- function(input_path_list, format = "seurat",
                                        ident_for_adata = "louvain", assay="RNA",
                                        update_seurat_object = FALSE, ...) {
  if (is.null(input_path_list)) {
    # This is a convenience for our automated setup
    warning("Input path list given to read_multiple_seurat4_objects is null, returning a null instead of list.")
    return(NULL)
  }

  if (is.list(input_path_list)) {
    inputs <- input_path_list
  } else {
    inputs <- strsplit(input_path_list,split = ",")[[1]]
  }
  # Assumes that all datasets are in the same format, in the future we could check if format is a list or a single value
  objects_list <- list()
  for (input in inputs) {
    seurat_object <- read_seurat4_object(input_path = input, format = format, ...)
    append(objects_list, seurat_object) -> objects_list
  }

  return(objects_list)
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
#' @param ... passed to Loom -> as.Seurat, singlcellexperiment -> as.Seurat, CreateSeuratObject or ReadH5AD, depending on input format.
#'
#' @export
#'
#' @examples
#' read_seurat3_object(input_file_loom, format="loom")
read_seurat3_object <- function(input_path, format,
                                ident_for_adata = "louvain", assay="RNA",
                                loom_normalized_path="/norm_data",
                                loom_connect_skip_validate=TRUE,
                                loom_scaled_path="/scale_data", ...) {
  if (format == "loom") {
    loom_object <- connect(filename = input_path,
                           mode = "r+",
                           skip.validate = loom_connect_skip_validate)
    return(as.Seurat(loom_object,
                     assay = assay,
                     normalized = loom_normalized_path,
                     scaled = loom_scaled_path, ...))
  } else if (format == "seurat") {
    return(readRDS(file = input_path))
  } else if (format == "singlecellexperiment") {
    singlecellexp_object <- readRDS(file = input_path)
    return(as.Seurat(singlecellexp_object, assay=assay, ...))
  } else if (format == "anndata") {
    seurat_object <- ReadH5AD(file = input_path, ...)
    if (!is.null(ident_for_adata)) {
      Idents(seurat_object) <- ident_for_adata
    }
    return(seurat_object)
  } else {
    cat("Format ", format, " for input not recognised, failing now.", file = stderr())
    quit(status = 1)
  }
}
