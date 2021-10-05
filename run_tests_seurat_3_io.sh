#!/usr/bin/env bash

script_dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
script_name=$0

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: r-seurat-workflow-post-install-tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
export use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_data_url='https://s3-us-west-2.amazonaws.com/10x.files/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz'
test_data_transfer_url='https://www.dropbox.com/s/1zxbn92y5du9pu0/pancreas_v3_files.tar.gz?dl=1'
test_seurat_experiment_url='https://www.dropbox.com/s/kwd3kcxkmpzqg6w/pbmc3k_final.rds?dl=0'
#test_single_cell_experiment_url='https://scrnaseq-public-datasets.s3.amazonaws.com/scater-objects/manno_human.rds'
#test_scater_url='https://scrnaseq-public-datasets.s3.amazonaws.com/scater-objects/manno_human.rds'
test_loom_url='https://storage.googleapis.com/linnarsson-lab-loom/l6_r1_immune_cells.loom'
test_anndata_url="https://seurat.nygenome.org/pbmc3k_final.h5ad"

export test_working_dir=`pwd`/'post_install_tests'
export data_dir="$test_working_dir/test_data"
export raw_matrix="$test_working_dir/matrix.mtx"
export raw_matrix_object="$test_working_dir/raw_matrix.rds"
export test_seurat_experiment_file="$test_working_dir/raw_seurat.rds"
export test_data_transfer_file=$test_working_dir/$(basename $test_data_transfer_url | sed 's/\?dl=1//')
export test_data_archive=$test_working_dir/$(basename $test_data_url)
#export test_single_cell_experiment_file=$test_working_dir/$(basename $test_single_cell_experiment_url)
export test_single_cell_experiment_file=${test_seurat_experiment_file}.sce.rds
export test_loom_file=$test_working_dir/$(basename $test_loom_url)
export test_anndata_file=$test_working_dir/$(basename $test_anndata_url)
export multiple_seurat_output=$test_working_dir/multiple_seurat.rds

# Clean up if specified

if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi

# Initialise directories

output_dir=$test_working_dir/outputs
export data_dir=$test_working_dir/test_data

mkdir -p $test_working_dir
mkdir -p $output_dir
mkdir -p $data_dir

################################################################################
# Fetch test data
################################################################################

if [ ! -e "$test_data_archive" ]; then
    wget $test_data_url -P $test_working_dir
fi

#if [ ! -e "$test_single_cell_experiment_file" ]; then
#    wget $test_single_cell_experiment_url -O $test_single_cell_experiment_file
#fi

if [ ! -e "$test_loom_file" ]; then
    wget $test_loom_url -O $test_loom_file
fi

if [ ! -e "$test_anndata_file" ]; then
    wget $test_anndata_url -O $test_anndata_file
fi


################################################################################
# Run tests
################################################################################

./run_tests_seurat_3_io.bats
