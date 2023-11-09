#create professor
create table testdb.professor (
	prof_id int primary key,
    prof_lname varchar(50),
    prof_fname varchar(50)
);

# create course
create table testdb.course(
	course_id int primary key,
    course_name varchar(255)
);

# create room
create table testdb.room (
	room_id int primary key,
    room_loc varchar(50),
    room_cap varchar(50),
    class_id int
);

# create class 
create table testdb.class (
	class_id int primary key,
    class_name varchar(255),
    prof_id int,
    course_id int,
    room_id int,
    foreign key (prof_id) references professor(prof_id),
    foreign key (course_id) references course(course_id)
);

# add foreign key for room table
alter table testdb.room add foreign key (class_id) references class(class_id)

# create student
create table testdb.student (
	stud_id int primary key,
    stud_fname varchar(50),
    stud_lname varchar(50),
    stud_street varchar(255),
    stud_city varchar(50),
    stud_zip varchar(10)
 )
 
 # create enroll
create table testdb.enroll (
	stud_id int,
    class_id int,
    grade varchar(3),
    primary key (stud_id, class_id),
    foreign key (stud_id) references student(stud_id),
    foreign key (class_id) references class(class_id)
 )
 
# những cặp student-professor có dạy học nhau và số lớp mà họ có liên quan
 select stud_id, prof_id, count(class_id) num_class from (
 select a.stud_id, b.prof_id, c.class_id from testdb.student a, testdb.professor b, testdb.class c, testdb.enroll d
 where b.prof_id = c.prof_id and a.stud_id = d.stud_id and c.class_id = d.class_id) a group by stud_id, prof_id;
 
# những course (distinct) mà 1 professor cụ thể đang dạy
 select distinct prof_id, course_id from testdb.class;
 
# những course (distinct) mà 1 student cụ thể đang học
select distinct b.stud_id, a.course_id from tesdb.class a, testdb.enroll b where a.stud_id = b.stud_id;

# điểm số trung bình của 1 học sinh cụ thể (quy ra lại theo chữ cái, và xếp loại học lực (weak nếu avg < 5, average nếu >=5 < 8, good nếu >=8 )
select stud_id, case
  when grade >= 0 and grade <= 2 then 'F'
     when grade > 2 and grade <= 4 then 'D'
     when grade > 4 and grade <= 6 then 'C'
     when grade > 6 and grade <= 8 then 'B'
     else 'A'
 end grade_letter, case
  when grade < 5 then 'weak'
     when grade >=5 and grade < 8 then 'average'
     else 'good' 
 end level from (
 select stud_id, avg(grade) grade from testdb.enroll group by stud_id) a;
 
# điểm số trung bình của các class (quy ra lại theo chữ cái)
select class_id, case
  when grade >= 0 and grade <= 2 then 'F'
     when grade > 2 and grade <= 4 then 'D'
     when grade > 4 and grade <= 6 then 'C'
     when grade > 6 and grade <= 8 then 'B'
     else 'A'
 end grade_letter from (
 select class_id, avg(grade) grade from testdb.enroll group by class_id) a;
 
# điểm số trung bình của các course (quy ra lại theo chữ cái)
select course_id, case
  when grade >= 0 and grade <= 2 then 'F'
     when grade > 2 and grade <= 4 then 'D'
     when grade > 4 and grade <= 6 then 'C'
     when grade > 6 and grade <= 8 then 'B'
     else 'A'
 end grade_letter from (
 select a.course_id, avg(b.grade) grade from testdb.class a, testdb.enroll b where a.class_id = b.class_id group by a.course_id) c