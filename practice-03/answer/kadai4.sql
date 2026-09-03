SELECT
    e.employee_name AS employee_name,

    -- マネージャーが存在しない場合はN/A
    COALESCE(m.employee_name, 'N/A') AS manager_name
FROM employees e
-- employees自信をマネージャーとして結合
LEFT JOIN employees m
    ON e.manager_id = m.employee_id
ORDER BY e.employee_id;