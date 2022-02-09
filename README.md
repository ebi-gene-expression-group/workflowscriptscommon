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

Note 1: To support Loom IO from Seurat 3 you might need to use it with a conda installation using r-base >=4.0. There are issues between R 3.6 and some of the libraries when installing r-loom.

Note 2: r-loom (used by Seurat 3 IO functions) only supports Loom files with specification version < 3.0. You could pass the `skip.validate = TRUE` option to connect at your own risk when reading newer Loom, but there is no guarantee that later steps will work. For reading newer loom the best option is to probably use Seurat 4 and SeuratDisk.

Note 3: Seurat 4 AnnData reading is currently not working due to a conflict in libgfortran between R 4.x and hdf5 lib, see [here](https://github.com/mojaveazure/seurat-disk/issues/30#issuecomment-914726678) for more details. 
