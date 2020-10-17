resource "aws_athena_database" "this" {
  name   = "test"
  bucket = var.private_bucket
}

resource "aws_athena_workgroup" "this" {
  name = "${local.resource_prefix}-athena-workgroup"

  configuration {
    enforce_workgroup_configuration =  true

    result_configuration {
      output_location = "s3://${var.private_bucket}/data_pipeline/${var.env}/athena_queries/"
    }
  }

  tags = {
      "environment" = var.env 
      "project_id" = var.project_id
      "client" = var.client
      "service" = "data-pipeline"
      "dag_id" = "sparkify-analytics"
  }
}

resource "aws_athena_named_query" "top_year_songs" {
  name = "${local.resource_prefix}-name"
  database = aws_athena_database.this.id
  workgroup = aws_athena_workgroup.this.name
  query = <<EOF
SELECT 
    song,
    artist,
    COUNT(*)
FROM songplay
JOIN songs
ON songs.artist_id = songplay.artist_id
GROUP BY artist, song, COUNT(*)
ORDER BY COUNT(*) DESC
WHERE year = {}
LIMIT 10
EOF
}

resource "aws_athena_named_query" "avg_session_id_item" {
  name = "${local.resource_prefix}-avg-session-id-item"
  database = aws_athena_database.this.id
  workgroup = aws_athena_workgroup.this.name
  query = <<EOF
SELECT
    page,
    ROUND(AVG(iteminsession), 1) AS avg_item_in_session,
    ROUND(AVG(sessionid), 1) AS avg_session_id
FROM staging_events
WHERE 
    page IN ('Upgrade', 'Downgrade', 'Submit Upgrade', 'Submit Downgrade')
GROUP BY page
EOF
}

resource "aws_athena_named_query" "upgrade_downgrade_count" {
  name = "${local.resource_prefix}-upgrade_downgrade_count"
  database = aws_athena_database.this.id
  workgroup = aws_athena_workgroup.this.name
  query = <<EOF
SELECT 
    page,
    COUNT(*)
FROM sparkify.staging_events
GROUP BY page
WHERE page IN ('Downgrade', 'Upgrade')
EOF
}