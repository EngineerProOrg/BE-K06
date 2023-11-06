use day1;
create table course (
	course_id int,
    course_name varchar(255),
    primary key (course_id)
);

create table professor (
	prof_id int,
    prof_lName varchar(50),
    prof_fName varchar(50),
    primary key (prof_id)
);

create table student (
	stud_id int,
    stud_fName varchar(50),
    stud_lName varchar(50),
    stud_street varchar(255),
    stud_city varchar(50),
    stud_zip varchar(10),
    primary key (stud_id)
);

create table class (
	class_id int,
    class_name varchar(255),
    prof_id int,
    course_id int,
    room_id int,
    primary key (class_id),
    foreign key (prof_id) REFERENCES professor(prof_id),
    foreign key (course_id) REFERENCES course(course_id)
);

create table enroll (
	stud_id int,
    class_id int,
    primary key (stud_id, class_id),
    foreign key (stud_id) REFERENCES student(stud_id),
    foreign key (class_id) REFERENCES class(class_id)
);

create table room (
	room_id int,
    room_looc varchar(50),
    room_cap varchar(50),
    class_id int,
    primary key (room_id),
    foreign key (class_id) references class(class_id)
);

alter table class add foreign key (room_id) references room(room_id);
    