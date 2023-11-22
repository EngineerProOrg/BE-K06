USE college;


/* 1 những cặp student-professor có dạy học nhau và số lớp mà họ có liên quan */
SELECT 
    CONCAT(professor.prof_fname, ' ', professor.prof_lname) as prof_name, 
    CONCAT(student.stud_fname, ' ', student.stud_lname) as student_name , 
    COUNT(*) as total_class  FROM student
INNER JOIN enroll ON student.stud_id = enroll.stud_id
INNER JOIN class ON enroll.class_id = class.class_id
INNER JOIN professor ON professor.prof_id = class.prof_id
GROUP BY prof_name, student_name;

/*2. những course (distinct) mà 1 professor cụ thể đang dạy*/

SELECT DISTINCT course.course_id, course.course_name FROM class
INNER JOIN professor ON class.prof_id = professor.prof_id
INNER JOIN course ON class.course_id = course.course_id
WHERE professor.prof_id=1;


/*3. những course (distinct) mà 1 student cụ thể đang học*/
SELECT DISTINCT course.course_id, course.course_name FROM class
INNER JOIN enroll ON class.class_id = enroll.class_id
INNER JOIN course ON class.course_id = course.course_id
WHERE enroll.stud_id=1;

/*4. điểm số là A, B, C, D, E, F tương đương với 10, 8, 6, 4, 2, 0*/
SELECT CONCAT(stud_fname, ' ', stud_lname) as student_name, 
	CONCAT(prof_fname, ' ', prof_lname) as prof_name, 
	course_name, grade, 
	CASE 
		WHEN grade = 'A' THEN 10
		WHEN grade = 'B' THEN 8
		WHEN grade = 'C' THEN 6
		WHEN grade = 'D' THEN 4
		WHEN grade = 'E' THEN 2
		WHEN grade = 'F' THEN 0
	END as grade_point
FROM student, professor, class, enroll, course
WHERE student.stud_id = enroll.stud_id;

/*5. điểm số trung bình của 1 học sinh cụ thể 
(quy ra lại theo chữ cái, và xếp loại học lực (weak nếu avg < 5, average nếu >=5 < 8, good nếu >=8 )*/

SELECT
    CONCAT(s.stud_fname, ' ', s.stud_lname) AS student_name,
    CONCAT(p.prof_fname, ' ', p.prof_lname) AS prof_name,
    c.course_name,
    e.grade,
    case WHEN avg_grade < 5 THEN 'weak'
		WHEN avg_grade >= 5 AND avg_grade < 8 THEN 'average'
		WHEN avg_grade >= 8 THEN 'good'
	END AS grade_point
FROM
	student s
INNER JOIN enroll e ON s.stud_id = e.stud_id
INNER JOIN class cl ON e.class_id = cl.class_id
INNER JOIN professor p ON cl.prof_id = p.prof_id
INNER JOIN course c ON cl.course_id = c.course_id
INNER JOIN (
	SELECT
		e.stud_id,
		AVG(
			CASE
				WHEN e.grade = 'A' THEN 10
				WHEN e.grade = 'B' THEN 8
				WHEN e.grade = 'C' THEN 6
				WHEN e.grade = 'D' THEN 4
				WHEN e.grade = 'E' THEN 2
				WHEN e.grade = 'F' THEN 0
			END
		) AS avg_grade
	FROM
		enroll e
	GROUP BY
		e.stud_id
) AS avg_grade ON s.stud_id = avg_grade.stud_id;


/*6. điểm số trung bình của các class (quy ra lại theo chữ cái)*/
SELECT
	CONCAT(p.prof_fname, ' ', p.prof_lname) AS prof_name,
	c.course_name,
	CASE
		WHEN avg_grade > 8 THEN 'A'
		WHEN avg_grade > 6 AND avg_grade <= 8 THEN 'B'
		WHEN avg_grade > 4 AND avg_grade <= 6 THEN 'C'
		WHEN avg_grade > 2 AND avg_grade <= 4 THEN 'D'
		WHEN avg_grade > 0 AND avg_grade <= 2 THEN 'E'
		WHEN avg_grade = 0 THEN 'F'
	END AS grade_point
FROM
	professor p
INNER JOIN class cl ON p.prof_id = cl.prof_id
INNER JOIN course c ON cl.course_id = c.course_id
INNER JOIN (
	SELECT
		cl.class_id,
		AVG(
			CASE
				WHEN e.grade = 'A' THEN 10
				WHEN e.grade = 'B' THEN 8
				WHEN e.grade = 'C' THEN 6
				WHEN e.grade = 'D' THEN 4
				WHEN e.grade = 'E' THEN 2
				WHEN e.grade = 'F' THEN 0
			END
		) AS avg_grade
	FROM
		class cl
	INNER JOIN enroll e ON cl.class_id = e.class_id
	GROUP BY
		cl.class_id
) AS avg_grade ON cl.class_id = avg_grade.class_id;


/*7. điểm số trung bình của các course (quy ra lại theo chữ cái)*/
SELECT
	c.course_name,
	CASE
		WHEN avg_grade > 8 THEN 'A'
		WHEN avg_grade > 6 AND avg_grade <= 8 THEN 'B'
		WHEN avg_grade > 4 AND avg_grade <= 6 THEN 'C'
		WHEN avg_grade > 2 AND avg_grade <= 4 THEN 'D'
		WHEN avg_grade > 0 AND avg_grade <= 2 THEN 'E'
		WHEN avg_grade = 0 THEN 'F'
	END AS grade_point	
FROM
	course c
INNER JOIN class cl ON c.course_id = cl.course_id
INNER JOIN (
	SELECT
		cl.course_id,
		AVG(
			CASE
				WHEN e.grade = 'A' THEN 10
				WHEN e.grade = 'B' THEN 8
				WHEN e.grade = 'C' THEN 6
				WHEN e.grade = 'D' THEN 4
				WHEN e.grade = 'E' THEN 2
				WHEN e.grade = 'F' THEN 0
			END
		) AS avg_grade
	FROM
		class cl
	INNER JOIN enroll e ON cl.class_id = e.class_id
	GROUP BY
		cl.course_id
) AS avg_grade ON c.course_id = avg_grade.course_id;

