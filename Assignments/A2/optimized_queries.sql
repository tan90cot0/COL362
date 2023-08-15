--P1--
Drop index index1;
CREATE INDEX index1 on person_likes_post(postid);
Drop index index2;
CREATE INDEX index2 on person_likes_comment(commentid);
drop index index3;
CREATE INDEX index3 on person_hasinterest_tag(tagid);

--Q1--
-- \set K 2
-- \set X 10
-- \set taglist '(\'Frank_Sinatra\',\'William_Shakespeare\', \'Elizabeth_II\', \'Adolf_Hitler\', \'George_W._Bush\')'
-- \set commentlength 100
-- \set lastdate '\'2011-07-19\''
with 
t1 AS(  SELECT id AS tid 
        FROM tag 
        WHERE tag.name in :taglist)
        -- t1 contains the tagid for the tags in the taglist
        , 
t_temp AS ( SELECT personid , person_hasinterest_tag.tagid as tag
        FROM person_hasinterest_tag
        WHERE person_hasinterest_tag.tagid in (select tid from t1)
        ) 
        --t2 contains personid with tagid if tagid is in taglist. 
,                                                
t3 as (select personid
         FROM person_hasinterest_tag
        WHERE person_hasinterest_tag.tagid in (select tid from t1)
        group by personid
        having count(tagid)>=:K) 
, 
t2 as (select t_temp.personid ,tag from t_temp where t_temp.personid in (select * from t3)),

filtered_msgs AS (
    (SELECT id ,creatorpersonid as pid 
    FROM post 
    WHERE  creationdate <:lastdate )
    UNION 
    (SELECT id ,creatorpersonid as pid
    FROM comment 
    WHERE comment.length >:commentlength) ) 
    -- this table stores all the relevant messages
,
msgs_with_likers AS (
    SELECT postid AS messageid ,personid , pid  FROM person_likes_post ,filtered_msgs as fm where fm.id=postid
    UNION
    SELECT commentid AS messageid,personid , pid FROM person_likes_comment , filtered_msgs as fm where fm.id=commentid
), -- this table stores all the messages with the person that likes them 
-- this table stores filtered messages along with persons that like those messages. 
people_pairs AS (
    SELECT t21.personid AS p1id, t22.personid AS p2id 
    FROM t2 AS t21 ,t2 AS t22 
    WHERE t21.personid<t22.personid and t21.tag = t22.tag
    group by p1id, p2id
    having count(t21.tag)>=:K) ,

-- this table stores all the possible pairs of people that satisfy condition1 , they may also already be fiends. 


-- people_pairs AS (
--     select pbp.p1id as p1id, pbp.p2id as p2id 
--     from people_basic_pairs as pbp
--     where (p1id,p2id) not in (select person1id , person2id from person_knows_person)
-- ),f1.person2id AS p1id, f2.person2id AS p2id 
common_friends AS(
    (SELECT f1.person1id AS fID , pp.p1id AS p1id, pp.p2id AS p2id 
    FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp 
    WHERE  f1.person1id=f2.person1id  AND f1.person2id=pp.p1id AND f2.person2id=pp.p2id )
    
    union all 
          (  SELECT f1.person1id AS fID , pp.p1id AS p1id, pp.p2id AS p2id 
            FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp
            where f1.person1id=f2.person2id AND f1.person2id = pp.p1id AND f2.person1id = pp.p2id )

    union all

   ( SELECT f1.person2id AS fID ,  pp.p1id AS p1id, pp.p2id AS p2id 
    FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp 
    WHERE  f1.person2id=f2.person1id  AND f1.person1id=pp.p1id AND f2.person2id=pp.p2id )
            
            
    union all 
     (   SELECT f1.person2id AS fID ,  pp.p1id AS p1id, pp.p2id AS p2id 
        FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp 
        where f1.person2id=f2.person2id AND f1.person1id = pp.p1id AND f2.person1id = pp.p2id )
) ,
common_likes_to_messages_by_common_friends AS (
    SELECT mwl1.personid AS person1sid, mwl2.personid AS person2sid 
    FROM msgs_with_likers AS mwl1, msgs_with_likers AS mwl2, people_pairs AS pp , common_friends as cf
    WHERE mwl1.messageid=mwl2.messageid AND mwl1.personid=pp.p1id AND mwl2.personid = pp.p2id AND mwl1.pid = cf.fID and pp.p1id= cf.p1id and pp.p2id = cf.p2id 
    GROUP BY mwl1.personid , mwl2.personid 
    HAVING count(mwl1.messageid) >= :X
),

