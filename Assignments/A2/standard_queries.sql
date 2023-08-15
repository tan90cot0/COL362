--1--
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
t2 AS ( SELECT personid , person_hasinterest_tag.tagid as tag
        FROM person_hasinterest_tag
        WHERE person_hasinterest_tag.tagid in (select tid from t1)
        ) 
        --t2 contains personid with tagid if tagid is in taglist. 
, 
filtered_msgs AS (
    (SELECT id 
    FROM post 
    WHERE  creationdate <:lastdate )
    UNION 
    (SELECT id 
    FROM comment 
    WHERE comment.length >:commentlength) ) 
    -- this table stores all the relevant messages
    ,

messages AS (
    SELECT id ,creatorpersonid AS pid FROM comment 
    union 
    SELECT id ,creatorpersonid AS pid FROM post
) 
-- this table is a mapping of messages with the person who posted them . 
, 

filtered_msgs_posters AS (
    SELECT m.id AS id ,m.pid AS pid 
    FROM filtered_msgs AS fm , messages AS m 
    WHERE m.id=fm.id
) -- this table stores filtered messages along with their creator's id. 
,
person_likes_message AS (
    SELECT postid AS messageid ,personid FROM person_likes_post
    UNION
    SELECT commentid AS messageid,personid FROM person_likes_comment
), -- this table stores all the messages with the person that likes them 
msgs_with_likers AS (
    SELECT id as messageid,personid 
    FROM person_likes_message AS plm ,filtered_msgs AS fm 
    WHERE fm.id=plm.messageid 
) , -- this table stores filtered messages along with persons that like those messages. 
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
    SELECT f1.person1id AS fID , pp.p1id AS p1id, pp.p2id AS p2id 
    FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp 
    WHERE  (f1.person1id=f2.person1id  AND f1.person2id=pp.p1id AND f2.person2id=pp.p2id) 
            or
            (f1.person1id=f2.person2id AND f1.person2id = pp.p1id AND f2.person1id = pp.p2id )

    union all

    SELECT f1.person2id AS fID ,  pp.p1id AS p1id, pp.p2id AS p2id 
    FROM person_knows_person AS f1, person_knows_person AS f2, people_pairs  AS pp 
    WHERE  (f1.person2id=f2.person1id  AND f1.person1id=pp.p1id AND f2.person2id=pp.p2id) 
            or
            (f1.person2id=f2.person2id AND f1.person1id = pp.p1id AND f2.person1id = pp.p2id )

) ,
common_likes AS (
    SELECT mwl1.messageid AS message_id , mwl1.personid AS p1id, mwl2.personid AS p2id 
    FROM msgs_with_likers AS mwl1, msgs_with_likers AS mwl2, people_pairs AS pp 
    WHERE mwl1.messageid=mwl2.messageid AND mwl1.personid=pp.p1id AND mwl2.personid = pp.p2id
),
common_likes_to_messages_by_common_friends AS (
    SELECT cl.p1id AS person1sid, cl.p2id AS person2sid 
    FROM common_likes AS cl, common_friends AS cf, filtered_msgs_posters AS fmp
    WHERE cl.p1id = cf.p1id AND  cl.p2id = cf.p2id AND  cf.fID=fmp.pid  AND cl.message_id=fmp.id
    GROUP BY cl.p1id , cl.p2id 
    HAVING count(cl.message_id) >= :X
)
,
result AS (
    select upper.person1sid as person1sid , upper.person2sid as person2sid 
    from common_likes_to_messages_by_common_friends as upper 
    where (person1sid,person2sid)not in (select pkp.person1id , pkp.person2id from person_knows_person as pkp)
    and (person2sid,person1sid)not in (select pkp.person1id , pkp.person2id from person_knows_person as pkp)
    

),
result_with_common_friends as (
    select person1sid , person2sid , count(fID) as mutualFriendCount
    from result as r , common_friends as cf where person1sid=cf.p1id and person2sid=cf.p2id
    group by person1sid,person2sid
    
    ORDER BY person1sid asc, mutualFriendCount desc, person2sid asc
)
-- CREATE INDEX indexpp on people_pairs(p1id);
SELECT * from result_with_common_friends;

