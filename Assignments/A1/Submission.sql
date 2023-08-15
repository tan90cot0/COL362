--1--
select t.playerID, nameFirst as firstname, nameLast as lastname, total_caught_stealing 
from 
(
    select count(cs) as total_caught_stealing, playerID 
    from Batting 
    group by playerID
) 
as t 
JOIN People 
ON People.playerID = t.playerID 
order by total_caught_stealing desc, nameFirst, nameLast, playerID 
limit 10;

--2--
select t.playerID, nameFirst as firstname, runscore 
from 
(
    select playerID, coalesce(runscore_null, 0) as runscore 
    from 
    (
        select playerID, sum(runs) as runscore_null 
        from 
        (
            select playerID, (2*h2b + 3*h3b + 4*hr) as runs 
            from batting
        )
        as t2 
        group by playerID
    ) 
    as t3
) 
as t 
JOIN People 
ON People.playerID = t.playerID 
order by runscore desc, nameFirst desc, playerID 
limit 10;

--3--
select t.playerID, coalesce(nameFirst, '')||' '||coalesce(nameLast, '')  as playername, total_points 
from 
(
    select playerID, sum(pointsWon) as total_points 
    from awardsshareplayers 
    where yearID>1999 
    group by playerID
) 
as t 
JOIN People 
on People.playerID = t.playerID 
order by total_points desc, playerID;

--4--
select t2.playerID, nameFirst as firstname, nameLast as lastname, career_batting_average 
from (
    select playerID, avg(avg_score) as career_batting_average
    from (  select yearID, playerID, sum(h)::float/sum(ab) as avg_score 
            from batting 
            where h is not null and ab is not null and ab != 0 
            group by playerID, yearID) as t 
    group by playerID 
    having count(avg_score) >=10) as t2
join People
on t2.playerID = People.playerID
order by career_batting_average desc, playerID, firstname, lastname
limit 10;

--5--
select t2.playerID, nameFirst as firstname, nameLast as lastname, coalesce(birthYear::varchar(4)||'-'||birthMonth::varchar(2)||'-'||birthDay::varchar(2), '') as date_of_birth, seasons as num_seasons
from
(
    select distinct playerID, count(yearID) as seasons
    from
    (
        select distinct playerID, yearID
        from
        (
            select playerID, yearID 
            from fielding
            group by playerID, yearID

            union all

            select playerID, yearID 
            from batting
            group by playerID, yearID

            union all

            select playerID, yearID 
            from pitching
            group by playerID, yearID
        )
        as t10
    )
    as t 
    group by playerID
)
as t2
join People
on t2.playerID = People.playerID
order by seasons desc, playerID, firstname, lastname, date_of_birth;

--6--
select teamid, teamname, franchName as franchisename, num_wins
from 
(
    select teamid, name as teamname, max(w) as num_wins, franchID
    from teams 
    where divwin = True
    group by teamid, name, franchID
) 
as t
join teamsfranchises
on t.franchID = teamsfranchises.franchID
order by num_wins desc, teamid, teamname, franchisename;

--7--
WITH temporaryTable (teamid2, percent, total_wins) as
(   
    SELECT teamid, maxp, total_wins
    FROM
    (
        select teamid, max(percentage) as maxp, sum(wins) as total_wins
        from
        (
            select teamid, sum(w) as wins,sum(w)::float*100/sum(g) as percentage, yearID
            from teams
            group by teamid, yearID
            order by teamid
        ) 
        as t
        group by teamid
    )
    as t2
)
SELECT teamid, teamname, yearID as seasonid, percentage as winning_percentage
FROM
(
    select teamid, sum(w) as wins,sum(w)::float*100/sum(g) as percentage, yearID, name as teamname
    from teams
    group by teamid, yearID, name
    order by teamid

) as t3, temporaryTable
WHERE t3.percentage = temporaryTable.percent and t3.teamid = temporaryTable.teamid2 and temporaryTable.total_wins>=20
order by winning_percentage desc, teamid, teamname, seasonid
limit 5;
 
