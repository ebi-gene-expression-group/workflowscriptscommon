#!/usr/bin/env bats

@test "Extract .mtx matrix from archive" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$raw_matrix" ]; then
        skip "$raw_matrix exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $raw_matrix && tar -xvzf $test_data_archive --strip-components 2 -C $test_working_dir
    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f "$raw_matrix" ]
}

@test "Get Seurat 3 object from 10x" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_seurat_experiment_file" ]; then
      skip "$test_seurat_experiment_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -rf $test_seurat_experiment_file && Rscript test/produce_seurat3_object.R $test_working_dir $test_seurat_experiment_file

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f "$test_seurat_experiment_file" ]
}

@test "Reading seurat and writing to all formats" {
  if [ "$use_existing_outputs" = 'true' ] && [ -f ${test_seurat_experiment_file}.loom ] && [ -f ${test_seurat_experiment_file}.sce.rds ]; then
        skip "Outputs exists and use_existing_outputs is set to 'true'"
  fi

  rm -rf ${test_seurat_experiment_file}.*
  run Rscript test/read_all_write_all_seurat3.R $test_seurat_experiment_file seurat

  echo "status = ${status}"
  echo "output = ${output}"

  [ "$status" -eq 0 ]
  [ -f ${test_seurat_experiment_file}.loom ]
  [ -f ${test_seurat_experiment_file}.sce.rds ]
  [ -f ${test_seurat_experiment_file}.rds ]
}

@test "Reading SCE and writing to all formats" {
  if [ "$use_existing_outputs" = 'true' ] && [ -f ${test_single_cell_experiment_file}.loom ] && [ -f ${test_single_cell_experiment_file}.sce.rds ]; then
        skip "Outputs exists and use_existing_outputs is set to 'true'"
  fi

  rm -rf ${test_single_cell_experiment_file}.*
  run Rscript test/read_all_write_all_seurat3.R $test_single_cell_experiment_file singlecellexperiment

  echo "status = ${status}"
  echo "output = ${output}"

  [ "$status" -eq 0 ]
  [ -f ${test_single_cell_experiment_file}.loom ]
  [ -f ${test_single_cell_experiment_file}.sce.rds ]
  [ -f ${test_single_cell_experiment_file}.rds ]
}

@test "Reading Loom and writing to all formats" {
  if [ "$use_existing_outputs" = 'true' ] && [ -f ${test_loom_file}.loom ] && [ -f ${test_loom_file}.sce.rds ]; then
        skip "Outputs exists and use_existing_outputs is set to 'true'"
  fi
  rm -rf ${test_loom_file}.*
  run Rscript test/read_all_write_all_seurat3.R $test_loom_file loom

  # writing to loom here is failing with:
  # Adding: AnalysisPool
  # Error in self$set_size(size) : HDF5-API Errors:
  #     error #000: H5T.c in H5Tset_size(): line 2376: size must be positive
  #         class: HDF5
  #         major: Invalid arguments to routine
  #         minor: Bad value
  # Calls: write_seurat3_object ... getDtype -> <Anonymous> -> initialize -> <Anonymous> -> .Call
  #
  # similar to https://github.com/satijalab/seurat/issues/2310

  echo "status = ${status}"
  echo "output = ${output}"

  [ "$status" -eq 0 ]
  [ -f ${test_loom_file}.loom ]
  [ -f ${test_loom_file}.sce.rds ]
  [ -f ${test_loom_file}.rds ]
}

@test "Reading AnnData and writing to all formats" {
  if [ "$use_existing_outputs" = 'true' ] && [ -f ${test_anndata_file}.loom ] && [ -f ${test_anndata_file}.sce.rds ]; then
        skip "Outputs exists and use_existing_outputs is set to 'true'"
  fi
  rm -rf ${test_anndata_file}.*
  run Rscript test/read_all_write_all_seurat3.R $test_anndata_file anndata

  echo "status = ${status}"
  echo "output = ${output}"

  [ "$status" -eq 0 ]
  [ -f ${test_anndata_file}.loom ]
  [ -f ${test_anndata_file}.sce.rds ]
  [ -f ${test_anndata_file}.rds ]
}

# @test "Read multiple seurat files into a list" {
#   if [ "$use_existing_outputs" = 'true' ] && [ -f ${multiple_seurat_output} ]; then
#         skip "Outputs exists and use_existing_outputs is set to 'true'"
#   fi
#   rm -rf ${multiple_seurat_output}
#   run Rscript test/read_many_into_list.R ${test_seurat_experiment_file},${test_seurat_experiment_file},${test_seurat_experiment_file} \
#       seurat ${multiple_seurat_output}
#
#   echo "status = ${status}"
#   echo "output = ${output}"
#
#   [ "$status" -eq 0 ]
#   [ -f ${multiple_seurat_output} ]
# }
