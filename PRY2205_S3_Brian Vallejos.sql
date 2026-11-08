-- =====================================================
-- CASO 1: Análisis de Propiedades
-- =====================================================
SELECT ID_TIPO_PROPIEDAD AS "TIPO",
       COUNT(*)          AS "TOTAL_PROPIEDADES",
       NVL(TO_CHAR(MAX(VALOR_ARRIENDO), '$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.'''), 'Sin datos') AS "MAX_ARRIENDO",
       NVL(TO_CHAR(ROUND(AVG(VALOR_ARRIENDO)), '$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.'''), 'Sin datos') AS "PROMEDIO_ARRIENDO",
       NVL(TO_CHAR(MIN(VALOR_ARRIENDO), '$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.'''), 'Sin datos') AS "MIN_ARRIENDO",
       CASE
           WHEN MAX(VALOR_ARRIENDO) IS NULL OR MIN(VALOR_ARRIENDO) < 0 THEN 'INVALIDO'
           WHEN MAX(VALOR_ARRIENDO) <= 1000000 THEN 'ESTÁNDAR'
           ELSE 'PREMIUM'
       END AS "CLASIFICACION",
       TO_CHAR(NVL(SUM(VALOR_GASTO_COMUN), 0), '$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS "TOTAL_GASTOS_COMUNES"
FROM PROPIEDAD
GROUP BY ID_TIPO_PROPIEDAD
HAVING SUM(VALOR_GASTO_COMUN) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(VALOR_GASTO_COMUN) DESC NULLS LAST;


------------------------------------------------
-- CASO 2: Análisis de antigüedad de empleados
------------------------------------------------
SELECT UPPER(NOMBRE_EMP ||' '|| APPATERNO_EMP) as "Nombre Empleado",
TO_CHAR(SUELDO_EMP, '$999G999G999','NLS_NUMERIC_CHARACTERS='',.''') as "Sueldo con Formato",
CASE 
    WHEN SUELDO_EMP IS NULL OR SUELDO_EMP < 0 THEN 'INVALIDO'
    WHEN SUELDO_EMP <= 2000000 THEN 'MEDIO'
    ELSE 'ALTO'
END as "Clasificación Sueldo",
TRUNC(MONTHS_BETWEEN(SYSDATE, FECING_EMP)/12) as "Años Antigüedad",
CASE
    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, FECING_EMP)/12)<=10 THEN 'Corresponde bono  5%: '|| TO_CHAR(ROUND(SUELDO_EMP*0.05), '$999G999G999','NLS_NUMERIC_CHARACTERS='',.''')
    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, FECING_EMP)/12)<=20 THEN 'Corresponde bono 10%: '|| TO_CHAR(ROUND(SUELDO_EMP*0.10), '$999G999G999','NLS_NUMERIC_CHARACTERS='',.''')
    ELSE 'Corresponde bono 15%: '|| TO_CHAR(ROUND(SUELDO_EMP*0.15), '$999G999G999','NLS_NUMERIC_CHARACTERS='',.''')
END as "BONO"
FROM EMPLEADO e
JOIN CATEGORIA_EMPLEADO ce ON e.id_categoria_emp = ce.id_categoria_emp
JOIN SUCURSAL s ON s.id_sucursal = e.id_sucursal
WHERE ce.id_categoria_emp = 3 AND s.id_sucursal != &CODIGO_SUCURSAL AND TRUNC(MONTHS_BETWEEN(SYSDATE, FECING_EMP)/12)>5
ORDER BY SUELDO_EMP DESC;


----------------------------------------------------
-- CASO 3: Lista de clientes
----------------------------------------------------
SELECT CASE
           WHEN RENTA_CLI IS NULL OR RENTA_CLI < 0 THEN 'INVALIDO'
           WHEN RENTA_CLI < 300000  THEN 'BAJA'
           WHEN RENTA_CLI < 600000  THEN 'MEDIA'
           WHEN RENTA_CLI < 1000000 THEN 'ALTA'
           ELSE 'PREMIUM'
       END AS "CLASIFICACION_RENTA",
COUNT(*) AS "CANTIDAD_CLIENTES",
NVL(TO_CHAR(ROUND(AVG(RENTA_CLI)), '$999G999G999',
       'NLS_NUMERIC_CHARACTERS='',.'''), 'Sin datos') AS "RENTA_PROMEDIO",
       CASE
           WHEN COUNT(FONOFIJO_CLI) <1 THEN 'Clientes Sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END AS "ESTADO_TELEFONO"
FROM CLIENTE
GROUP BY CASE
           WHEN RENTA_CLI IS NULL OR RENTA_CLI < 0 THEN 'INVALIDO'
           WHEN RENTA_CLI < 300000  THEN 'BAJA'
           WHEN RENTA_CLI < 600000  THEN 'MEDIA'
           WHEN RENTA_CLI < 1000000 THEN 'ALTA'
           ELSE 'PREMIUM'
       END
HAVING AVG(RENTA_CLI) > 200000;