--8--
WITH temporaryTable (max_sal, teamid2, yearID2) as
(   
    SELECT max(salary), teamid, yearID
    FROM salaries
    group by teamid, yearID
)
select distinct teamid, teamname, yearID as seasonid, t.playerID, nameFirst as player_firstname, nameLast as player_lastname, salary
from
(
    SELECT distinct yearID, teamid, t2.playerID, salary, teamname, nameFirst, nameLast
    FROM 
    (
        SELECT salaries.yearID, salaries.teamid, playerID, salary, name as teamname
        from salaries join teams
        on salaries.teamid = teams.teamid
    ) 
    as t2 join People
    on t2.playerID = People.playerID
)
as t, temporaryTable
WHERE t.salary = temporaryTable.max_sal and t.teamid = temporaryTable.teamid2 and t.yearID = temporaryTable.yearID2
order by teamid, teamname, seasonid, playerID, player_firstname, player_lastname, salary desc;


--9--
select player_category, avg_salary
from
(
    select avg(salary) as avg_salary, 'batting' as player_category
    from
    (
        select batting.playerID, batting.yearID, batting.teamID, salary 
        from salaries, batting
        where batting.playerID = salaries.playerID and batting.yearID = salaries.yearID and batting.teamID = salaries.teamID and salary>=0 and batting.lgid = salaries.lgid
    ) 
    as t

    union all

    select avg(salary) as sal, 'pitching' as category
    from
    (
        select pitching.playerID, pitching.yearID, pitching.teamID, salary 
        from salaries, pitching
        where pitching.playerID = salaries.playerID and pitching.yearID = salaries.yearID and pitching.teamID = salaries.teamID and salary>=0 and pitching.lgid = salaries.lgid
    ) 
    as t4
) 
as t2
order by avg_salary desc
limit 1;

--10--

select t.playerid, coalesce(nameFirst, '')||' '||coalesce(nameLast, '')  as playername, number_of_batchmates
from
(
    select p1 as playerID, count(p2)-1 as number_of_batchmates
    from
    (
        select distinct A.playerID as p1, B.playerID as p2
        from collegeplaying A, collegeplaying B
        where A.schoolid = B.schoolid and A.yearID = B.yearID and A.playerID!=B.playerID
    )
    as t2
    group by p1
    order by number_of_batchmates desc, p1
)
as t
join People
on People.playerID = t.playerID;

--11--
select teamid, name as teamname, count(yearID) as total_ws_wins from teams
where wswin = True and g>=110
group by teamid, name
order by total_ws_wins desc, teamid, teamname
limit 5;

--12--
select t.playerID, nameFirst as firstname, nameLast as lastname, career_saves, num_seasons
from 
(
    select playerID, sum(sv) as career_saves, count(yearID) as num_seasons from pitching
    group by playerID
)
as t
join People
on People.playerID = t.playerID
where num_seasons>=15
order by career_saves desc, num_seasons desc, playerID, firstname, lastname
limit 10;

--13--
select t5.playerID, nameFirst as firstname, nameLast as lastname, lower(coalesce(birthCity||' '||birthState||' '||birthCountry, '')) as birth_address, first_teamname, second_teamname
from
(
    select t3.playerID, first_teamname, second_teamname 
    from
    (
        select t2.playerID, teamid as first_teamname
        from 
        (
            select t100.playerID, pitching.teamid, ROW_NUMBER() OVER (PARTITION BY t100.playerID ORDER BY pitching.yearID, pitching.stint) as earliest_rank from
            (
                select distinct playerID, count(teamid) as diff_teams 
                from pitching
                group by playerID
                having count(teamid)>=5
            ) as t100, pitching
            where pitching.playerID = t100.playerID
        )
        as t2
        where earliest_rank=1
    )
    as t3
    join
    (
        select t.playerID, teamid as second_teamname
        from 
        (
            select t10.playerID, pitching.teamid, ROW_NUMBER() OVER (PARTITION BY t10.playerID ORDER BY pitching.yearID, pitching.stint) as earliest_rank from
            (
                select distinct playerID, count(teamid) as diff_teams 
                from pitching
                group by playerID
                having count(teamid)>=5
            ) as t10, pitching
            where pitching.playerID = t10.playerID
        )
        as t
        where earliest_rank=2
    )
    as t4
    on t3.playerID = t4.playerID
)
as t5
join People
on People.playerID = t5.playerID
order by t5.playerID, firstname, lastname, birth_address, first_teamname, second_teamname;


