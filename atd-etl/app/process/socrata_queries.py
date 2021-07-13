"""
Socrata Queries
Author: Austin Transportation Department, Data & Technology Services

Description: The purpose of this script is to define graphql query templates
to run against the Hasura endpoint for Socrata upsertion.

Important: These templates require importing the Template class from the string library.
"""
from string import Template

# Queries Hasura to retrieve records for
# https://data.austintexas.gov/d/y2wy-tgr5
crashes_query_template = Template(
    """
    query getCrashesSocrata {
        atd_txdot_crashes (
                limit: $limit,
                offset: $offset,
                order_by: {crash_id: asc},
                where: {
                    crash_date: { _lt: "$date_limit" }
                    private_dr_fl: { _eq: "N" },
                    _and: [
                      { crash_date: { _is_null: false }},
                      { crash_time: { _is_null: false }}
                    ]
                    _or: [
                        {austin_full_purpose: {_eq: "Y"}},
                        {
                            _and: [
                                {city_id: {_eq: 22}},
                                {position: {_is_null: true}}
                            ]
                        }
                    ]
                }
        ) {
            apd_confirmed_fatality
            apd_confirmed_death_count
            crash_id
            crash_fatal_fl
            crash_date
            crash_time
            case_id
            onsys_fl
            private_dr_fl
            rpt_latitude
            rpt_longitude
            rpt_block_num
            rpt_street_pfx
            rpt_street_name
            rpt_street_sfx
            crash_speed_limit
            road_constr_zone_fl
            latitude_primary
            longitude_primary
            street_name
            street_nbr
            street_name_2
            street_nbr_2
            crash_sev_id
            sus_serious_injry_cnt
            nonincap_injry_cnt
            poss_injry_cnt
            non_injry_cnt
            unkn_injry_cnt
            tot_injry_cnt
            atd_fatality_count
            atd_mode_category_metadata
            units {
                contrib_factr_p1_id
                contrib_factr_p2_id
            }
        }
    }
"""
)

# Queries Hasura to retrieve records for
# https://data.austintexas.gov/d/xecs-rpy9
people_query_template = Template(
    """
    query getPeopleSocrata {
        atd_txdot_person(
            limit: $limit,
            offset: $offset,
            order_by: {person_id: asc},
            where: {
                crash: { private_dr_fl: { _eq: "N" }},
                _or: [
                    {prsn_injry_sev_id: {_eq: 1}},
                    {prsn_injry_sev_id: {_eq: 4}}
                ],
                _and: {
                    crash: {crash_date: {_lt: "$date_limit"}}
                    _or: [
                        {crash: {austin_full_purpose: {_eq: "Y"}}},
                        {
                            _and: [
                                {crash: {city_id: {_eq: 22}}},
                                {crash: {position: {_is_null: true}}} 
                            ]
                        }
                    ]
                }
            }
        ) {
            person_id
            prsn_injry_sev_id
            prsn_age
            prsn_gndr_id
            prsn_ethnicity_id
            unit_nbr
            crash {
                crash_date
                crash_time
                crash_id
                atd_mode_category_metadata
                units {
                    unit_nbr
                    unit_id
                }
            }
        }
        atd_txdot_primaryperson(
            limit: $limit,
            offset: $offset,
            order_by: {primaryperson_id: asc},
            where: {
                crash: { private_dr_fl: { _eq: "N" }},
                _or: [{prsn_injry_sev_id: {_eq: 1}}, {prsn_injry_sev_id: {_eq: 4}}],
                _and: {
                    crash: {crash_date: {_lt: "$date_limit"}}
                    _or: [
                        {crash: {austin_full_purpose: {_eq: "Y"}}}, 
                        {
                            _and: [
                                {crash: {city_id: {_eq: 22}}},
                                {crash: {position: {_is_null: true}}}
                            ]
                        }
                    ]
                }
            }
        ) {
            primaryperson_id
            prsn_injry_sev_id
            prsn_age
            prsn_gndr_id
            prsn_ethnicity_id
            unit_nbr
            crash {
                crash_date
                crash_time
                crash_id
                atd_mode_category_metadata
                units {
                    unit_nbr
                    unit_id
                }
            }
        }
    }
"""
)
