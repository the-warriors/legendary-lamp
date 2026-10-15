-- One row per motorway_id with coverage stats.
-- motorway_name is not unique per id in the source (e.g. 100 = SHB and SHT,
-- 105 = two operator names), so all names are kept as an array.

select
    motorway_id,
    max(motorway_short_name)                       as motorway_short_name,
    array_sort(collect_set(motorway_name))         as motorway_names,
    max(state)                                     as state,
    max(facility_type)                             as facility_type,
    count(*)                                       as toll_point_count,
    count(distinct plaza_id)                       as plaza_count,
    round(avg(case when entry_coord_status = 'valid' then 1.0 else 0.0 end), 2)
                                                   as pct_with_valid_coords
from {{ ref('dim_toll_point') }}
group by motorway_id