--14--
insert into people values   ('dunphil02', null, null, null, null, null, null, null, null, null, null, null, null, 'Phil', 'Dunphy', null, null, null, null, null, null, null, null, null), 
                            ('tuckcam01', null, null, null, null, null, null, null, null, null, null, null, null, 'Cameron', 'Tucker', null, null, null, null, null, null, null, null, null),
                            ('scottm02', null, null, null, null, null, null, null, null, null, null, null, null, 'Michael', 'Scott', null, null, null, null, null, null, null, null, null),
                            ('waltjoe', null, null, null, null, null, null, null, null, null, null, null, null, 'Joe', 'Walt', null, null, null, null, null, null, null, null, null);
insert into AwardsPlayers values    ('dunphil02', 'Best Baseman', 2014, '', True, null), 
                                    ('tuckcam01', 'Best Baseman', 2014, '', True, null), 
                                    ('scottm02', 'ALCS MVP', 2015, 'AA', False, null), 
                                    ('waltjoe', 'Triple Crown', 2016, '', null, null), 
                                    ('adamswi01', 'Gold Glove', 2017, '', False, null), 
                                    ('yostne01', 'ALCS MVP', 2017, '', null, null);

select awardID, t.playerID, nameFirst as firstname, nameLast as lastname, num_wins
from
(
    select playerID, awardID, count(yearID) as num_wins, ROW_NUMBER() OVER (PARTITION BY awardID ORDER BY count(yearID) desc, playerID) as rank
    from AwardsPlayers
    group by playerID, awardID
)
as t, People
where rank = 1 and t.playerID = People.playerID
order by awardID, num_wins desc;

--15--
select distinct teamID, teamname, seasonid, Managerid, nameFirst as managerfirstname, nameLast as managerlastname
from
(
    select distinct t.teamID, name as teamname, seasonid, Managerid
    from
    (
        select teamid, playerID as Managerid, yearID as seasonid
        from Managers
        where yearID>=2000 and yearID<=2010 and (inseason = 0 or inseason = 1)
    )
    as t
    join teams
    on teams.teamID = t.teamID
) 
as t2
join People
on People.playerID = Managerid
order by teamID, teamname, seasonid desc, Managerid, managerfirstname, managerlastname;

--16--
select distinct playerID, schoolName as colleges_name, total_awards
from
(
    select playerID, schoolID, total_awards
    from
    (
        select distinct t.playerID, schoolID, total_awards, yearID, ROW_NUMBER() OVER (PARTITION BY t.playerID ORDER BY yearID desc) as rank
        from
        (
            select playerID, count(awardID) as total_awards
            from AwardsPlayers
            group by playerID
        )
        as t
        left join collegeplaying
        on collegeplaying.playerID = t.playerID
        order by playerID
    )
    as t10
    where rank = 1
)
as t2
join Schools
on schools.schoolID = t2.schoolID
order by total_awards desc, colleges_name, playerID
limit 10;

--17--
select t7.playerID, nameFirst as firstname, nameLast as lastname, playerawardid, playerawardyear, managerawardid, managerawardyear
from
(
    select t3.playerid, playerawardid, playerawardyear, managerawardid, managerawardyear
    from
    (
        select playerID, playerawardyear, playerawardid
        from
        (
            select C.playerID, yearID as playerawardyear, awardID as playerawardid, ROW_NUMBER() OVER (PARTITION BY C.playerID ORDER BY yearID, awardID) as rank
            from AwardsPlayers C
            join 
            (
                select distinct A.playerID
                from AwardsManagers A, AwardsPlayers B
                where A.playerID = B.playerID
            ) 
            as t
            on t.playerID = C.playerID
        )
        as t5
        where rank = 1 
    ) 
    as t3
    join
    (
        select playerID, managerawardid, managerawardyear
        from
        (
            select D.playerID, yearID as managerawardyear, awardID as managerawardid, ROW_NUMBER() OVER (PARTITION BY D.playerID ORDER BY yearID, awardID) as rank
            from AwardsManagers D
            join 
            (
                select distinct E.playerID
                from AwardsManagers E, AwardsManagers F
                where E.playerID = F.playerID
            ) 
            as t2
            on t2.playerID = D.playerID
        )
        as t6
        where rank = 1
    )
    as t4
    on t3.playerID = t4.playerID
)
as t7, People
where People.playerID = t7.playerID
order by t7.playerID, firstname, lastname;

