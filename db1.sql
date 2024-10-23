-- Tạo bảng departments
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT true
);

-- Tạo bảng employees
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(12,2) NOT NULL,
    department_id INTEGER,
    active BOOLEAN DEFAULT true,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Thêm dữ liệu vào bảng departments
INSERT INTO departments (name) VALUES
    ('Phòng Kỹ thuật'),
    ('Phòng Nhân sự'),
    ('Phòng Kế toán'),
    ('Phòng Marketing'),
    ('Phòng Kinh doanh');

-- Thêm dữ liệu vào bảng employees
INSERT INTO employees (name, salary, department_id) VALUES
    ('Nguyễn Văn A', 15000000, 1),
    ('Trần Thị B', 12000000, 2),
    ('Lê Văn C', 9000000, 3),
    ('Phạm Thị D', 11000000, 4),
    ('Hoàng Văn E', 13000000, 5),
    ('Đỗ Thị F', 8500000, 1),
    ('Bùi Văn G', 10500000, 2),
    ('Ngô Thị H', 9500000, 3),
    ('Vũ Văn I', 14000000, 4),
    ('Đặng Thị K', 12500000, 5);

-- 1. Lấy danh sách nhân viên và phòng ban của họ
SELECT 
    e.id, 
    e.name as employee_name, 
    e.salary, 
    d.name as department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
WHERE e.active = true AND d.active = true;

-- 2. Tìm nhân viên có lương lớn hơn 10 triệu
SELECT 
    id, 
    name, 
    salary::money, 
    department_id
FROM employees
WHERE salary > 10000000 AND active = true;

-- 3. Đếm số nhân viên trong mỗi phòng ban
SELECT 
    d.name as department_name, 
    COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
    AND e.active = true
WHERE d.active = true
GROUP BY d.id, d.name;

-- 4. Cập nhật lương của một nhân viên cụ thể
UPDATE employees
SET salary = 16000000
WHERE id = 1
RETURNING id, name, salary::money;

-- 5. Xóa một phòng ban (cập nhật active thành false)

-- Đánh dấu phòng ban là không active
UPDATE departments
SET active = false
WHERE id = 1
RETURNING id, name;

-- Đánh dấu các nhân viên thuộc phòng ban đó là không active
UPDATE employees
SET active = false
WHERE department_id = 1
RETURNING id, name;
