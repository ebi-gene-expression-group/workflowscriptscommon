#!/usr/bin/env bats

@test "Reading seurat and writing to all formats" {
  rm -rf ${test_seurat_experiment_file}.*
  run Rscript test/read_all_write_all.R $test_seurat_experiment_file seurat
  
  echo "status = ${status}"
  echo "output = ${output}"
  
  [ "$status" -eq 0 ]
  [ -f ${test_seurat_experiment_file}.loom ]
  [ -f ${test_seurat_experiment_file}.sce.rds ]
  [ -f ${test_seurat_experiment_file}.rds ]
  [ -f ${test_seurat_experiment_file}.h5seurat ]
}

@test "Reading SCE and writing to all formats" {
  rm -rf ${test_single_cell_experiment_file}.*
  run Rscript test/read_all_write_all.R $test_single_cell_experiment_file singlecellexperiment
  
  echo "status = ${status}"
  echo "output = ${output}"
  
  [ "$status" -eq 0 ]
  [ -f ${test_single_cell_experiment_file}.loom ]
  [ -f ${test_single_cell_experiment_file}.sce.rds ]
  [ -f ${test_single_cell_experiment_file}.rds ]
  [ -f ${test_single_cell_experiment_file}.h5seurat ]
}

@test "Reading Loom and writing to all formats" {
  rm -rf ${test_loom_file}.*
  run Rscript test/read_all_write_all.R $test_loom_file loom
  
  echo "status = ${status}"
  echo "output = ${output}"
  
  [ "$status" -eq 0 ]
  [ -f ${test_loom_file}.loom ]
  [ -f ${test_loom_file}.sce.rds ]
  [ -f ${test_loom_file}.rds ]
  [ -f ${test_loom_file}.h5seurat ]
}

@test "Reading H5Seurat and writing to all formats" {
  rm -rf ${test_h5seurat_file}.*
  run Rscript test/read_all_write_all.R $test_h5seurat_file h5seurat
  
  echo "status = ${status}"
  echo "output = ${output}"
  
  [ "$status" -eq 0 ]
  [ -f ${test_h5seurat_file}.loom ]
  [ -f ${test_h5seurat_file}.sce.rds ]
  [ -f ${test_h5seurat_file}.rds ]
  [ -f ${test_h5seurat_file}.h5seurat ]
}