--18--
select t5.playerID, nameFirst as firstname, nameLast as lastname, num_honoured_categories, seasonid
from
(
    select t3.playerID, num_honoured_categories, seasonid
    from
    (
        select playerID, num_honoured_categories
        from
        (
            select playerID, count(category) as num_honoured_categories
            from
            (
                select distinct playerID, category from HallOfFame
                order by playerID
            )
            as t 
            group by playerID
        )
        as t2
        where num_honoured_categories>=2
    )
    as t3
    join
    (
        select distinct playerID, min(yearID) as seasonid from AllstarFull
        where gp = 1
        group by playerID
    )
    as t4
    on t3.playerID = t4.playerID
)
as t5, People
where People.playerID= t5.playerID
order by num_honoured_categories desc, playerID, firstname, lastname, seasonid;

--19--
select t2.playerID, nameFirst as firstname, nameLast as lastname, g_all, G_1b, G_2b, G_3b
from
(
    select playerID, g_all, G_1b, G_2b, G_3b 
    from
    (
        select playerID, sum(g_all) as g_all, sum(G_1b) as G_1b, sum(G_2b) as G_2b, sum(G_3b) as G_3b from Appearances
        group by playerID
    )
    as t
    where (G_1b>0 and G_2b>0 and G_3b=0) or (G_1b>0 and G_2b=0 and G_3b>0) or (G_1b=0 and G_2b>0 and G_3b>0) or (G_1b>0 and G_2b>0 and G_3b>0)
)
as t2
join people
on people.playerID = t2.playerID
order by G_all desc, playerID, firstname, lastname, G_1b desc, G_2b desc, G_3b desc;

--20--
select schoolID, schoolname, schooladdr, t4.playerID, nameFirst as firstname, nameLast as lastname
from
(
    select t3.schoolID, schoolname, lower(schoolCity||' '||schoolState) as schooladdr, playerID
    from
    (
        select distinct playerID, A.schoolID
        from collegeplaying A
        join
        (
            select schoolID
            from
            (
                select distinct playerID, schoolID 
                from collegeplaying
            )
            as t 
            group by schoolID
            order by count(playerID) desc
            limit 5
        )
        as t2
        on t2.schoolID = A.schoolID
    )
    as t3
    join Schools
    on schools.schoolID = t3.schoolID
)
as t4, People
where people.playerID = t4.playerID
order by schoolid, schoolname, schooladdr, playerID, firstname, lastname;

--21--
select distinct player1_id, player2_id, birthCity, birthState, CASE WHEN count(role) =2  THEN 'both' ELSE max(role) END AS role
from
(
    select distinct C.playerID as player1_id, D.playerID as player2_id, A.birthCity, A.birthState, 'batting' as role
    from batting C, batting D, people A, people B
    where C.teamID = D.teamID and A.playerID = C.playerID and B.playerId = D.playerId and A.birthCity = B.birthCity and A.birthState = B.birthState and A.playerID!=B.playerID and A.birthCity is not null and A.birthState is not null
    
    union all

    select distinct C.playerID as player1_id, D.playerID as player2_id, A.birthCity, A.birthState, 'pitching' as role
    from pitching C, pitching D, people A, people B
    where C.teamID = D.teamID and A.playerID = C.playerID and B.playerId = D.playerId and A.birthCity = B.birthCity and A.birthState = B.birthState and A.playerID!=B.playerID and A.birthCity is not null and A.birthState is not null
)
as t 
group by birthCity, birthState, player1_id, player2_id
order by birthCity, birthState, player1_id, player2_id;

--22--
select distinct awardID, seasonid, playerID, playerpoints, averagepoints
from
(
    select distinct A.playerID, A.pointsWon as playerpoints, t.averagepoints, A.awardID, A.yearID as seasonid
    from
    (
        select awardID, yearID, avg(pointsWon) as averagepoints
        from awardsshareplayers
        group by awardID, yearID
    )
    as t, awardsshareplayers A
    where A.awardID = t.awardID and A.yearID = t.yearID and A.pointsWon>=t.averagepoints

    union all

    select distinct A.playerID, A.pointsWon as playerpoints, t.averagepoints, A.awardID, A.yearID as seasonid
    from
    (
        select awardID, yearID, avg(pointsWon) as averagepoints
        from AwardsShareManagers
        group by awardID, yearID
    )
    as t, AwardsShareManagers A
    where A.awardID = t.awardID and A.yearID = t.yearID and A.pointsWon>=t.averagepoints
)
as t2
order by awardID, seasonid, playerpoints desc, playerID;

