-- Create tables
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT true
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT true
);

CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER REFERENCES subjects(id),
    name VARCHAR(200) NOT NULL,
    duration INTEGER, -- minutes
    total_score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT true
);

CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    exam_id INTEGER REFERENCES exams(id),
    question TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    score DECIMAL(5,2) DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT true
);

CREATE TABLE exam_results (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    exam_id INTEGER REFERENCES exams(id),
    question_id INTEGER REFERENCES questions(id),
    student_answer TEXT,
    is_correct BOOLEAN,
    score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO subjects (name, description) VALUES
('Mathematics', 'Basic math course'),
('Physics', 'Introduction to physics'),
('Chemistry', 'Basic chemistry course');

INSERT INTO students (name, email, phone) VALUES 
('John Doe', 'john@email.com', '1234567890'),
('Jane Smith', 'jane@email.com', '0987654321'),
('Bob Wilson', 'bob@email.com', '1122334455');

INSERT INTO exams (subject_id, name, duration, total_score) VALUES
(1, 'Math Midterm', 60, 100),
(1, 'Math Final', 120, 100),
(2, 'Physics Quiz 1', 30, 50);

INSERT INTO questions (exam_id, question, correct_answer, score) VALUES
(1, 'What is 2+2?', '4', 10),
(1, 'What is 5x5?', '25', 10),
(2, 'Solve: x + 5 = 10', '5', 20),
(3, 'What is Newton''s first law?', 'An object remains at rest or in motion unless acted upon by a force', 15);

INSERT INTO exam_results (student_id, exam_id, question_id, student_answer, is_correct, score) VALUES
(1, 1, 1, '4', true, 10),
(1, 1, 2, '25', true, 10),
(2, 1, 1, '5', false, 0),
(2, 2, 3, '5', true, 20);

-- Query 1: Get exam list by subject_id
CREATE OR REPLACE VIEW exam_list AS
SELECT e.*, s.name as subject_name
FROM exams e
JOIN subjects s ON e.subject_id = s.id
WHERE e.subject_id = :subject_id;

-- Query 2: Get exam list with questions by subject_id
CREATE OR REPLACE VIEW exam_with_questions AS
SELECT 
    e.id as exam_id,
    e.name as exam_name,
    e.duration,
    e.total_score,
    json_agg(
        json_build_object(
            'question_id', q.id,
            'question', q.question,
            'score', q.score
        )
    ) as questions
FROM exams e
LEFT JOIN questions q ON e.id = q.exam_id
WHERE e.subject_id = :subject_id
GROUP BY e.id;

-- Query 3: Get exam results by subject_id
CREATE OR REPLACE VIEW exam_results_by_subject AS
SELECT 
    s.id as student_id,
    s.name as student_name,
    json_agg(
        json_build_object(
            'exam_id', e.id,
            'exam_name', e.name,
            'questions', (
                SELECT json_agg(
                    json_build_object(
                        'question_id', q.id,
                        'question', q.question,
                        'correct_answer', q.correct_answer,
                        'student_answer', er.student_answer,
                        'is_correct', er.is_correct,
                        'score', er.score
                    )
                )
                FROM questions q
                LEFT JOIN exam_results er ON er.question_id = q.id 
                    AND er.student_id = s.id
                WHERE q.exam_id = e.id
            )
        )
    ) as exams
FROM students s
JOIN exam_results er ON er.student_id = s.id
JOIN questions q ON er.question_id = q.id
JOIN exams e ON q.exam_id = e.id
WHERE e.subject_id = :subject_id
GROUP BY s.id;

-- Example usage:
-- SELECT * FROM exam_list WHERE subject_id = 1;
-- SELECT * FROM exam_with_questions WHERE subject_id = 1;
-- SELECT * FROM exam_results_by_subject WHERE subject_id = 1;
