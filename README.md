# 🏢 Análisis de Datos para Retener y Potenciar Empleados en ABC Corporation

<div align="center">

![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?style=for-the-badge&logo=mysql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.0-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Sklearn](https://img.shields.io/badge/Scikit--Learn-1.3-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Team--1-181717?style=for-the-badge&logo=github&logoColor=white)

**Proyecto 3 · Promo 69 · Módulo 3 · Adalab**

*Análisis completo de retención de talento para una consultora tecnológica de IA*

</div>

---

## 👥 Equipo

| Nombre | GitHub |
|--------|--------|
| Sabrina Gómez | [@Sabri667](https://github.com/Sabri667) |
| Jezabel Sánchez | [@Jezi](https://github.com/Jezi) |
| Cristina Millán | [@cristimimej](https://github.com/cristimimej) |
| Jessica Hernández | [@firenzejess](https://github.com/firenzejess) |

---

## 📋 Descripción del proyecto

ABC Corporation, consultora tecnológica fundada en 1980 en California especializada en **Inteligencia Artificial y Machine Learning**, nos contrató para entender y resolver el reto de la fuga de talento que estaban experimentando.

A partir de un dataset de **1.470 empleados** con 35 variables, desarrollamos un análisis completo que incluye exploración de datos, limpieza, visualizaciones, base de datos relacional y un modelo predictivo.

> *"Los datos tienen una historia que contar — nuestro trabajo fue escucharla."*

---

## 🚨 El reto

| Indicador | Valor |
|-----------|-------|
| Total empleados analizados | **1.470** |
| Empleados que abandonaron | **237** |
| Tasa de abandono | **16.12%** |
| Salario medio global | **$6.483/mes** |
| Empleados con overtime | **405 (27.6%)** |
| **Coste mensual estimado de la fuga** | **$1.536.595** |

---

## 🗂️ Estructura del repositorio

```
project-da-promo-69-modulo-3-team-1/
│
├── 📓 Fase1_EDA.ipynb                    # Exploración y diagnóstico del dataset
├── 📓 Fase2_Limpieza_ParejaA.ipynb       # Transformación — Pareja A
├── 📓 Fase2_Limpieza_ParejaB.ipynb       # Transformación — Pareja B
├── 📓 Fase3_Visualizacion_Unificada.ipynb # Visualizaciones + Random Forest
├── 📓 Fase4_BBDD.ipynb                   # Base de datos MySQL
├── 🐍 transform_ETLpy.py                 # ETL automatizado (Fase 5)
│
├── 📁 data/
│   ├── hr.csv                            # Dataset original
│   └── hr_clean.csv                      # Dataset limpio
│
├── 📁 graficos/
│   ├── g1_attrition_departamento.png
│   ├── g2_attrition_satisfaccion.png
│   ├── g3_salario_rol.png
│   ├── g4_attrition_genero.png
│   ├── g5_attrition_jobrole.png
│   └── g6_heatmap_correlaciones.png
│
└── 📖 README.md
```

---

## 🔄 Fases del proyecto

### Fase 1 — Análisis Exploratorio (EDA)

Exploración completa del dataset antes de tocar nada.

**Pareja A — Estructura y calidad:**
- 1.474 filas × 35 columnas
- 11 columnas con valores nulos
- 4 filas duplicadas
- 3 columnas sin varianza (`EmployeeCount`, `Over18`, `StandardHours`)
- 4 columnas con tipo incorrecto (`float64` → `int64`)

**Pareja B — Contenido y variable objetivo:**
- Attrition: **16.15%** abandonaron (238 empleados)
- `JobRole` con texto corrupto (`' sALES eXECUTIVE '`)
- `MaritalStatus` con typo (`'Marreid'`)
- 3 columnas constantes identificadas para eliminar

---

### Fase 2 — Limpieza y Transformación

Funciones Python reutilizables para transformar los datos.

**Pareja A:**
```python
def fix_job_role(df)    # Normaliza texto de JobRole
def fix_types(df)       # Convierte float64 → int64
def fix_nulls(df)       # Rellena nulos (mediana/moda)
```

**Pareja B:**
```python
def drop_useless_cols(df)   # Elimina columnas sin varianza
def encode_binary(df)       # Yes/No → 1/0
def validate(df_orig, df)   # Valida el resultado final
```

**Pipeline completo:**
```python
df_clean = df.copy()
df_clean = fix_job_role(df_clean)
df_clean = fix_types(df_clean)
df_clean = fix_nulls(df_clean)
df_clean = drop_useless_cols(df_clean)
df_clean = encode_binary(df_clean)
validate(df, df_clean)
# Resultado: 1.470 filas × 32 columnas, 0 nulos
```

---

### Fase 3 — Visualizaciones

13 gráficos organizados por preguntas de negocio reales.

| Pregunta | Hallazgo clave |
|----------|----------------|
| ¿Por qué se van? | Sales 20.3% · HR 19.0% · R&D 14.0% |
| ¿Influye el rol? | Sales Representative **39.76%** 🚨 |
| ¿Influye el salario? | Los que se van cobran un **30% menos** |
| ¿Influye el género? | Diferencia mínima (2.2 puntos) |
| ¿Qué hace cómodo al empleado? | Overtime **triplica** el riesgo |

**Bonus — Modelo predictivo Random Forest:**
Variables más importantes: `MonthlyIncome`, `Age`, `TotalWorkingYears`, `YearsAtCompany`, `OverTime`

---

### Fase 4 — Base de Datos MySQL

Base de datos `abc_corporation` con **4 tablas relacionadas** y **1.470 registros**.

```sql
empleados     → datos personales (PK: EmployeeNumber)
puestos       → información laboral (FK → empleados)
satisfaccion  → métricas de bienestar (FK → empleados)
compensacion  → salario y beneficios (FK → empleados)
```

**Consultas más impactantes:**

```sql
-- Coste mensual de la fuga por departamento
SELECT Department,
       SUM(Attrition) AS empleados_perdidos,
       ROUND(SUM(Attrition) * AVG(MonthlyIncome), 2) AS coste_mensual
FROM empleados e JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
GROUP BY Department ORDER BY coste_mensual DESC;
-- R&D: $852.519 · Sales: $618.087 · HR: $78.871
```

```sql
-- Empleados actuales en riesgo de fuga
SELECT e.EmployeeNumber, p.JobRole, c.MonthlyIncome
FROM empleados e
JOIN puestos p ON e.EmployeeNumber = p.EmployeeNumber
JOIN compensacion c ON e.EmployeeNumber = c.EmployeeNumber
JOIN satisfaccion s ON e.EmployeeNumber = s.EmployeeNumber
WHERE e.Attrition = 0 AND p.JobLevel = 1
  AND p.OverTime = 1 AND c.MonthlyIncome < 3000
  AND s.JobSatisfaction = 1
ORDER BY c.MonthlyIncome ASC LIMIT 10;
```

---

### Fase 5 — ETL Automatizado (Bonus)

Pipeline completo en `transform_ETLpy.py` que automatiza todo el proceso:

```bash
python transform_ETLpy.py
```

```
[EXTRACCION]    CSV cargado: 1474 filas × 35 columnas
[TRANSFORMACION] JobRole limpio
[TRANSFORMACION] Tipos de datos corregidos
[TRANSFORMACION] Nulos tratados
[TRANSFORMACION] Columnas eliminadas
[TRANSFORMACION] Columnas binarias codificadas
[TRANSFORMACION] Duplicados eliminados: 4 filas
[TRANSFORMACION] Dataset limpio: 1470 filas × 32 columnas
[CONEXION]      Conexion establecida!
[CARGA]         Tabla empleados creada
[CARGA]         Empleados insertados: 1470 filas
✅  ETL COMPLETADO CORRECTAMENTE
```

---

## 🔍 Hallazgos clave

```
1 de cada 6 empleados abandona ABC Corporation (16.12%)
Sales Representative → 39.76% de abandono 🚨
El overtime TRIPLICA el riesgo (30.86% vs 10.52%)
Los que se van cobran un 30% menos ($2.058/mes)
Los primeros 2 años son la ventana crítica (34-36%)
La fuga cuesta $1.536.595 al mes ($18M al año)
Los solteros abandonan el doble que los casados
Stock options nivel 1 → abandono del 9.40%
```

---

## 💡 Plan de acción recomendado

**Prioridad alta — impacto inmediato:**
- Limitar el overtime o compensarlo correctamente
- Plan de onboarding reforzado en los primeros 2 años
- Revisión salarial en posiciones operativas

**Prioridad media:**
- Jornada híbrida para empleados a más de 13km
- Programa de conciliación WorkLifeBalance nivel 1
- Ampliar acceso a stock options nivel 1 y 2

**Largo plazo:**
- Planes de carrera claros para roles junior
- Revisión de promociones (empleados con 15 años sin ascender)
- Programa de mentoring para nuevas incorporaciones

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|------------|-----|
| **Python 3.11** | Análisis, limpieza y ETL |
| **Pandas** | Manipulación de datos |
| **Matplotlib / Seaborn** | Visualizaciones |
| **Scikit-Learn** | Modelo Random Forest |
| **MySQL 8.0** | Base de datos relacional |
| **mysql-connector-python** | Conexión Python → MySQL |
| **Jupyter Notebooks** | Desarrollo interactivo |
| **Git / GitHub** | Control de versiones en equipo |

---

## ⚙️ Instalación y uso

### Requisitos previos
```bash
pip install pandas numpy matplotlib seaborn scikit-learn mysql-connector-python
```

### Configuración de la base de datos
```python
# En Fase4_BBDD.ipynb o transform_ETLpy.py
conexion = mysql.connector.connect(
    host     = "localhost",
    user     = "root",
    password = "tu_password"
)
```

### Ejecutar el ETL completo
```bash
python transform_ETLpy.py
```

### Ejecutar los notebooks en orden
```
1. Fase1_EDA.ipynb
2. Fase2_Limpieza_ParejaA.ipynb + Fase2_Limpieza_ParejaB.ipynb
3. Fase3_Visualizacion_Unificada.ipynb
4. Fase4_BBDD.ipynb
```

---

## 📊 Dataset

**Archivo:** `hr.csv`
**Fuente:** ABC Corporation — datos internos de RRHH
**Registros:** 1.474 empleados × 35 variables
**Variable objetivo:** `Attrition` (Yes/No → 1/0)

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `EmployeeNumber` | int | Identificador único |
| `Attrition` | binary | Si el empleado se fue (1) o no (0) |
| `Department` | string | Departamento del empleado |
| `JobRole` | string | Rol dentro de la empresa |
| `MonthlyIncome` | int | Salario mensual en dólares |
| `OverTime` | binary | Si hace horas extra (1) o no (0) |
| `JobSatisfaction` | int | Nivel de satisfacción (1-4) |
| `YearsAtCompany` | int | Años en la empresa |

---

## 🤝 Metodología de trabajo

Proyecto desarrollado con metodología **Agile / Scrum**:
- Control de versiones con **Git** — cada miembro en su rama
- Pull requests para integrar el trabajo en `main`
- Puesta en común al finalizar cada fase

---

<div align="center">

**Promo 69 · Módulo 3 · Team 1 · Adalab · Junio 2026**

*Sabrina Gómez · Jezabel Sánchez · Cristina Millán · Jessica Hernández*

</div>