--23--
select playerID, coalesce(nameFirst, '')||' '||coalesce(nameLast, '')  as playername, CASE WHEN deathYear is not null THEN false ELSE true END AS alive
from people
where people.playerID not in 
(
    select distinct playerID 
    from awardsshareplayers 
    union all
    select distinct playerID 
    from AwardsShareManagers
)
order by playerID, playername;

--24--
CREATE TEMPORARY TABLE "Graph1"
(
    player1_number integer,
    edge integer,
    player2_number integer,
    len integer
);

select distinct C.player_num as player1_number, count(A.teamID) as edge, D.player_num as player2_number, 1 as len
into temp table Graph1
from
(
    select playerID, teamID, yearID from pitching
    union all
    select playerID, teamID, yearID from AllstarFull
)
as A, 
(
    select playerID, teamID, yearID from pitching
    union all
    select playerID, teamID, yearID from AllstarFull
)
as B,
(
    select playerID, row_number() over(order by playerid) as player_num
    from 
    (
        select playerID 
        from pitching

        union all

        select playerID 
        from AllstarFull
    ) as T
)
as C,
(
    select playerID, row_number() over(order by playerid) as player_num
    from 
    (
        select playerID 
        from pitching 

        union all

        select playerID 
        from AllstarFull
    ) as T
)
as D
where A.teamID = B.teamID and A.yearID = B.yearID and A.playerID!=B.playerID and A.playerid = C.playerID and B.playerID = D.playerID
group by A.playerID, B.playerID, C.player_num, D.player_num
order by edge desc;

select CASE WHEN count(*) = 0 THEN false ELSE true END AS pathexists
from
(
    with recursive paths(player1_number, player2_number, wt, visited) as 
    (
        select distinct player1_number, player2_number, edge, array[player1_number, player2_number] as visited
        from Graph1
        where player1_number = 9374 --start node

        union all

        select distinct paths.player1_number, Graph1.player2_number, paths.wt+Graph1.edge, array_append(paths.visited, Graph1.player2_number) 
        from paths, Graph1
        where paths.player2_number = Graph1.player1_number and Graph1.player2_number != ALL(paths.visited)
    )
    Select player1_number
    from paths 
    where wt >= 3 and player2_number = 1617
    limit 1
)
as t;

/*select player_num from 
(
    select playerID, row_number() over(order by playerid) as player_num
    from 
    (
        select playerID 
        from pitching 
        union 
        select playerID 
        from AllstarFull
    ) as T
) as t2 
where playerID = 'clemero02';*/

--25--
select CASE WHEN count(*) = 0 THEN 0 ELSE min(wt) END as pathlength
from
(
    with recursive paths(player1_number, player2_number, wt, visited) as 
    (
        select distinct player1_number, player2_number, edge, array[player1_number, player2_number] as visited
        from Graph1
        where player1_number = 3082 --start node

        union all

        select distinct paths.player1_number, Graph1.player2_number, paths.wt+Graph1.edge, array_append(paths.visited, Graph1.player2_number) 
        from paths, Graph1
        where paths.player2_number = Graph1.player1_number and Graph1.player2_number != ALL(paths.visited)
    )
    Select player1_number, visited, wt
    from paths 
    where player2_number = 5071
    limit 100
)
as t;

--26--

CREATE TEMPORARY TABLE "Map2"
(
    teamid character(3),
    team_num integer
);

select teamID, row_number() over(order by teamID) as team_num
into temp table Map2
from 
(
    select distinct teamIDwinner as teamID from
    (
        select teamIDwinner from SeriesPost
        union all
        select teamIDloser from SeriesPost
    )
    as t
    order by teamIDwinner
)
as t2;

CREATE TEMPORARY TABLE "Graph2"
(
    node1 integer,
    node2 integer
);

select m1.team_num as node1, m2.team_num as node2
into temp table Graph2
from
(
    select distinct teamIDwinner as team1, teamIDloser as team2
    from SeriesPost
) 
as t,
Map2 as m1,
Map2 as m2
where m1.teamid = t.team1 and m2.teamid = t.team2;

