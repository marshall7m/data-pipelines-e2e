dependency "sparkify_etl" {
    config_path = "${get_terragrunt_dir()}/../sparkify_etl"
    mock_outputs = {
      glue_catalog_db = "tmp_glue_catalog"
    }
}

include {
  path = find_in_parent_folders()
}

inputs = {
    athena_db = dependency.sparkify_etl.outputs.glue_catalog_db
}

