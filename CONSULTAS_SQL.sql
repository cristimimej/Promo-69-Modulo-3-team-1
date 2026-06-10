

USE abc_corporation;

-- 1. ¿Cuántos empleados se fueron y cuántos se quedaron?
SELECT 
    CASE WHEN Attrition = 1 THEN 'Se fue' ELSE 'Se quedo' END AS Estado,
    COUNT(*) AS Total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM empleados), 2) AS Porcentaje
FROM empleados
GROUP BY Attrition;


-- 2. ¿Cuántos empleados hay por departamento?
SELECT 
    p.Department,
    COUNT(*) AS Total_empleados
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY p.Department
ORDER BY Total_empleados DESC;


-- 3. ¿Cuál es el salario medio por departamento?
SELECT 
    p.Department,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM compensacion c
JOIN puestos p ON c.EmployeeNumber = p.EmployeeNumber
GROUP BY p.Department
ORDER BY Salario_medio DESC;


-- 4. ¿Cuántos empleados hacen overtime?
SELECT 
    CASE WHEN OverTime = 1 THEN 'Con overtime' ELSE 'Sin overtime' END AS Overtime,
    COUNT(*) AS Total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM puestos), 2) AS Porcentaje
FROM puestos
GROUP BY OverTime;


-- 5. Tasa de abandono por departamento (%)
SELECT 
    p.Department,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY p.Department
ORDER BY Tasa_abandono DESC;


-- 6. Salario medio: se fueron vs se quedaron
SELECT 
    CASE WHEN e.Attrition = 1 THEN 'Se fue' ELSE 'Se quedo' END AS Estado,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(MIN(c.MonthlyIncome), 2) AS Salario_minimo,
    ROUND(MAX(c.MonthlyIncome), 2) AS Salario_maximo
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY e.Attrition;

-- 7. Top 5 roles con mayor tasa de abandono
SELECT 
    p.JobRole,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY p.JobRole
ORDER BY Tasa_abandono DESC
LIMIT 5;


-- 8. Impacto del overtime en el abandono
SELECT 
    CASE WHEN p.OverTime = 1 THEN 'Con overtime' ELSE 'Sin overtime' END AS Overtime,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY p.OverTime
ORDER BY Tasa_abandono DESC;


-- 9. Satisfaccion laboral vs abandono
SELECT 
    s.JobSatisfaction,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
GROUP BY s.JobSatisfaction
ORDER BY s.JobSatisfaction ASC;


-- 10. Coste mensual estimado de la fuga por departamento
SELECT 
    p.Department,
    SUM(e.Attrition) AS Empleados_perdidos,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(SUM(e.Attrition) * AVG(c.MonthlyIncome), 2) AS Coste_mensual_estimado
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY p.Department
ORDER BY Coste_mensual_estimado DESC;


-- 11. Perfil completo del empleado en riesgo
SELECT 
    e.EmployeeNumber,
    p.Department,
    p.JobRole,
    c.MonthlyIncome,
    s.JobSatisfaction,
    p.YearsAtCompany
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
WHERE e.Attrition = 0
  AND p.JobLevel = 1
  AND p.OverTime = 1
  AND c.MonthlyIncome < 3000
  AND s.JobSatisfaction = 1
ORDER BY c.MonthlyIncome ASC
LIMIT 10;


-- 12. Ranking completo con todos los indicadores
SELECT 
    p.Department,
    COUNT(*) AS Total_empleados,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(AVG(s.JobSatisfaction), 2) AS Satisfaccion_media,
    SUM(CASE WHEN p.OverTime = 1 THEN 1 ELSE 0 END) AS Con_overtime,
    ROUND(SUM(e.Attrition) * AVG(c.MonthlyIncome), 2) AS Coste_fuga_mensual
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
GROUP BY p.Department
ORDER BY Tasa_abandono DESC;


-- 13. Empleados veteranos (+10 años) que se fueron
-- ¿Estamos perdiendo talento senior?
SELECT 
    p.JobRole,
    p.Department,
    ROUND(AVG(p.YearsAtCompany), 1) AS Anos_medios,
    COUNT(*) AS Total_bajas,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
WHERE e.Attrition = 1
  AND p.YearsAtCompany > 10
GROUP BY p.JobRole, p.Department
ORDER BY Total_bajas DESC;


-- 14. ¿En qué año de antigüedad se van más empleados?
SELECT 
    p.YearsAtCompany,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY p.YearsAtCompany
ORDER BY Tasa_abandono DESC
LIMIT 10;


-- 15. Comparativa hombres vs mujeres
SELECT 
    e.Gender,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY e.Gender
ORDER BY Tasa_abandono DESC;



-- 16. Ranking de roles por coste de fuga
SELECT 
    p.JobRole,
    COUNT(*) AS Total_empleados,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(SUM(e.Attrition) * AVG(c.MonthlyIncome), 2) AS Coste_fuga_mensual
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY p.JobRole
ORDER BY Coste_fuga_mensual DESC;