select count(node1) from 
(
    with recursive paths(node1, node2, visited) as 
        (
            select distinct node1, node2, array[node1, node2] as visited
            from Graph2
            where node1 = 2 --start node

            union all

            select distinct paths.node1, Graph2.node2, array_append(paths.visited, Graph2.node2) 
            from paths, Graph2
            where paths.node2 = Graph2.node1 and Graph2.node2 != ALL(paths.visited)
        )
        Select node1
        from paths 
        where node2 = 16
        --limit 100
)
as t;

--27--
select node2 as teamid, max(hops) as num_hops
from
(
    with recursive paths(node1, node2, visited, hops) as 
        (
            select distinct node1, node2, array[node1, node2] as visited, 1 as hops
            from Graph2
            where node1 = 19 --start node

            union all

            select distinct paths.node1, Graph2.node2, array_append(paths.visited, Graph2.node2), paths.hops + 1
            from paths, Graph2
            where paths.node2 = Graph2.node1 and Graph2.node2 != ALL(paths.visited) and paths.hops <=2
        )
        Select node1, node2, visited, hops
        from paths
        where node2!=19
)
as t2
group by node2
order by teamid;
     

--28--
CREATE TEMPORARY TABLE "LastNodes"
(
    node integer,
    hops integer
);

with recursive paths(node1, node2, visited, hops) as 
    (
        select distinct node1, node2, array[node1, node2] as visited, 1 as hops
        from Graph2
        where node1 = 49 --start node

        union all

        select distinct paths.node1, Graph2.node2, array_append(paths.visited, Graph2.node2), paths.hops + 1
        from paths, Graph2
        where paths.node2 = Graph2.node1 and Graph2.node2 != ALL(paths.visited)
    )
    Select node2 as node, hops
    into temp table LastNodes
    from paths
    limit 100;


select teamid, teamname, pathlength
from
(
    select distinct map2.teamID, name as teamname, pathlength, yearID, ROW_NUMBER() OVER (PARTITION BY map2.teamID ORDER BY yearID desc) as rank
    from
    (
        select node, max(hops) as pathlength
        from
        (
            WITH max_finder (max_val) as
            (
                SELECT max(hops)
                FROM LastNodes
            )
                SELECT node, hops
                FROM LastNodes, max_finder
                WHERE LastNodes.hops = max_finder.max_val
        )
        as t
        group by node
    )
    as t2,
    map2,
    teams
    where t2.node = map2.team_num and map2.teamID = teams.teamid
    order by teamID, teamname
)
as t3
where rank = 1
order by teamID, teamname;

--29--


select distinct map2.teamID, pathlength
from
(
with recursive paths(node1, node2, visited, hops) as 
        (
            select distinct node1, node2, array[node1, node2] as visited, 1 as hops
            from Graph2
            where node1 = ANY   (
                                    select team_num from
                                    (
                                        select teamIDwinner from SeriesPost
                                        where ties > losses
                                        order by yearID
                                    ) 
                                    as t, Map2
                                    where Map2.teamid = t.teamIDwinner
                                )
                                -- set A
            union all

            select distinct paths.node1, Graph2.node2, array_append(paths.visited, Graph2.node2) , paths.hops + 1
            from paths, Graph2
            where paths.node2 = Graph2.node1 and Graph2.node2 != ALL(paths.visited)
        )
        Select node1 as team_num, hops as pathlength
        from paths 
        where node2 = 30
        limit 1
--nya is 30
)
as t2,
map2
where t2.team_num = map2.team_num
order by teamID, pathlength;

--30--
CREATE TEMPORARY TABLE "NumCycles"
(
    hops integer
);

with recursive paths(node1, node2, visited, hops) as 
    (
        select distinct node1, node2, array[node1, node2] as visited, 1 as hops
        from Graph2
        where node1 = 16 --start node

        union all

        select distinct paths.node1, Graph2.node2, array_append(paths.visited, Graph2.node2), paths.hops + 1
        from paths, Graph2
        where paths.node2 = Graph2.node1 and (Graph2.node2 != ALL(paths.visited) or Graph2.node2 = 16)
    )
    Select hops
    into temp table NumCycles
    from paths 
    where node2 = 16;
    --limit 100;

WITH max_finder (max_val) as
(
    SELECT max(hops)
    FROM NumCycles
)
    SELECT max(hops) as cyclelength, count(hops) as numcycles
    FROM NumCycles, max_finder
    WHERE NumCycles.hops = max_finder.max_val;
