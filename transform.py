# ================================================
# FASE 5 — ETL (Extract, Transform, Load)
# ABC Corporation — HR Analytics
# ================================================

import pandas as pd
import mysql.connector

# ════════════════════════════════════════════════
# EXTRACCIÓN
# ════════════════════════════════════════════════

def extraer_datos(ruta_csv):
    """
    Extrae los datos desde el CSV original.
    Devuelve un DataFrame con los datos crudos.
    """
    df = pd.read_csv(ruta_csv)
    print(f"[EXTRACCION] CSV cargado: {df.shape[0]} filas x {df.shape[1]} columnas")
    return df


# ════════════════════════════════════════════════
# TRANSFORMACIÓN
# ════════════════════════════════════════════════

def fix_job_role(df):
    """Limpia el texto corrupto de JobRole."""
    df["JobRole"] = df["JobRole"].str.strip()
    df["JobRole"] = df["JobRole"].str.title()
    print("[TRANSFORMACION] JobRole limpio")
    return df


def fix_types(df):
    """Convierte columnas float que deberían ser int."""
    cols = ["Age", "JobSatisfaction", "MonthlyIncome", "YearsWithCurrManager"]
    for col in cols:
        if col in df.columns:
            df[col] = df[col].fillna(0)
            df[col] = df[col].astype(int)
    print("[TRANSFORMACION] Tipos de datos corregidos")
    return df


def fix_nulls(df):
    """Rellena nulos con mediana (numéricas) o moda (texto)."""
    cols_mediana = [
        "YearsWithCurrManager", "TrainingTimesLastYear",
        "Age", "JobSatisfaction", "MonthlyIncome"
    ]
    for col in cols_mediana:
        if col in df.columns:
            mediana = df[col].median()
            df[col] = df[col].replace(0, mediana)

    cols_moda = [
        "MaritalStatus", "BusinessTravel",
        "EducationField", "OverTime", "Department"
    ]
    for col in cols_moda:
        if col in df.columns:
            moda = df[col].mode()[0]
            df[col] = df[col].fillna(moda)

    if "TrainingTimesLastYear" in df.columns:
        df["TrainingTimesLastYear"] = df["TrainingTimesLastYear"].fillna(
            df["TrainingTimesLastYear"].median()).astype(int)

    print("[TRANSFORMACION] Nulos tratados")
    return df


def drop_useless_cols(df):
    """Elimina columnas sin varianza que no aportan información."""
    cols = ["EmployeeCount", "Over18", "StandardHours"]
    cols_existentes = [c for c in cols if c in df.columns]
    df = df.drop(columns=cols_existentes)
    print(f"[TRANSFORMACION] Columnas eliminadas: {cols_existentes}")
    return df


def encode_binary(df):
    """Convierte columnas Yes/No a 1/0."""
    mapping = {"Yes": 1, "No": 0}
    if "Attrition" in df.columns:
        df["Attrition"] = df["Attrition"].map(mapping)
    if "OverTime" in df.columns:
        df["OverTime"] = df["OverTime"].map(mapping)
        df["OverTime"] = df["OverTime"].fillna(0).astype(int)
    print("[TRANSFORMACION] Columnas binarias codificadas")
    return df


def drop_duplicates(df):
    """Elimina filas duplicadas."""
    antes = len(df)
    df = df.drop_duplicates()
    despues = len(df)
    print(f"[TRANSFORMACION] Duplicados eliminados: {antes - despues} filas")
    return df


def transformar_datos(df):
    """
    Aplica todas las transformaciones en orden.
    Devuelve el DataFrame limpio.
    """
    print("\n[TRANSFORMACION] Iniciando pipeline de limpieza...")
    df = fix_job_role(df)
    df = fix_types(df)
    df = fix_nulls(df)
    df = drop_useless_cols(df)
    df = encode_binary(df)
    df = drop_duplicates(df)
    print(f"[TRANSFORMACION] Dataset limpio: {df.shape[0]} filas x {df.shape[1]} columnas")
    return df


# ════════════════════════════════════════════════
# CARGA — Creación de la BBDD
# ════════════════════════════════════════════════

def crear_bbdd(cursor, conexion):
    """Crea la base de datos y las 4 tablas."""

    print("\n[CARGA] Creando base de datos...")
    cursor.execute("CREATE DATABASE IF NOT EXISTS abc_corporation")
    cursor.execute("USE abc_corporation")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS empleados (
            EmployeeNumber    INT PRIMARY KEY,
            Age               INT,
            Gender            VARCHAR(10),
            MaritalStatus     VARCHAR(20),
            Education         INT,
            EducationField    VARCHAR(50),
            Attrition         INT,
            DistanceFromHome  INT
        )
    """)
    print("[CARGA] Tabla empleados creada")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS puestos (
            EmployeeNumber          INT PRIMARY KEY,
            Department              VARCHAR(50),
            JobRole                 VARCHAR(50),
            JobLevel                INT,
            BusinessTravel          VARCHAR(30),
            OverTime                INT,
            YearsAtCompany          INT,
            YearsInCurrentRole      INT,
            YearsSinceLastPromotion INT,
            YearsWithCurrManager    INT,
            TotalWorkingYears       INT,
            NumCompaniesWorked      INT,
            TrainingTimesLastYear   INT,
            FOREIGN KEY (EmployeeNumber) REFERENCES empleados(EmployeeNumber)
        )
    """)
    print("[CARGA] Tabla puestos creada")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS satisfaccion (
            EmployeeNumber           INT PRIMARY KEY,
            JobSatisfaction          INT,
            EnvironmentSatisfaction  INT,
            RelationshipSatisfaction INT,
            WorkLifeBalance          INT,
            JobInvolvement           INT,
            PerformanceRating        INT,
            FOREIGN KEY (EmployeeNumber) REFERENCES empleados(EmployeeNumber)
        )
    """)
    print("[CARGA] Tabla satisfaccion creada")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS compensacion (
            EmployeeNumber     INT PRIMARY KEY,
            MonthlyIncome      INT,
            MonthlyRate        INT,
            DailyRate          INT,
            HourlyRate         INT,
            PercentSalaryHike  INT,
            StockOptionLevel   INT,
            FOREIGN KEY (EmployeeNumber) REFERENCES empleados(EmployeeNumber)
        )
    """)
    print("[CARGA] Tabla compensacion creada")
    conexion.commit()


