-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- there are some typo in two Pakistan record, according to the detail information of the measures, they're taken in Pakistan instead of in areas of Indian. 
update PHSM 
set who_region = 'EMRO', iso='PAK', iso_3166_1_numeric= '586'
where country_territory_area = 'Pakistan' and iso='IND';
-- 1NF
-- there are some duplicate records in the PHSM dataset, like the result of 'select * from PHSM where who_id='ACAPS_3345';', except for the lineID, the other attributes are same.
drop table if exists 1NF_p;
create table 1NF_p as select distinct who_id, who_region, country_territory_area, iso, iso_3166_1_numeric, admin_level, area_covered, who_code,
who_category, who_subcategory, who_measure, comments, date_start, measure_stage, prev_measure_number, following_measure_number, date_end, reason_ended, targeted,
enforcement, non_compliance_penalty from PHSM;
alter table 1NF_p
modify who_id varchar(255),
modify who_code varchar(255),
modify iso_3166_1_numeric varchar(255),
add column recordID int not null auto_increment,
add primary key(recordID);


-- 2NF There's no partial dependencies exist on the primary key of 1NF_p.

-- 3NF
/* 
In the PHSM dataset, a certain country can take one or several same or different measures at certain levels(national or regional)
during some certain periods. 
*/
drop table if exists isoCode;
create table isoCode as select distinct iso, iso_3166_1_numeric from 1NF_p;
alter table isoCode
add primary key(iso_3166_1_numeric);

drop table if exists region;
create table region as select distinct who_id, who_region, country_territory_area, iso_3166_1_numeric from 1NF_p;
alter table region
add primary key(who_id),
add foreign key(iso_3166_1_numeric) references isoCode(iso_3166_1_numeric);

drop table if exists measure;
create table measure as select distinct who_code, who_category, who_subcategory, who_measure from 1NF_p;
alter table measure
add primary key(who_code);

drop table if exists measureLevel;
create table measureLevel as select distinct who_id, who_code, admin_level, area_covered from 1NF_p;
alter table measureLevel
add primary key(who_id, who_code),
add foreign key(who_id) references region(who_id),
add foreign key(who_code) references measure(who_code);

drop table if exists measureTaken;
create table measureTaken as select distinct recordID, who_id, who_code, prev_measure_number, targeted, comments, date_start, measure_stage, 
following_measure_number, date_end, reason_ended, enforcement, non_compliance_penalty from 1NF_p;
alter table measureTaken
add primary key(recordID),
add foreign key(who_id) references region(who_id),
add foreign key(who_code) references measure(who_code);
