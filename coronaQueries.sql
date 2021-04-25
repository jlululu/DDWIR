-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

-- since there's only one day account in December, omit December.
/*
research question 1
*/
select (select countriesAndTerritories from aread a where a.areaCode = k1.areaCode) country, k1.month, k1.avg_cases this_month_avgCase,k2.avg_cases last_month_avgCase,concat((k1.avg_cases - k2.avg_cases)/k2.avg_cases*100,'%') increase_rate
from (
select areaCode,month,avg(cases) avg_cases
from covidf c, timed t
where c.timeCode = t.timeCode and month != 12
group by c.areaCode, month
order by c.areaCode
) as k1,
(select areaCode,month,avg(cases) avg_cases
from covidf c, timed t
where c.timeCode = t.timeCode and month != 12
group by areaCode, month
order by areaCode
) as k2 
where k1.areaCode = k2.areaCode and k1.month = k2.month + 1
order by k1.areaCode,k1.month;

/*
research question 2
*/
select (select countriesAndTerritories from aread a where a.areaCode = k1.areaCode) country, k1.month, k1.sum_death this_month_death, k2.sum_death last_month_death, concat((k1.sum_death - k2.sum_death)/k2.sum_death*100,'%') increase_rate
from(
select areaCode,month, sum(deaths) sum_death
from covidf c, timed t
where c.timeCode = t.timeCode and month != 12
group by areaCode, month
order by areaCode
) as k1,
(
select areaCode,month,sum(deaths) sum_death
from covidf c, timed t
where c.timeCode = t.timeCode and month != 12
group by areaCode, month
order by areaCode
) as k2
where k1.areaCode = k2.areaCode and k1.month = k2.month + 1
order by k1.areaCode,k1.month;