--2--
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

--3--
-- \set begindate '\'2010-02-03\''
-- \set middate '\'2010-12-03\''
-- \set enddate '\'2011-05-03\''

with message_hasTag_Tag as 
(select creationDate as date , commentid as id, tagid as tagid 
from comment_hastag_tag
union 
select creationDate as date , postid as id, tagid as tagid 
from post_hastag_tag
),
message_count_start as 
(select tag.id as tagid, tag.name as name ,count(mhtt.id) as count 
from tag,message_hasTag_Tag as mhtt 
where mhtt.tagid=tag.id and mhtt.date >= :begindate and mhtt.date <= :middate 
group by tag.id, tag.name
),
message_count_end as 
(select tag.id as tagid, tag.name as name ,count(mhtt.id) as count 
from tag,message_hasTag_Tag as mhtt 
where mhtt.tagid=tag.id and mhtt.date >= :middate and mhtt.date <= :enddate 
group by tag.id, tag.name
),
tags_selected as 
(
    select mce.name as tname , mce.tagid as tagid , mcs.count as mcs , mce.count as mce , t.TypeTagClassId as classid 
    from message_count_end as mce , message_count_start as mcs , tag as t where t.id=mce.tagid and  mce.tagid=mcs.tagid and mcs.count>=5*mce.count 
),
tag_classes_selected as 
(select tc.name as tagclassname , count(tagid) as count 
from tags_selected as ts, tagclass as tc 
where tc.id = ts.classid
group by tc.name
order by count desc , tagclassname asc
)
select * from tag_classes_selected;

--4--
-- \set X 4
with messages as 
(select coalesce(parentcommentid,parentpostid) as messageid from comment group by coalesce(parentcommentid,parentpostid) having count(id)>=:X)
,
 message_hastag_tag as 
(select postid as messageid , tagid , tag.name as tagname from post_hastag_tag , tag 
where tag.id=tagid
union 
select commentid as messageid ,tagid , tag.name as tagname from comment_hastag_tag ,tag
where tag.id=tagid
),
 toptags_in_messages as 
(select   tagname , count(messages.messageid) as count from messages , message_hasTag_Tag WHERE
message_hasTag_Tag.messageid = messages.messageid group by tagname order by count desc, tagname asc LIMIT 10)
select * from toptags_in_messages;

--5--
-- \set country_name '\'India\''
-- \set tagclass '\'TennisPlayer\''
with 
test_table(num_posts, forum_id, tagid, rank) as 
(
    select num_posts, forum_id, tagid, ROW_NUMBER() OVER (PARTITION BY forum_id ORDER BY num_posts desc) as rank
    from
    (
        select count(post.id) as num_posts, forum_ids as forum_id, tagid
        from 
        (
            select condition1 as forum_ids
            from
            (
                select forum.id as condition1
                from place as t1, place as t2, person, forum
                where t1.type = 'City' and t1.partofplaceid = t2.id and t2.name = :country_name and t1.id = person.locationcityid and forum.moderatorpersonid = person.id
            ) as t3,
            (
                select distinct containerforumid as condition2
                from post_hastag_tag, post, tag, tagclass
                where post.id = postid and tag.id = tagid and TypeTagClassId = tagclass.id and tagclass.name = :tagclass
            ) as t4
            where condition1 = condition2
        ) as t5, post, post_hastag_tag
        where post.containerforumid = forum_ids and post_hastag_tag.postid = post.id
        group by forum_ids, tagid
    ) as t6
),
max_count(num_posts, forum_id) as 
(
    select num_posts, forum_id from test_table
    where rank = 1
),
mostpop(num_posts, forum_id, tagid) as
(
    select test_table.num_posts, test_table.forum_id, tagid 
    from test_table, max_count
    where test_table.num_posts = max_count.num_posts and test_table.forum_id = max_count.forum_id
)
select forum_id as forumid, forum.title as forumtitle, tag.name as mostpopulartagname, num_posts as count
from mostpop, forum,tag 
where forum.id = forum_id and tag.id=tagid
order by count desc, forumid, forumtitle, mostpopulartagname;
