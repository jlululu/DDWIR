-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- dimension table
drop table if exists durationd;
create table durationd as select distinct date_start, date_end from PHSM;
alter table durationd
add column durationCode int not null auto_increment,
add primary key(durationCode);

drop table if exists measureReportd;
create table measureReportd as select distinct lineID, who_id, who_region, iso_3166_1_numeric, admin_level, area_covered, comments, measure_stage, prev_measure_number, following_measure_number, reason_ended, targeted, 
enforcement, non_compliance_penalty from PHSM;
alter table measureReportd
add primary key(lineID);

drop table if exists measured;
create table measured as select distinct who_code, who_category, who_subcategory, who_measure from PHSM;
alter table measured
add column measureCode int not null auto_increment,
add primary key(measureCode);

drop table if exists regiond;
create table regiond as select distinct country_territory_area, iso from PHSM;
alter table regiond
add column regionCode int not null auto_increment,
add primary key(regionCode);


-- fact table
drop table if exists phsmf;
create table phsmf(
durationCode int not null,
reportCode int not null,
measureCode int not null,
regionCode int not null,
primary key(durationCode, reportCode, measureCode,regionCode),
constraint fkDuration foreign key (durationCode) references durationd (durationCode),
constraint fkReport foreign key (reportCode) references measureReportd (lineID),
constraint fkMeasure foreign key (measureCode) references measured (measureCode),
constraint fkRegion foreign key (regionCode) references regiond (regionCode)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into phsmf
select distinct durationCode, lineID, measureCode, regionCode
from PHSM p, durationd d, measured m, regiond r
where p.date_start = d.date_start and p.date_end = d.date_end and
p.who_code = m.who_code and p.country_territory_area = r.country_territory_area;