result AS (
    select upper.person1sid as person1sid , upper.person2sid as person2sid 
    from common_likes_to_messages_by_common_friends as upper 
    where (person1sid,person2sid)not in (select pkp.person1id , pkp.person2id from person_knows_person as pkp)
    and (person2sid,person1sid)not in (select pkp.person1id , pkp.person2id from person_knows_person as pkp)
    

)
    ,  fr as (select person1sid , person2sid , count(fID) as mutualFriendCount
    from result as r , common_friends as cf where person1sid=cf.p1id and person2sid=cf.p2id
    group by person1sid,person2sid
    ORDER BY person1sid asc, mutualFriendCount desc, person2sid asc)

    select * from fr;

--C1--    
Drop index index1;
drop index index2;
drop index index3;

--P2--


--Q2--
-- \set startdate '\'2010-06-01\''
-- \set enddate '\'2012-07-01\''
-- \set country_name '\'China\''
with 
city_country as 
(select place1.id as cityid, place2.id as countryid
from place as place1 , place as place2 
where place1.type='City' AND place2.type='Country' AND place1.partofplaceid=place2.id),

id_of_country as
    (select id 
    from place 
    where place.type='Country' and place.name = :country_name),

relevant_people as 
(select p.id as pid 
from person as p, city_country as cc ,id_of_country as idc 
where p.locationcityid=cc.cityid and cc.countryid=idc.id and creationdate>:startdate and creationdate< :enddate)

, 
info_relevant_people as (select rp.pid as pid ,SUBSTRING((CAST(birthday as text)),6,2) as birthmonth, universityid as univid 
from relevant_people as rp , person as p  ,  person_studyat_university as psu
where rp.pid = p.id AND rp.pid= psu.personid  
) -- this table here contains all the relevant people with the info we need about them . 

,
filtered_person_knows_person as 
(select irp1.pid as person1id , irp2.pid as person2id
from  info_relevant_people as irp1 , info_relevant_people as irp2 
where irp1.birthmonth=irp2.birthmonth and irp1.univid=irp2.univid and (irp1.pid,irp2.pid) in (select person1id,person2id from person_knows_person))
,
transitive_triple as 
(select pp1.person1id as p1id , pp1.person2id as p2id , pp2.person2id as p3id 
from filtered_person_knows_person as pp1 JOIN filtered_person_knows_person as pp2 
on pp1.person2id = pp2.person1id)
,
cliques as 
(   select tt.p1id as p1id, tt.p2id as p2id, tt.p3id as p3id 
    from transitive_triple as tt  
    where (p1id,p3id) in (select person1id, person2id from filtered_person_knows_person) 
)
select count(*) from cliques;

--C2--


--P3--
drop index index1;
CREATE index index1
on post_hastag_tag(creationDate);
drop index index2;
CREATE index index2
on comment_hastag_tag(creationDate);