-- 17. ¿Los empleados con más formación se van menos?
SELECT 
    e.Education,
    CASE e.Education
        WHEN 1 THEN 'Sin titulo'
        WHEN 2 THEN 'Bachillerato'
        WHEN 3 THEN 'Grado'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctorado'
    END AS Nivel_educativo,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
GROUP BY e.Education
ORDER BY e.Education ASC;



-- 18. Top 10 empleados con más años sin promoción
SELECT 
    e.EmployeeNumber,
    p.Department,
    p.JobRole,
    p.YearsSinceLastPromotion,
    p.YearsAtCompany,
    c.MonthlyIncome,
    s.JobSatisfaction
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
WHERE e.Attrition = 0
ORDER BY p.YearsSinceLastPromotion DESC
LIMIT 10;


-- 19. Doble riesgo — overtime Y baja satisfacción
SELECT 
    p.Department,
    p.JobRole,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
WHERE p.OverTime = 1
  AND s.JobSatisfaction = 1
GROUP BY p.Department, p.JobRole
ORDER BY Tasa_abandono DESC;


-- 20. Resumen ejecutivo completo para ABC Corporation
SELECT 
    'Total empleados'          AS Indicador,
    COUNT(*)                   AS Valor
FROM empleados
UNION ALL
SELECT 'Empleados que se fueron', SUM(Attrition) FROM empleados
UNION ALL
SELECT 'Tasa abandono (%)', ROUND(AVG(Attrition) * 100, 2) FROM empleados
UNION ALL
SELECT 'Salario medio global ($)', ROUND(AVG(MonthlyIncome), 2) 
FROM compensacion
UNION ALL
SELECT 'Empleados con overtime', SUM(OverTime) FROM puestos
UNION ALL
SELECT 'Coste fuga mensual estimado ($)', 
    ROUND(SUM(e.Attrition) * AVG(c.MonthlyIncome), 2)
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber;


SELECT 
    CASE WHEN p.JobLevel = 1 THEN 'Junior' ELSE 'Senior' END AS Nivel,
    CASE WHEN p.OverTime = 1 THEN 'Con OT' ELSE 'Sin OT' END AS Overtime,
    CASE WHEN s.JobSatisfaction <= 2 THEN 'Baja satisf' ELSE 'Alta satisf' END AS Satisfaccion,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
GROUP BY Nivel, Overtime, Satisfaccion
ORDER BY Tasa_abandono DESC;

-- B. ¿Los empleados solteros se van más?
SELECT 
    e.MaritalStatus,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY e.MaritalStatus
ORDER BY Tasa_abandono DESC;


-- C. ¿Cuánto tiempo aguanta un empleado insatisfecho?
SELECT 
    s.JobSatisfaction,
    ROUND(AVG(p.YearsAtCompany), 2) AS Anos_medios_antes_irse,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    COUNT(*) AS Total
FROM empleados e
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
WHERE e.Attrition = 1
GROUP BY s.JobSatisfaction
ORDER BY s.JobSatisfaction ASC;


-- D. ¿Los que viajan mucho se van más?
SELECT 
    p.BusinessTravel,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY p.BusinessTravel
ORDER BY Tasa_abandono DESC;


-- E. ¿Los empleados con más formación cobran más?
SELECT 
    e.Education,
    CASE e.Education
        WHEN 1 THEN 'Sin título'
        WHEN 2 THEN 'Bachillerato'
        WHEN 3 THEN 'Grado'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctorado'
    END AS Nivel_educativo,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(AVG(p.JobLevel), 2) AS Nivel_puesto_medio,
    COUNT(*) AS Total
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
GROUP BY e.Education
ORDER BY e.Education ASC;


-- F. ¿Cuánto sube el sueldo por año de experiencia?
SELECT 
    p.TotalWorkingYears,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    COUNT(*) AS Total_empleados,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY p.TotalWorkingYears
ORDER BY p.TotalWorkingYears ASC
LIMIT 15;



-- G. ¿Los que tienen stock options se quedan más?
SELECT 
    c.StockOptionLevel,
    COUNT(*) AS Total,
    SUM(e.Attrition) AS Se_fueron,
    ROUND(SUM(e.Attrition) * 100.0 / COUNT(*), 2) AS Tasa_abandono,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio
FROM empleados e
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY c.StockOptionLevel
ORDER BY c.StockOptionLevel ASC;


-- H. Perfil completo del empleado ideal que nunca se va
SELECT 
    p.JobRole,
    p.Department,
    ROUND(AVG(e.Age), 1) AS Edad_media,
    ROUND(AVG(c.MonthlyIncome), 2) AS Salario_medio,
    ROUND(AVG(s.JobSatisfaction), 2) AS Satisfaccion_media,
    ROUND(AVG(p.YearsAtCompany), 1) AS Anos_medios,
    ROUND(AVG(p.JobLevel), 1) AS Nivel_medio,
    COUNT(*) AS Total
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
WHERE e.Attrition = 0
  AND s.JobSatisfaction = 4
  AND p.OverTime = 0
GROUP BY p.JobRole, p.Department
ORDER BY Total DESC
LIMIT 10;