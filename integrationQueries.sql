-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- research question 1
select (select countriesAndTerritories from aread a where a.areaCode = k1.areaCode) country, k1.month, k1.avg_cases this_month_avgCase,k2.avg_cases last_month_avgCase,concat((k1.avg_cases - k2.avg_cases)/k2.avg_cases*100,'%') increase_rate
from (
select areaCode,t.month, avg(cases) avg_cases
from covidf c, timed t,(
select regionCode, t1.month start, t2.month end
from phsmf pf, measured m, timed t1, timed t2
where pf.measureCode = m.measureCode and who_category = 'Social and physical distancing measures' and pf.date_startCode = t1.timeCode and pf.date_endCode = t2.timeCode) g
where c.timeCode = t.timeCode and t.month != 12 and areaCode = g.regionCode and t.month > start and t.month <= end
group by areaCode, t.month
order by areaCode
) as k1,
(
select areaCode,t.month,avg(cases) avg_cases
from covidf c, timed t,(
select regionCode, t1.month start, t2.month end
from phsmf pf, measured m, timed t1, timed t2
where pf.measureCode = m.measureCode and who_category = 'Social and physical distancing measures' and pf.date_startCode = t1.timeCode and pf.date_endCode = t2.timeCode) g
where c.timeCode = t.timeCode and t.month != 12 and areaCode = g.regionCode and t.month >= start and t.month < end
group by areaCode, t.month
order by areaCode
) as k2
where k1.areaCode = k2.areaCode and k1.month = k2.month + 1
order by k1.areaCode,k1.month;

-- research question 2
select (select countriesAndTerritories from aread a where a.areaCode = k1.areaCode) country, k1.month, k1.avg_death this_month_death, k2.avg_death last_month_death, concat((k1.avg_death - k2.avg_death)/k2.avg_death*100,'%') increase_rate
from(
select areaCode,t.month, avg(deaths) avg_death
from covidf c, timed t,(
select regionCode, month
from phsmf pf, measured m, timed 
where pf.measureCode = m.measureCode and who_category = 'Drug-based measures' and pf.date_startCode = timeCode) g
where c.timeCode = t.timeCode and t.month != 12 and areaCode = g.regionCode and t.month > g.month
group by areaCode, t.month
order by areaCode
) as k1,
(
select areaCode,t.month,avg(deaths) avg_death
from covidf c, timed t,(
select regionCode, month
from phsmf pf, measured m, timed
where pf.measureCode = m.measureCode and who_category = 'Drug-based measures' and pf.date_startCode = timeCode) g
where c.timeCode = t.timeCode and t.month != 12 and areaCode = g.regionCode and t.month >= g.month
group by areaCode, t.month
order by areaCode
) as k2
where k1.areaCode = k2.areaCode and k1.month = k2.month + 1
order by k1.areaCode,k1.month;