-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- using time dimension and region dimension to link the two datamarts 
-- time dimension
-- in case the date_start or date_end is null in the PHSM
insert into timed(dateRep, day, month, year)
values(' ',0,0,0);

insert into timed(dateRep, day, month, year)
select distinct date_start, 
	convert(substring_index(date_start,'/',1),unsigned), 
    convert(substring_index(substring_index(date_start,'/',-2),'/',1),unsigned),
    convert(substring_index(date_start,'/',-1),unsigned)
from durationd
where date_start != '' and not exists(select * from timed where dateRep = date_start);

insert into timed(dateRep, day, month, year)
select distinct date_end, 
	convert(substring_index(date_end,'/',1),unsigned), 
    convert(substring_index(substring_index(date_end,'/',-2),'/',1),unsigned),
    convert(substring_index(date_end,'/',-1),unsigned)
from durationd
where date_end != '' and not exists(select * from timed where dateRep = date_end);


-- region dimension
insert into aread(countriesAndTerritories, countryterritoryCode)
select country_territory_area, iso
from regiond r
where not exists(select * from aread a where a.countriesAndTerritories = r.country_territory_area);

drop table if exists phsmf;
create table phsmf(
date_startCode int,
date_endCode int,
reportCode int not null,
measureCode int not null,
regionCode int not null,
primary key(date_startCode, date_endCode, reportCode, measureCode,regionCode),
constraint fkStart foreign key (date_startCode) references timed (timeCode),
constraint fkEnd foreign key (date_endCode) references timed (timeCode),
constraint fkReport foreign key (reportCode) references measureReportd (lineID),
constraint fkMeasure foreign key (measureCode) references measured (measureCode),
constraint fkRegion foreign key (regionCode) references aread (areaCode)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into phsmf
select t1.timeCode, t2.timeCode, lineID, measureCode, areaCode
from PHSM p, timed t1, timed t2, measured m, aread a
where p.date_start = t1.dateRep and p.date_end = t2.dateRep and p.who_code = m.who_code and p.country_territory_area = a.countriesAndTerritories;