# ════════════════════════════════════════════════
# CARGA — Inserción de datos
# ════════════════════════════════════════════════

def cargar_datos(df, cursor, conexion):
    """Inserta todos los datos en las 4 tablas."""

    # Convertir NaN a None para MySQL
    df = df.where(pd.notnull(df), None)

    print("\n[CARGA] Insertando datos...")

    # Tabla empleados
    cursor.executemany("""
        INSERT IGNORE INTO empleados
            (EmployeeNumber, Age, Gender, MaritalStatus,
             Education, EducationField, Attrition, DistanceFromHome)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, df[["EmployeeNumber", "Age", "Gender", "MaritalStatus",
             "Education", "EducationField", "Attrition",
             "DistanceFromHome"]].values.tolist())
    conexion.commit()
    print(f"[CARGA] Empleados insertados: {cursor.rowcount} filas")

    # Tabla puestos
    cursor.executemany("""
        INSERT IGNORE INTO puestos
            (EmployeeNumber, Department, JobRole, JobLevel,
             BusinessTravel, OverTime, YearsAtCompany,
             YearsInCurrentRole, YearsSinceLastPromotion,
             YearsWithCurrManager, TotalWorkingYears,
             NumCompaniesWorked, TrainingTimesLastYear)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, df[["EmployeeNumber", "Department", "JobRole", "JobLevel",
             "BusinessTravel", "OverTime", "YearsAtCompany",
             "YearsInCurrentRole", "YearsSinceLastPromotion",
             "YearsWithCurrManager", "TotalWorkingYears",
             "NumCompaniesWorked",
             "TrainingTimesLastYear"]].values.tolist())
    conexion.commit()
    print(f"[CARGA] Puestos insertados: {cursor.rowcount} filas")

    # Tabla satisfaccion
    cursor.executemany("""
        INSERT IGNORE INTO satisfaccion
            (EmployeeNumber, JobSatisfaction, EnvironmentSatisfaction,
             RelationshipSatisfaction, WorkLifeBalance,
             JobInvolvement, PerformanceRating)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, df[["EmployeeNumber", "JobSatisfaction", "EnvironmentSatisfaction",
             "RelationshipSatisfaction", "WorkLifeBalance",
             "JobInvolvement",
             "PerformanceRating"]].values.tolist())
    conexion.commit()
    print(f"[CARGA] Satisfaccion insertada: {cursor.rowcount} filas")

    # Tabla compensacion
    cursor.executemany("""
        INSERT IGNORE INTO compensacion
            (EmployeeNumber, MonthlyIncome, MonthlyRate,
             DailyRate, HourlyRate, PercentSalaryHike, StockOptionLevel)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, df[["EmployeeNumber", "MonthlyIncome", "MonthlyRate",
             "DailyRate", "HourlyRate", "PercentSalaryHike",
             "StockOptionLevel"]].values.tolist())
    conexion.commit()
    print(f"[CARGA] Compensacion insertada: {cursor.rowcount} filas")


# ════════════════════════════════════════════════
# PIPELINE COMPLETO — función principal
# ════════════════════════════════════════════════

def ejecutar_etl(ruta_csv, host, user, password):
    """
    Ejecuta el pipeline ETL completo:
    Extracción → Transformación → Carga
    """
    print("=" * 55)
    print("  ETL ABC CORPORATION — INICIANDO PIPELINE")
    print("=" * 55)

    # 1. EXTRACCIÓN
    df = extraer_datos(ruta_csv)

    # 2. TRANSFORMACIÓN
    df = transformar_datos(df)

    # 3. CONEXIÓN A MYSQL
    print("\n[CONEXION] Conectando a MySQL...")
    conexion = mysql.connector.connect(
        host     = host,
        user     = user,
        password = password
    )
    cursor = conexion.cursor()
    print("[CONEXION] Conexion establecida!")

    # 4. CREACIÓN DE BBDD
    crear_bbdd(cursor, conexion)

    # 5. CARGA DE DATOS
    cargar_datos(df, cursor, conexion)

    # 6. CERRAR CONEXIÓN
    cursor.close()
    conexion.close()

    print("\n" + "=" * 55)
    print("  ETL COMPLETADO CORRECTAMENTE!")
    print("=" * 55)


# ════════════════════════════════════════════════
# EJECUCIÓN
# ════════════════════════════════════════════════

if __name__ == "__main__":
    ejecutar_etl(
        ruta_csv = "hr.csv",
        host     = "localhost",
        user     = "root",
        password = "tu_contraseña"
    )