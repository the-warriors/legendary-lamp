-- One row per toll point, with state, a surrogate key and an H3 cell for spatial joins.

select
    {{ dbt_utils.generate_surrogate_key(['p.motorway_id', 'p.plaza_id', 'p.lane_id', 'p.trip_description']) }}
                                as toll_point_key,
    p.motorway_id,
    p.motorway_short_name,
    p.motorway_name,
    r.state,
    r.facility_type,
    p.plaza_id,
    p.lane_id,
    p.trip_description,
    p.entry_gantry_reference,
    p.exit_gantry_reference,
    p.entry_latitude,
    p.entry_longitude,
    p.exit_latitude,
    p.exit_longitude,
    p.entry_coord_status,
    case when p.entry_latitude is not null
         then h3_longlatash3(p.entry_longitude, p.entry_latitude, 9) end as entry_h3_r9,
    p.exit_latitude is not null    as is_entry_exit_pair
from {{ ref('stg_etoll_plaza') }} p
left join {{ ref('motorway_reference') }} r
    on p.motorway_id = r.motorway_id

