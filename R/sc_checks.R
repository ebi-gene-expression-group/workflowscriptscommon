#' Check metadata variables against Seurat object
#'
#' @param seurat_object An object of type 'Seurat'
#' @param varnames Character vector of metadata names
#'
#' @return No return- function will stop if supplied metadata list is not in object.

check_metadata <- function(seurat_object, varnames){
  for ( vn in varnames ){
    if (! vn %in% colnames(seurat_object@meta.data) ){
      stop(paste(paste0("'", vn, "'"), 'not a valid metadata variable for this object'))
    }
  }
}

#' Check specified cells against object
#'
#' @param cell_names Character vector of cell names
#' @param seurat_object An object of type 'Seurat'
#'
#' @return No return- function will stop if supplied cell list is not in object.

check_cells <- function(cell_names, seurat_object){
  if (! all(cell_names %in% seurat_object@cell.names)){
    stop("Some specified cells not present in Seurat object")
  }
}
