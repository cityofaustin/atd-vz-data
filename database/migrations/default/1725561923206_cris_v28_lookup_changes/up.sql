insert into lookups.agency (id, label, source) values (
    10013,
    'BURLINGTON NORTHERN SANTA FE RAILROAD COMPANY POLICE DEPARTMENT',
    'cris'
);
insert into lookups.agency (id, label, source) values (
    10228, 'SMITH COUNTY', 'cris'
);
insert into lookups.agency (id, label, source) values (
    10229, 'HARRIS COUNTY COMMISSIONER PRECINCT 4', 'cris'
);
insert into lookups.agency (id, label, source) values (
    10231, 'COLLIN COUNTY CRIMINAL DISTRICT ATTORNEY''S OFFICE', 'cris'
);
insert into lookups.agency (id, label, source) values (
    10232, 'TRAVIS COUNTY - AUSTIN EMS', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3355, 'KILGORE COLLEGE POLICE DEPARTMENT', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3356, 'COMAL COUNTY CONSTABLE''S OFFICE PCT 4', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3357, 'ANGELINA COLLEGE POLICE DEPARTMENT', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3359, 'COPPER CANYON POLICE DEPARTMENT', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3360, 'WILSON COUNTY CONSTABLE OFFICE PRECINCT 3', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3361, 'JEFFERSON COUNTY SHERIFF''S OFFICE', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3362, 'AUSTIN COMMUNITY COLLEGE DISTRICT POLICE DEPARTMENT', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3363, 'TOWN OF INDIAN LAKE POLICE DEPARTMENT', 'cris'
);
insert into lookups.agency (id, label, source) values (
    3364, 'DODD CITY ISD POLICE DEPARTMENT', 'cris'
);
update lookups.agency set label = 'TEXAS WOMAN''S UNIVERSITY POLICE DEPARTMENT'
where id = 2264;
update lookups.agency set
    label
    = 'TRAVIS COUNTY - TRANSPORTATION AND NATURAL RESOURCES -TRAFFIC ENGINEERING'
where id = 10170;

-- manual migration of investigat_agency_id on old crashes
-- AUSTIN COLLEGE POLICE DEPARTMENT --> AUSTIN COMMUNITY COLLEGE DISTRICT POLICE DEPARTMENT
update crashes_cris set investigat_agency_id = 3362
where investigat_agency_id = 71;

-- TRINITY COUNTY CONSTABLE PRECINCT 3 --> UNKNOWN (no corresponding value exists)
update crashes_cris set investigat_agency_id = 9999
where investigat_agency_id = 2296;

delete from lookups.agency where id = 1167;
delete from lookups.agency where id = 1201;
delete from lookups.agency where id = 1226;
delete from lookups.agency where id = 1278;
delete from lookups.agency where id = 1326;
delete from lookups.agency where id = 1441;
delete from lookups.agency where id = 151;
delete from lookups.agency where id = 1520;
delete from lookups.agency where id = 1666;
delete from lookups.agency where id = 167;
delete from lookups.agency where id = 1684;
delete from lookups.agency where id = 1723;
delete from lookups.agency where id = 1765;
delete from lookups.agency where id = 1802;
delete from lookups.agency where id = 1822;
delete from lookups.agency where id = 1832;
delete from lookups.agency where id = 1894;
delete from lookups.agency where id = 1930;
delete from lookups.agency where id = 1956;
delete from lookups.agency where id = 1968;
delete from lookups.agency where id = 1983;
delete from lookups.agency where id = 2070;
delete from lookups.agency where id = 2092;
delete from lookups.agency where id = 212;
delete from lookups.agency where id = 2202;
delete from lookups.agency where id = 220;
delete from lookups.agency where id = 2272;
delete from lookups.agency where id = 2296;
delete from lookups.agency where id = 2314;
delete from lookups.agency where id = 2320;
delete from lookups.agency where id = 234;
delete from lookups.agency where id = 23673;
delete from lookups.agency where id = 23682;
delete from lookups.agency where id = 23773;
delete from lookups.agency where id = 23794;
delete from lookups.agency where id = 23816;
delete from lookups.agency where id = 23845;
delete from lookups.agency where id = 23846;
delete from lookups.agency where id = 23854;
delete from lookups.agency where id = 23897;
delete from lookups.agency where id = 24043;
delete from lookups.agency where id = 2446;
delete from lookups.agency where id = 2461;
delete from lookups.agency where id = 2586;
delete from lookups.agency where id = 2590;
delete from lookups.agency where id = 2602;
delete from lookups.agency where id = 262;
delete from lookups.agency where id = 275;
delete from lookups.agency where id = 2779;
delete from lookups.agency where id = 2831;
delete from lookups.agency where id = 2839;
delete from lookups.agency where id = 2871;
delete from lookups.agency where id = 2872;
delete from lookups.agency where id = 2887;
delete from lookups.agency where id = 3078;
delete from lookups.agency where id = 3123;
delete from lookups.agency where id = 3168;
delete from lookups.agency where id = 3171;
delete from lookups.agency where id = 3173;
delete from lookups.agency where id = 3174;
delete from lookups.agency where id = 3181;
delete from lookups.agency where id = 3183;
delete from lookups.agency where id = 3186;
delete from lookups.agency where id = 321;
delete from lookups.agency where id = 3250;
delete from lookups.agency where id = 3254;
delete from lookups.agency where id = 3257;
delete from lookups.agency where id = 3258;
delete from lookups.agency where id = 3262;
delete from lookups.agency where id = 3264;
delete from lookups.agency where id = 3270;
delete from lookups.agency where id = 3273;
delete from lookups.agency where id = 3275;
delete from lookups.agency where id = 3281;
delete from lookups.agency where id = 3283;
delete from lookups.agency where id = 3284;
delete from lookups.agency where id = 3287;
delete from lookups.agency where id = 3290;
delete from lookups.agency where id = 3291;
delete from lookups.agency where id = 3295;
delete from lookups.agency where id = 3299;
delete from lookups.agency where id = 3310;
delete from lookups.agency where id = 3313;
delete from lookups.agency where id = 3314;
delete from lookups.agency where id = 3323;
delete from lookups.agency where id = 3335;
delete from lookups.agency where id = 42;
delete from lookups.agency where id = 71;
delete from lookups.agency where id = 795;
