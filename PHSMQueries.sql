-- Student Name: Wenjing Lu
-- Student Number : k20002533
-- Write your commands and/or comments below

/*
research question 1
*/
select country_territory_area, who_measure national_measure, count(*) num
from phsmf pf, regiond r, measured m  
where pf.regionCode = r.regionCode and pf.measureCode = m.measureCode and 
exists(select * from measureReportd mr where mr.lineID = reportCode and mr.admin_level = 'national')
group by country_territory_area, who_measure
order by country_territory_area asc, num desc;


/*
research question 2
*/
select distinct country_territory_area, who_measure, date_start
from phsmf pf, durationd d, regiond r, measured m
where pf.durationCode = d.durationCode and pf.regionCode = r.regionCode and pf.measureCode = m.measureCode and
who_category = 'social and physical distancing measures' and
convert(substring_index(substring_index(date_start,'/',-2),'/',1),unsigned) < 4
order by country_territory_area;