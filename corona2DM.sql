-- Student Name: Wenjing LU
-- Student Number : k20002533
-- Write your commands and/or comments below

-- dimension table
drop table if exists timed;
create table timed as select distinct dateRep, day, month, year from corona;
alter table timed 
add column timeCode int not null auto_increment,
add primary key(timeCode);

drop table if exists aread;
create table aread as select distinct geoId, countriesAndTerritories, countryterritoryCode, popData2019, continentExp from corona;
alter table aread
add column areaCode int not null auto_increment,
add primary key(areaCode);


-- fact table
drop table if exists covidf;
create table covidf(
timeCode int not null,
areaCode int not null,
cases int(11) not null,
deaths int(11) not null,
primary key(timeCode, areaCode),
constraint fkTime foreign key (timeCode) references timed (timeCode),
constraint fkArea foreign key (areaCode) references aread (areaCode)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


/* For those negative values in cases and deaths, which come from corrections of previous days, since there are no more context information about 
it like the time scale of every correction, I just assume that every correction is based on mistakes from all of the previous days. Then I use the 
following method to deal with the negative values:
create a trigger for the fact table, every time a negative value is about to insert into it, we set it to 0 and record the negative value together
according to different regions. Then after inserting, we subtract every positive case/death value with a specific portion of the accumulated correction
value, which mainly based on their effects on the total case/death value.
*/
set @temp1 = 0;
set @temp2 = 0;
set @g1 = -1;
set @g2 = -1;

drop table if exists negative_c;
create table negative_c(
geId int not null,
cases int(11) not null,
case_sum int(11),
primary key(geId)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop table if exists negative_d;
create table negative_d(
geId int not null,
deaths int(11) not null,
death_sum int(11),
primary key(geId)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

delimiter ||
create trigger covidf_inserta before insert on covidf
for each row
begin
if new.cases < 0 then
	if new.areaCode = @g1 then
		set @temp1 = @temp1 + new.cases;
	else
		insert into negative_c
        values(@g1,@temp1,(select sum(cases) from covidf where areaCode = @g1));
        set @g1 = new.areaCode;
        set @temp1 = new.cases;
    end if;
	set new.cases = 0;
end if;
if new.deaths < 0 then
	if new.areaCode = @g2 then
		set @temp2 = @temp2 + new.deaths;
	else
		insert into negative_d
        values(@g2,@temp2,(select sum(deaths) from covidf where areaCode = @g2));
        set @g2 = new.areaCode;
        set @temp2 = new.deaths;
    end if;
    set new.deaths = 0;
end if;
end ||
delimiter ;

insert into covidf
select distinct t.timeCode, a.areaCode, cases, deaths
from corona c left join timed t on c.dateRep = t.dateRep 
left join aread a on c.geoId = a.geoId;

insert into negative_c
values(@g1,@temp1,(select sum(cases) from covidf where areaCode = @g1));
insert into negative_d
values(@g2,@temp2,(select sum(deaths) from covidf where areaCode = @g2));
              
update covidf
set cases = cases + cases/(select case_sum from negative_c c1 where c1.geId = areaCode)*(select cases from negative_c c2 where c2.geId = areaCode)
where exists(select * from negative_c c3 where c3.geId = areaCode);
update covidf
set deaths = deaths + deaths/(select death_sum from negative_d d1 where d1.geId = areaCode)*(select deaths from negative_d d2 where d2.geId = areaCode)
where exists(select * from negative_d d3 where d3.geId = areaCode);


drop table negative_c;
drop table negative_d;
