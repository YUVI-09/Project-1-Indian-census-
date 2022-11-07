select* from projcet1.dbo.Data1;
select* from projcet1.dbo.data2;

--number of rows
select COUNT(*) from projcet1.dbo.Data1;
select COUNT(*) from projcet1.dbo.data2;

--dataset for my homestate and current state
select* from  projcet1.dbo.Data1 where state in ('Madhya Pradesh','Rajasthan')

--population of the above states
select sum(population) as Population from projcet1.dbo.data2 where state in ('Madhya Pradesh','Rajasthan')

--avg growht of state
select avg(Growth)*100 as avg_growth from projcet1.dbo.Data1 where state in ('Madhya Pradesh','Rajasthan')

--population of the country
select sum(population) as Population from projcet1.dbo.data2

--avg growht of state
select state,avg(Growth)*100 as avg_growth from projcet1.dbo.Data1 group by state

 --avg sex ration
 select state, round(avg(Sex_Ratio),0) as avg_sexratio from projcet1.dbo.Data1 group by state order by avg_sexratio desc

 --top 3 states whith sex_ratio
  select top 3 state, round(avg(Sex_Ratio),0) as avg_sexratio from projcet1.dbo.Data1 group by state order by avg_sexratio desc

  --top and bottom 3 states in literacy rate
drop table if exists #topstates
  create table #topstates
  ( state nvarchar(255),
	 topstates float
	 )
insert into #topstates
select state, round(avg(literacy),0) avg_literacy_ratio from projcet1..Data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstates desc;

drop table if exists #bottomstates
  create table #bottomstates
  ( state nvarchar(255),
	 bottomstates float
	 )
insert into #bottomstates
select state, round(avg(literacy),0) avg_literacy_ratio from projcet1..Data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

--union opertator (joining in vertical fashion)
select* from(
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc)a
union
select* from(
select top 3 * from #topstates order by #topstates.topstates desc)b

--state starting with 'a'
SELECT distinct state FROM projcet1..Data1 where LOWER(State) like 'a%';


-- joining both table

--total males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from projcet1..Data1 a inner join projcet1..data2 b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from projcet1..data1 a 
inner join projcet1..data2 b on a.district=b.district) d) c
group by c.state

-- population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from projcet1..data1 a inner join projcet1..data2 b on a.district=b.district) d) e
group by e.state)m


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from projcet1..data1 a inner join projcet1..data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from projcet1..data2)z) r on q.keyy=r.keyy)g;

--window 

output top 3 districts from each state with highest literacy rate;


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from projcet1..data1) a

where a.rnk in (1,2,3) order by state
