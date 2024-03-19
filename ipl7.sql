/*select * from dbo.dim_match_summary;
select * from dbo.dim_players;
select * from dbo.fact_bating_summary;
select * from dbo.fact_bowling_summary;

select *,right(matchDate,4)as yearn  into dim_match_summary_new from dbo.dim_match_summary;

select sum(f.balls) as total_balls,f.batsmanName,d.yearn into dim_match from dbo.fact_bating_summary f  inner join dim_match_summary_new d
on f.match_id=d.match_id
group by f.batsmanName,d.yearn;


select min(a.total_balls) as min_total_balls,a.batsmanName as batsmanName into dim_match_new from dim_match a
group by a.batsmanName  having min(a.total_balls)>60;


select top 10 (sum(f.runs)/count(f.match_id)) as average,f.batsmanName from dbo.fact_bating_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id
where f.batsmanName in(select batsmanName from dim_match_new)
group by f.batsmanName
order by average desc;


select top 10 sum(f.runs) as total_runs ,f.batsmanName from dbo.fact_bating_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id
where f.batsmanName in(select batsmanName from dim_match_new)
group by f.batsmanName
order by total_runs desc



select top 10 (sum(f.SR)/count(f.match_id)) as average_strike_rate,f.batsmanName from dbo.fact_bating_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id 
where f.batsmanName in(select batsmanName from dim_match_new)
group by f.batsmanName
order by average_strike_rate desc;
*/


/*select sum(f.overs)*6 as total_balls,f.bowlerName,d.yearn into dim_match_ball from dbo.fact_bowling_summary f  inner join dim_match_summary_new d
on f.match_id=d.match_id
group by f.bowlerName,d.yearn;


select min(a.total_balls) as min_total_balls,a.bowlerName as bowlerName into dim_match_new_ball from dim_match_ball a
group by a.bowlerName  having min(a.total_balls)>60;*/


/*select top 10 (sum(f.wickets)/count(f.match_id)) as average,f.bowlerName from dbo.fact_bowling_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id
where f.bowlerName in(select bowlerName from dim_match_new_ball)
group by f.bowlerName
order by average desc;
*/


select top 10 (sum(f.wickets)/count(f.match_id)) as average_wickets,f.bowlerName from dbo.fact_bowling_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id
where f.bowlerName in(select bowlerName from dim_match_new_ball)
group by f.bowlerName
order by average_wickets desc;


select top 10 sum(f.wickets) as total_wickets,f.bowlerName from dbo.fact_bowling_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id
where f.bowlerName in(select bowlerName from dim_match_new_ball)
group by f.bowlerName
order by total_wickets desc;



select top 10 round((sum(f.economy)/count(f.match_id)),2) as average_economy_rate,f.bowlerName from dbo.fact_bowling_summary f inner join dbo.dim_match_summary d
on f.match_id=d.match_id 
where f.bowlerName in(select bowlerName from dim_match_new_ball)
group by f.bowlerName
order by average_economy_rate;
select * from dbo.dim_match_summary;

select f.batsmanName,sum(f.balls) as total_balls,Round(1.0*(sum(f._4s)+sum(f._6s))/(sum(f.balls)+1),2) as percent_4s_6s from dbo.fact_bating_summary f group by f.batsmanName order by percent_4s_6s desc;
select f.bowlerName,sum(f.overs*6) as total_balls,Round(1.0*(sum(f._0s)/(sum(f.overs*6)+1)),2) as percent_0s from dbo.fact_bowling_summary f group by f.bowlerName order by percent_0s desc;

select * from dbo.fact_bating_summary;
select * from dbo.dim_match_summary;
with a as(
select team1,case when team1=winner then 1 else 0 end as win_flag from dbo.dim_match_summary
union all
select team2,case when team2=winner then 1 else 0 end as win_flag from dbo.dim_match_summary
)

select a.team1,round(1.01*sum(a.win_flag)/count(*),2) as winning_percentage from a  group by team1 order by winning_percentage;

select winner,count(margin) as win_chase from dbo.dim_match_summary where margin like '%wickets' group by winner order by win_chase;


