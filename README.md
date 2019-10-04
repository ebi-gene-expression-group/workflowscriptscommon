# Common R functions for wrapper scripts for workflows

An R package to contain accessory functions for packages defining wrapper scripts for workflows related to single-cell analysis.

The package can be installed using devtools:

```
devtools::install_github("ebi-gene-expression-group/workflow-scripts-common")
```

To use the Seurat 3 I/O methods you need to have installed Seurat 3, loomR and Scater (for Seurat, loom, anndata and single cell experiment support). The recommended way is through:

```
conda create -n seurat-with-io r-seurat r-loom bioconductor-scater
```