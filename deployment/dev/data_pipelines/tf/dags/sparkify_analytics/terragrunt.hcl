include {
  path = find_in_parent_folders()
}

dependency "sparkify_etl" {
    config_path = "../sparkify_etl"
    mock_outputs = {
        athena_db = "tmp-athena-db"
    }
}

inputs = {
    athena_db = dependency.sparkify_etl.outputs.glue_catalog_db
}

