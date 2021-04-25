-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- 1NF
drop table if exists 1NF_c;
create table 1NF_c as select * from corona;
alter table 1NF_c
add primary key(dateRep,geoId);

-- 2NF
drop table if exists time;
create table time as select distinct dateRep, day, month, year from 1NF_c;
alter table time
add primary key(dateRep);

drop table if exists area;
create table area as select distinct geoId, countriesAndTerritories, countryterritoryCode, popData2019, continentExp from 1NF_c;
alter table area
add primary key(geoId);

drop table if exists covid;
create table covid as select distinct dateRep, geoId, cases, deaths from 1NF_c;
alter table covid
add primary key(dateRep, geoId),
add foreign key(dateRep) references time(dateRep),
add foreign key(geoId) references area(geoId);


-- 3NF 
drop table if exists areaInfo;
create table areaInfo as select distinct countriesAndTerritories, popData2019, continentExp from area;
alter table areaInfo 
add primary key(countriesAndTerritories);

drop table if exists areaName;
create table areaName as select distinct countryterritoryCode,  countriesAndTerritories from area;
alter table areaName
add primary key(countryterritoryCode),
add foreign key(countriesAndTerritories) references areaInfo(countriesAndTerritories);

alter table area 
drop column countriesAndTerritories,
drop column popData2019, 
drop column continentExp,
add foreign key(countryterritoryCode) references areaName(countryterritoryCode);


