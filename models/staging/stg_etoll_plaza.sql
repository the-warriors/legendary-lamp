-- One row per toll point: motorway_id + plaza_id + lane_id + trip_description.
-- Fixes applied:
--   1. Types cast; text trimmed.
--   2. M5 South West rows appear twice (once per operator name) -> keep one.
--   3. Coordinates outside Australia (e.g. CCT rows where longitude = latitude) -> set to null and flagged.

with source as (

    select * from {{ ref('brz_etoll_plaza') }}

),

typed as (

    select
        cast(motorway_id as int)            as motorway_id,
        trim(motorway_short_name)           as motorway_short_name,
        trim(motorway_name)                 as motorway_name,
        trim(plaza_id)                      as plaza_id,
        trim(trip_description)              as trip_description,
        cast(lane_id as int)                as lane_id,
        cast(latitude as double)            as entry_latitude_raw,
        cast(longitude as double)           as entry_longitude_raw,
        cast(exit_latitude as double)       as exit_latitude_raw,
        cast(exit_longitude as double)      as exit_longitude_raw,
        nullif(trim(entry_gantry_reference), '') as entry_gantry_reference,
        nullif(trim(exit_gantry_reference), '')  as exit_gantry_reference,
        _source_file,
        _loaded_at
    from source

),

deduped as (

    select *
    from typed
    qualify row_number() over (
        partition by motorway_id, plaza_id, lane_id, trip_description
        order by motorway_name
    ) = 1

),

validated as (

    select
        *,
        entry_latitude_raw  between -44 and -10
            and entry_longitude_raw between 112 and 154  as is_entry_coord_valid,
        exit_latitude_raw   between -44 and -10
            and exit_longitude_raw  between 112 and 154  as is_exit_coord_valid
    from deduped

)

select
    motorway_id,
    motorway_short_name,
    motorway_name,
    plaza_id,
    trip_description,
    lane_id,

    case when is_entry_coord_valid then entry_latitude_raw  end as entry_latitude,
    case when is_entry_coord_valid then entry_longitude_raw end as entry_longitude,
    case when is_exit_coord_valid  then exit_latitude_raw   end as exit_latitude,
    case when is_exit_coord_valid  then exit_longitude_raw  end as exit_longitude,

    case
        when entry_latitude_raw is null      then 'missing'
        when not is_entry_coord_valid        then 'invalid'
        else 'valid'
    end as entry_coord_status,

    entry_gantry_reference,
    exit_gantry_reference,
    _source_file,
    _loaded_at
from validated
