conda env create -f test_environment.yml
eval "$(conda shell.bash hook)"
conda activate test-wsc-seurat-4
R -e 'remotes::install_github("satijalab/seurat-data", dependencies=FALSE)'