-- Raw e-toll plaza file, landed as-is.
-- Every column is kept as STRING so leading zeros in plaza_id ("003") and lane_id ("01")
-- survive; typing happens in staging.
-- The file is Windows-1252 encoded (en dashes in NorthConnex gantry names).

select
    *,
    _metadata.file_name  as _source_file,
    current_timestamp()  as _loaded_at
from read_files(
    '{{ var("raw_volume") }}/motorway_ext/etoll_plaza.csv',
    format             => 'csv',
    header             => true,
    encoding           => 'windows-1252',
    inferColumnTypes   => false
)
