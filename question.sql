use day1;
#1
select CONCAT(professor.prof_fname, ' ', professor.prof_lname) as 'Professor Name', CONCAT(Student.stud_fname, ' ', Student.stud_lname) as 'Student Name',
Class.class_name as 'Class Name'
from professor
         inner join Class on professor.prof_id = class.prof_id
         inner join Enroll on class.class_id = Enroll.class_id
         inner join Student on Enroll.stud_id = Student.stud_id;
#2
select distinct(Course.course_name)
from Course
         inner join Class on Course.course_id = Class.course_id;

#3
select distinct(Course.course_name)
from Course
         inner join Class on Course.course_id = Class.course_id
         inner join enroll on class.class_id = enroll.class_id;
         
#4 
create or replace view grade as 
select e.class_id, e.stud_id,
case e.grade 
	when 'A' then 10
	when 'B' then 8
	when 'C' then 6
	when 'D' then 4
	when 'E' then 2
	when 'F' then 0
    end
as 'grade'
from enroll e;

#5
select concat(s.stud_fname, ' ', s.stud_lname) as 'Student name',
	avg(g.grade) as 'average grade',
    case 
		when avg(g.grade) < 5 then 'weak'
        when avg(g.grade) >= 5 and avg(g.grade) < 8 then 'average'
        when avg(g.grade) >= 8 then 'good'
        end as 'grade'
from student s join grade g on s.stud_id = G.stud_id
group by s.stud_id;
         
#6
select concat(c.class_id, ' ', c.class_name) as 'Student name',
	avg(g.grade) as 'average grade',
    case 
		when avg(g.grade) < 5 then 'weak'
        when avg(g.grade) >= 5 and avg(g.grade) < 8 then 'average'
        when avg(g.grade) >= 8 then 'good'
        end as 'grade'
from class c join grade g on c.class_id = G.class_id
group by c.class_id;

#7
select co.course_name as 'Course name',
	avg(g.grade) as 'Average grade',
    case 
		when avg(g.grade) < 5 then 'weak'
        when avg(g.grade) >= 5 and avg(g.grade) < 8 then 'average'
        when avg(g.grade) >= 8 then 'good'
        end as 'grade'
from grade g join class c on c.class_id = G.class_id
join course co on co.course_id = c.course_id group by c.course_id;