--Q3--
-- \set begindate '\'2010-02-03\''
-- \set middate '\'2010-12-03\''
-- \set enddate '\'2011-05-03\''
with 
first_half_table(first_half, tagid) as
(
    select count(messages) as first_half, tagid
    from 
    (
        select postid as messages, tagid from post_hastag_tag
        where creationDate >= :begindate and creationDate <= :middate

        union all

        select commentid as messages, tagid from comment_hastag_tag
        where creationDate >= :begindate and creationDate <= :middate
    )
    as t2
    group by tagid
),
second_half_table(second_half, tagid) as
(
    select count(messages) as first_half, tagid
    from 
    (
        select postid as messages, tagid from post_hastag_tag
        where creationDate >= :middate and creationDate <= :enddate

        union all

        select commentid as messages, tagid from comment_hastag_tag
        where creationDate >= :middate and creationDate <= :enddate
    )
    as t2
    group by tagid
),
combined(tagid) as
(
    select f.tagid 
    from first_half_table as f, second_half_table as s
    where first_half>=5*second_half and f.tagid = s.tagid
)
select tagclass.name as tagclassname, count(tagid) 
from combined, tagclass, tag
where tagid = tag.id and tag.TypeTagClassId = tagclass.id
group by tagclass.id, tagclass.name
order by count(tagid) desc, tagclassname;

--C3--
drop index index1;
drop index index2;

--P4--


--Q4--
-- \set X 4

select tag.name as tagname, num_posts+num_comments as count 
from
(
    select count(postid) as num_posts, tagid 
    from
    (
        select parentpostid as posts from comment
        where parentpostid is not null
        group by parentpostid
        having count(id)>=:X
    ) as t1, post_hastag_tag
    where postid = posts
    group by tagid
    order by num_posts desc
) as t3, 
(
    select count(commentid) as num_comments, tagid 
    from
    (
        select parentcommentid as comments from comment
        where parentcommentid is not null
        group by parentcommentid
        having count(id)>=:X
    ) as t2, comment_hastag_tag
    where commentid = comments
    group by tagid
    order by num_comments desc
) as t4, tag
where t3.tagid = t4.tagid and t3.tagid = tag.id
order by count desc, tagname
limit 10;

--C4--


--P5--
drop index index4;
drop index index5;
drop index index6;
drop index index7;
drop index index8;
drop index index9;

create index index4 on post(containerforumid);
create index index5 on tag(TypeTagClassId);
create index index6 on person(locationcityid);
create index index7 on forum(moderatorpersonid);
create index index8 on place(partofplaceid, type, name);
create index index9 on tagclass(name);

--Q5--
-- \set country_name '\'India\''
-- \set tagclass '\'TennisPlayer\''
with 
ranked_table(num_posts, forum_id, tagid, rank) as 
(
    select num_posts, forum_id, tagid, ROW_NUMBER() OVER (PARTITION BY forum_id ORDER BY num_posts desc) as rank
    from
    (
        select count(post.id) as num_posts, forum_ids as forum_id, tagid
        from 
        (
            select forum_ids
            from
            (
                select forum.id as forum_ids
                from place as t1, place as t2, person, forum
                where t1.type = 'City' and t1.partofplaceid = t2.id and t2.name = :country_name and t1.id = person.locationcityid and forum.moderatorpersonid = person.id
            
                intersect

                select distinct containerforumid as forum_ids
                from post_hastag_tag, post, tag, tagclass
                where post.id = postid and tag.id = tagid and TypeTagClassId = tagclass.id and tagclass.name = :tagclass
            ) as t4

        ) as t5, post, post_hastag_tag
        where post.containerforumid = forum_ids and post_hastag_tag.postid = post.id
        group by forum_ids, tagid
    ) as t6
),
max_count(num_posts, forum_id) as 
(
    select num_posts, forum_id from ranked_table
    where rank = 1
),
mostpop(num_posts, forum_id, tagid) as
(
    select ranked_table.num_posts, ranked_table.forum_id, tagid 
    from ranked_table, max_count
    where ranked_table.num_posts = max_count.num_posts and ranked_table.forum_id = max_count.forum_id
)
select forum_id as forumid, forum.title as forumtitle, tag.name as mostpopulartagname, num_posts as count
from mostpop, forum, tag
where forum.id = forum_id and tagid = tag.id
order by count desc, forumid, forumtitle, mostpopulartagname;

--C5--
drop index index4;
drop index index5;
drop index index6;
drop index index7;
drop index index8;
drop index index9;
