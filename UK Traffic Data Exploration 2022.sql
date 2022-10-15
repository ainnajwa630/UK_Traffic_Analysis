-- ** create db **
create database UkTraffic;

create index _Accident_Index_
on UkTraffic.dbo.Vehicle_Information(_Accident_Index_)

-- ** explore accident information table ** --
-- ** 1. Is every accident index unique in this table? **

select _Accident_Index_, count(*) count_row
from UkTraffic.dbo.Accident_Information 
group by _Accident_Index_
having count(*) > 1 


-- ** 2. Accident Severity based on number of incidents
select * from (
select _Accident_Severity_, count(distinct _Accident_Index_) num_index_accident
from UkTraffic.dbo.Accident_Information
group by _Accident_Severity_
)a order by num_index_accident desc



-- ** 3. Does accidents increase by the year?
select a._Year_, count(distinct _Accident_Index_) number_accidents
from UkTraffic.dbo.Accident_Information a
group by _Year_
order by _Year_

-- ** 4. How about the severity across the year?
select *
from 
(
	select 
	ai._Year_ as Years, 
	ai._Accident_Severity_ as accident_severity,
	count(distinct ai._Accident_Index_) as number_accidents
	from UkTraffic.dbo.Accident_Information ai
	group by ai._Year_, ai._Accident_Severity_
)a
pivot( sum(number_accidents) for accident_severity in ([Serious],[Slight],[Fatal])) as pivot_table

-- ** 5. Conditions that are hazardous and what hour are the deadly hours?

select *
from 
(
	select 
	datepart(hour,ai._Time_) as accident_hour, 
	ai._Road_Surface_Conditions_ as road_conditions,
	count(distinct ai._Accident_Index_) as number_accidents
	from UkTraffic.dbo.Accident_Information ai
	left join UkTraffic.dbo.Vehicle_Information vi
	on ai._Accident_Index_ = vi._Accident_Index_
	group by ai._Road_Surface_Conditions_,ai._Time_
)a
pivot( sum(number_accidents) for accident_hour in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23])) as pivot_table
where road_conditions not in ('Data missing or out of range')
order by road_conditions desc
--pivot( sum(number_accidents) for road_conditions in ([Dry],[Frost or ice],[Snow],[Wet or damp],[Flood over 3cm. deep])) as pivot_table


-- ** 6. Driver demographic

select 
	vi._Sex_of_Driver_ as sex_driver,
	count(distinct ai._Accident_Index_) as number_accidents
from UkTraffic.dbo.Accident_Information ai
left join UkTraffic.dbo.Vehicle_Information vi
on ai._Accident_Index_ = vi._Accident_Index_
group by
	_Sex_of_Driver_
order by count(distinct ai._Accident_Index_) desc
