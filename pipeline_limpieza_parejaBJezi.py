# transform.py
# Pipeline completo de limpieza y transformación del dataset HR
# Pareja B — Fase 2

import pandas as pd


# --- FUNCIONES DE LIMPIEZA ---

def drop_useless_cols(df):
    """
    Elimina las columnas constantes que no aportan
    variabilidad ni valor al análisis.
    """
    cols_to_drop = ['EmployeeCount', 'Over18', 'StandardHours']
    return df.drop(columns=cols_to_drop, errors='ignore')


def drop_duplicates(df):
    """
    Elimina las filas duplicadas del dataset.
    """
    return df.drop_duplicates()


def fix_job_role(df):
    """
    Elimina espacios en blanco en los extremos de 'JobRole'
    y transforma el texto a formato título estándar.
    """
    df_mod = df.copy()
    df_mod['JobRole'] = df_mod['JobRole'].str.strip().str.title()
    return df_mod


def fix_marital_status(df):
    """
    Corrige la errata de escritura 'Marreid' pasándola a 'Married'
    en la columna MaritalStatus.
    """
    df_mod = df.copy()
    df_mod['MaritalStatus'] = df_mod['MaritalStatus'].replace({'Marreid': 'Married'})
    return df_mod


def fix_categorical_nulls(df):
    """
    Rellena los valores nulos de las columnas categóricas con 'Unknown'.
    """
    df_mod = df.copy()
    cols_with_nulls = ['Department', 'MaritalStatus', 'OverTime', 'BusinessTravel']
    for col in cols_with_nulls:
        df_mod[col] = df_mod[col].fillna('Unknown')
    return df_mod


def fix_numerical_nulls(df):
    """
    Rellena los valores nulos de las columnas numéricas con la mediana.
    Usamos la mediana porque es resistente a valores extremos (outliers).
    """
    df_mod = df.copy()
    cols_with_nulls = ['Age', 'JobSatisfaction', 'MonthlyIncome',
                       'TrainingTimesLastYear', 'YearsWithCurrManager']
    for col in cols_with_nulls:
        df_mod[col] = df_mod[col].fillna(df_mod[col].median())
    return df_mod


def fix_dtypes(df):
    """
    Convierte columnas numéricas que están en float64 a int64,
    ya que representan valores enteros.
    Solo se aplica después de haber tratado los nulos.
    """
    df_mod = df.copy()
    cols_to_fix = ['Age', 'JobSatisfaction', 'MonthlyIncome',
                   'TrainingTimesLastYear', 'YearsWithCurrManager']
    for col in cols_to_fix:
        df_mod[col] = df_mod[col].astype(int)
    return df_mod


def encode_binary(df):
    """
    Codifica las columnas binarias 'Attrition' y 'OverTime' a 1/0.
    Yes → 1, No → 0, Unknown → nulo (pd.NA).
    """
    df_mod = df.copy()
    binary_mapping = {'Yes': 1, 'No': 0, 'Unknown': pd.NA}
    df_mod['Attrition'] = df_mod['Attrition'].replace(binary_mapping).astype('Int64')
    df_mod['OverTime'] = df_mod['OverTime'].replace(binary_mapping).astype('Int64')
    return df_mod


def validate(df_original, df_clean):
    """
    Comprueba que el pipeline ha funcionado correctamente.
    Lanza un error si algo no está bien.
    """
    assert df_clean.shape[1] == 32, f"Error: Se esperaban 32 columnas pero hay {df_clean.shape[1]}"
    assert df_clean.shape[0] == 1470, f"Error: Se esperaban 1470 filas pero hay {df_clean.shape[0]}"
    assert df_clean['Department'].isnull().sum() == 0, "Error: Siguen quedando nulos en Department"
    assert df_clean['MaritalStatus'].isnull().sum() == 0, "Error: Siguen quedando nulos en MaritalStatus"
    assert df_clean['BusinessTravel'].isnull().sum() == 0, "Error: Siguen quedando nulos en BusinessTravel"
    assert df_clean['Age'].isnull().sum() == 0, "Error: Siguen quedando nulos en Age"
    assert df_clean['MonthlyIncome'].isnull().sum() == 0, "Error: Siguen quedando nulos en MonthlyIncome"
    assert df_clean['TrainingTimesLastYear'].isnull().sum() == 0, "Error: Siguen quedando nulos en TrainingTimesLastYear"
    assert df_clean['YearsWithCurrManager'].isnull().sum() == 0, "Error: Siguen quedando nulos en YearsWithCurrManager"
    assert 'Marreid' not in df_clean['MaritalStatus'].unique(), "Error: La errata 'Marreid' sigue existiendo"
    assert df_clean['Age'].dtype == 'int64', "Error: Age no es int64"
    assert df_clean['MonthlyIncome'].dtype == 'int64', "Error: MonthlyIncome no es int64"
    assert df_clean['Attrition'].dtype == 'Int64', "Error: Attrition no es Int64"
    assert df_clean['OverTime'].dtype == 'Int64', "Error: OverTime no es Int64"
    print("✅ ¡Todos los controles de calidad han pasado! El dataset está limpio y listo.")


# --- PIPELINE COMPLETO ---

if __name__ == "__main__":
    # Cargamos el dataset original
    df_original = pd.read_csv('hr.csv')

    # Ejecutamos el pipeline en orden
    df_clean = df_original.copy()
    df_clean = drop_useless_cols(df_clean)
    df_clean = drop_duplicates(df_clean)
    df_clean = fix_job_role(df_clean)
    df_clean = fix_marital_status(df_clean)
    df_clean = fix_categorical_nulls(df_clean)
    df_clean = fix_numerical_nulls(df_clean)
    df_clean = fix_dtypes(df_clean)
    df_clean = encode_binary(df_clean)
    validate(df_original, df_clean)

    # Guardamos el resultado
    df_clean.to_csv('Fase2_ParejaB_limpiezaJezi.csv', index=False)
    print(f"✅ Archivo guardado. Dimensiones finales: {df_clean.shape[0]} filas x {df_clean.shape[1]} columnas")