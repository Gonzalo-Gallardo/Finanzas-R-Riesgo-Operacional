# -*- coding: utf-8 -*-
"""
DIPLOMADO EN CIENCIA DE DATOS PARA LAS FINANZAS
TRABAJO FINAL | MODELOS DE APRENDIZAJE AUTOMATICO EN FINANZAS

Evaluación y Priorización de Controles de Riesgo Operacional mediante Redes Neuronales Artificiales

Autor: Gonzalo Gallardo Alvarado
Metodologia: aprendizaje supervisado y red neuronal multicapa (ANN/MLP).
Objetivo: estimar la probabilidad de deficiencias en la siguiente revision
de controles de riesgo operacional y apoyar su priorizacion.

Nota metodologica: los datos son sinteticos; el desempeño corresponde
a un ejercicio academico y no constituye validacion bancaria real.
"""
from pathlib import Path
import json
import warnings

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')  # Generacion de figuras en archivos PNG
import matplotlib.pyplot as plt
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import (roc_auc_score, average_precision_score, precision_score,
                             recall_score, f1_score, accuracy_score, brier_score_loss,
                             confusion_matrix, RocCurveDisplay, PrecisionRecallDisplay)
from sklearn.inspection import permutation_importance

SEED = 20261022
BASE = Path(__file__).resolve().parent
DATOS = BASE / 'datos'
SALIDA = BASE / 'resultados'
DATOS.mkdir(exist_ok=True)
SALIDA.mkdir(exist_ok=True)

NUM = ['criticidad_riesgo', 'frecuencia_mensual', 'antiguedad_meses',
       'hallazgos_previos', 'incumplimientos_previos', 'dias_desde_revision',
       'cambios_proceso_90d', 'porcentaje_evidencia_previa']
CAT = ['tipo_control', 'area', 'plan_previo_abierto']
TARGET = 'deficiencia_siguiente_revision'


def crear_datos_sinteticos(n=2400, seed=SEED):
    """Genera observaciones hipotéticas con ruido, no etiquetas deterministas.
    Todas las variables explicativas se suponen observables ANTES de la revisión.
    """
    rng = np.random.default_rng(seed)
    fechas = pd.date_range('2023-01-01', '2026-09-01', freq='MS')
    periodos = rng.choice(len(fechas), n, replace=True)
    criticidad = rng.choice([1, 2, 3, 4, 5], n, p=[.09, .17, .31, .27, .16])
    tipo = rng.choice(['Manual', 'Automatizado', 'Mixto'], n, p=[.48, .29, .23])
    area = rng.choice(['Pagos', 'Tesoreria', 'Comex', 'Creditos', 'Operaciones'], n)
    frecuencia = rng.choice([1, 4, 20, 60], n, p=[.22, .27, .39, .12])
    antiguedad = rng.integers(2, 97, n)
    hallazgos = rng.poisson(.48 + .13 * (criticidad - 1), n).clip(0, 6)
    incumplimientos = rng.binomial(4, np.clip(.07 + .035 * hallazgos, 0, .8))
    dias = rng.integers(10, 361, n)
    cambios = rng.poisson(.35 + .07 * (criticidad - 1), n).clip(0, 5)
    evidencia = np.clip(rng.normal(91 - 4 * hallazgos - 3 * incumplimientos, 12, n), 25, 100)
    plan = np.where(rng.random(n) < np.clip(.12 + .10 * hallazgos, 0, .85), 'Si', 'No')
    # Logit oculto para crear etiquetas probabilísticas; no se usa como feature.
    z = (-3.4 + .39 * criticidad + .42 * hallazgos + .48 * incumplimientos
         + .32 * cambios + .003 * dias + .017 * (85 - evidencia)
         + .37 * (tipo == 'Manual') + .21 * (tipo == 'Mixto')
         + .31 * (plan == 'Si') + .14 * (area == 'Pagos')
         + rng.normal(0, .52, n))
    prob = 1 / (1 + np.exp(-np.clip(z, -20, 20)))
    y = rng.binomial(1, prob)
    df = pd.DataFrame({
        'id_revision': [f'REV-{i+1:05d}' for i in range(n)],
        'fecha_corte': pd.to_datetime(fechas[periodos]),
        'id_control': [f'CTRL-{i%120+1:03d}' for i in range(n)],
        'criticidad_riesgo': criticidad,
        'frecuencia_mensual': frecuencia,
        'antiguedad_meses': antiguedad,
        'hallazgos_previos': hallazgos,
        'incumplimientos_previos': incumplimientos,
        'dias_desde_revision': dias,
        'cambios_proceso_90d': cambios,
        'porcentaje_evidencia_previa': np.round(evidencia, 1),
        'tipo_control': tipo, 'area': area, 'plan_previo_abierto': plan,
        TARGET: y
    }).sort_values(['fecha_corte', 'id_revision']).reset_index(drop=True)
    return df


def construir_preprocesador():
    return ColumnTransformer([
        ('numericas', Pipeline([('imputar', SimpleImputer(strategy='median')),
                                ('escalar', StandardScaler())]), NUM),
        ('categoricas', Pipeline([('imputar', SimpleImputer(strategy='most_frequent')),
                                  ('onehot', OneHotEncoder(handle_unknown='ignore'))]), CAT)
    ])


def metrica(y, p, umbral):
    pred = (p >= umbral).astype(int)
    return {
        'n': int(len(y)), 'prevalencia': float(np.mean(y)),
        'roc_auc': float(roc_auc_score(y, p)) if len(np.unique(y)) > 1 else None,
        'average_precision': float(average_precision_score(y, p)),
        'precision': float(precision_score(y, pred, zero_division=0)),
        'recall': float(recall_score(y, pred, zero_division=0)),
        'f1': float(f1_score(y, pred, zero_division=0)),
        'accuracy': float(accuracy_score(y, pred)),
        'brier': float(brier_score_loss(y, p)),
        'matriz_confusion': confusion_matrix(y, pred, labels=[0, 1]).tolist()
    }


def elegir_umbral(y, p):
    """El umbral se elige SOLO en validación, no en prueba."""
    opciones = np.arange(.15, .851, .025)
    puntajes = [f1_score(y, p >= t, zero_division=0) for t in opciones]
    return float(opciones[int(np.argmax(puntajes))])


def guardar_graficos(y_test, probabilidades, umbral, ann, nombres_modelos):
    fig, ax = plt.subplots(figsize=(7.2, 5.1))
    for nombre, p in probabilidades.items():
        RocCurveDisplay.from_predictions(y_test, p, ax=ax, name=nombre)
    ax.plot([0, 1], [0, 1], '--', color='gray', label='Azar')
    ax.set_xlabel('Tasa de falsos positivos (1 - especificidad)')
    ax.set_ylabel('Tasa de verdaderos positivos (sensibilidad)')
    ax.set_title('Curvas ROC - conjunto de prueba temporal')
    ax.legend(loc='lower right')
    fig.tight_layout(); fig.savefig(SALIDA/'01_curvas_roc.png', dpi=160); plt.close(fig)

    fig, ax = plt.subplots(figsize=(7.2, 5.1))
    for nombre, p in probabilidades.items():
        PrecisionRecallDisplay.from_predictions(y_test, p, ax=ax, name=nombre)
    ax.set_xlabel('Sensibilidad (exhaustividad)')
    ax.set_ylabel('Precisión (valor predictivo positivo)')
    ax.set_title('Precisión y sensibilidad - conjunto de prueba')
    fig.tight_layout(); fig.savefig(SALIDA/'02_precision_recall.png', dpi=160); plt.close(fig)

    p = probabilidades['Red neuronal ANN']
    cm = confusion_matrix(y_test, p >= umbral, labels=[0, 1])
    fig, ax = plt.subplots(figsize=(5.5, 4.7))
    ax.imshow(cm, cmap='Blues')
    for i in range(2):
        for j in range(2):
            ax.text(j, i, str(cm[i, j]), ha='center', va='center', fontsize=16)
    ax.set_xticks([0,1], ['Sin deficiencia', 'Con deficiencia'])
    ax.set_yticks([0,1], ['Sin deficiencia', 'Con deficiencia'])
    ax.set_xlabel('Predicción'); ax.set_ylabel('Resultado observado')
    ax.set_title(f'Matriz de confusión ANN (umbral={umbral:.2f})')
    fig.tight_layout(); fig.savefig(SALIDA/'03_matriz_confusion.png', dpi=160); plt.close(fig)

    fig, ax = plt.subplots(figsize=(7.2, 4.8))
    ax.plot(ann.named_steps['clasificador'].loss_curve_)
    ax.set_title('Evolución de pérdida de entrenamiento ANN')
    ax.set_xlabel('Iteración'); ax.set_ylabel('Pérdida logarítmica de entrenamiento')
    fig.tight_layout(); fig.savefig(SALIDA/'04_curva_aprendizaje.png', dpi=160); plt.close(fig)


def ejecutar():
    print('\n' + '='*74)
    print('EVALUACION Y PRIORIZACION DE CONTROLES DE RIESGO OPERACIONAL')
    print('MEDIANTE REDES NEURONALES ARTIFICIALES')
    print('Autor: Gonzalo Gallardo Alvarado')
    print('Estudio academico con datos sinteticos | Semilla de reproducibilidad:', SEED)
    print('='*74)
    df = crear_datos_sinteticos()
    df.to_csv(DATOS/'base_sintetica_controles.csv', index=False, encoding='utf-8-sig')
    # Fechas ordenadas, sin mezclar periodos entre entrenamiento, validación y prueba.
    # Divisiones temporales fijas, establecidas ANTES de entrenar.
    train = df[df.fecha_corte < '2025-07-01'].copy()
    val = df[(df.fecha_corte >= '2025-07-01') & (df.fecha_corte < '2026-02-01')].copy()
    test = df[df.fecha_corte >= '2026-02-01'].copy()
    assert min(len(train), len(val), len(test)) > 100, 'Muestras insuficientes'
    assert all(x[TARGET].nunique() == 2 for x in (train, val, test))
    print('Registros: entrenamiento', len(train), '| validación', len(val), '| prueba', len(test))
    print('Prevalencias:', *(f'{x[TARGET].mean():.1%}' for x in (train,val,test)))
    Xtr, ytr = train[NUM+CAT], train[TARGET]
    Xv, yv = val[NUM+CAT], val[TARGET]
    Xt, yt = test[NUM+CAT], test[TARGET]

    modelos = {
        'Regresion logistica': Pipeline([
            ('preprocesar', construir_preprocesador()),
            ('clasificador', LogisticRegression(max_iter=1500, random_state=SEED))]),
        'Red neuronal ANN': Pipeline([
            ('preprocesar', construir_preprocesador()),
            ('clasificador', MLPClassifier(hidden_layer_sizes=(16, 8), activation='relu',
                                         solver='adam', alpha=.05, learning_rate_init=.001,
                                         max_iter=500, early_stopping=True,
                                         validation_fraction=.15, n_iter_no_change=22,
                                         random_state=SEED))])
    }
    resultados = {}
    probs_test = {}
    umbrales = {}
    for nombre, modelo in modelos.items():
        print('\nEntrenando:', nombre)
        with warnings.catch_warnings():
            warnings.filterwarnings('ignore', category=UserWarning, module='sklearn')
            modelo.fit(Xtr, ytr)
        pv = modelo.predict_proba(Xv)[:, 1]
        umbral = elegir_umbral(yv, pv)
        pt = modelo.predict_proba(Xt)[:, 1]
        umbrales[nombre] = umbral
        probs_test[nombre] = pt
        resultados[nombre] = {
            'validacion': metrica(yv, pv, umbral),
            'prueba': metrica(yt, pt, umbral),
            'umbral_validacion': umbral
        }
        m = resultados[nombre]['prueba']
        print(f"  Prueba: ROC-AUC={m['roc_auc']:.3f} | AP={m['average_precision']:.3f} | "
              f"F1={m['f1']:.3f} | Sensibilidad={m['recall']:.3f} | Umbral={umbral:.3f}")

    # Importancia por permutación, evaluada SOLO sobre el conjunto de prueba.
    # Su uso es descriptivo y no se utiliza para ajustar ni elegir modelos.
    ann = modelos['Red neuronal ANN']
    importancia = permutation_importance(ann, Xt, yt, n_repeats=6,
                                         random_state=SEED, scoring='roc_auc')
    imp = pd.DataFrame({'variable': NUM+CAT, 'reduccion_auc_media': importancia.importances_mean,
                        'desviacion': importancia.importances_std}).sort_values('reduccion_auc_media', ascending=False)
    imp.to_csv(SALIDA/'importancia_variables.csv', index=False, encoding='utf-8-sig')

    fig, ax = plt.subplots(figsize=(9, 5.5))
    top = imp.head(10).iloc[::-1]
    ax.barh(top['variable'], top['reduccion_auc_media'])
    ax.set_xlabel('Disminución media de ROC-AUC al permutar')
    ax.set_title('Importancia de variables ANN - análisis descriptivo')
    fig.tight_layout(); fig.savefig(SALIDA/'05_importancia_variables.png', dpi=160); plt.close(fig)

    # Priorizar registros de prueba: sin usar la etiqueta como entrada.
    prioridades = test[['id_revision','id_control','fecha_corte','area','tipo_control', TARGET]].copy()
    prioridades['probabilidad_deficiencia'] = np.round(probs_test['Red neuronal ANN'], 4)
    # Bandas operativas ilustrativas; NO equivalen a categorías regulatorias.
    prioridades['prioridad_operativa'] = pd.cut(
        prioridades['probabilidad_deficiencia'], bins=[-0.001,.35,.65,1.001],
        labels=['Baja','Media','Alta'])
    prioridades = prioridades.sort_values('probabilidad_deficiencia', ascending=False)
    prioridades.to_csv(SALIDA/'priorizacion_controles_prueba.csv', index=False, encoding='utf-8-sig')
    # Ejemplo de predicción sin conocer el resultado de la siguiente revisión.
    nuevo = pd.DataFrame([{
        'criticidad_riesgo':5, 'frecuencia_mensual':20, 'antiguedad_meses':36,
        'hallazgos_previos':2, 'incumplimientos_previos':1,
        'dias_desde_revision':190, 'cambios_proceso_90d':2,
        'porcentaje_evidencia_previa':73, 'tipo_control':'Manual',
        'area':'Pagos', 'plan_previo_abierto':'Si'
    }])
    p_nuevo = float(ann.predict_proba(nuevo[NUM+CAT])[0,1])
    pd.DataFrame([{'id_control':'CONTROL-EJEMPLO', 'probabilidad_deficiencia':round(p_nuevo,4)}]).to_csv(
        SALIDA/'prediccion_control_nuevo.csv', index=False, encoding='utf-8-sig')
    guardar_graficos(yt, probs_test, umbrales['Red neuronal ANN'], ann, list(modelos))
    (SALIDA/'metricas_modelos.json').write_text(json.dumps(resultados, indent=2, ensure_ascii=False), encoding='utf-8')

    ann_m = resultados['Red neuronal ANN']['prueba']
    log_m = resultados['Regresion logistica']['prueba']
    informe = f'''# Evaluación y Priorización de Controles de Riesgo Operacional mediante Redes Neuronales Artificiales

**Autor:** Gonzalo Gallardo Alvarado  
**Curso:** Introducción a modelos de Machine Learning en Finanzas  
**Alternativa:** B, red neuronal artificial (ANN)  
**Problema:** predecir si un control operacional presentará deficiencias en su siguiente revisión, utilizando atributos disponibles antes de la revisión.

## Alcance y naturaleza de los datos

Los **{len(df)} registros son completamente sintéticos** y generados con una regla probabilística hipotética más ruido aleatorio. Los resultados son una demostración de funcionamiento del software y **no** validan su capacidad de predicción en bancos reales. No se usan datos confidenciales. Los registros no representan operaciones, controles ni revisiones de una entidad real.

## Metodología

- Variables predictoras: {', '.join(NUM + CAT)}.
- Etiqueta: `{TARGET}` (1 = deficiencia en siguiente revisión; 0 = sin deficiencia).
- Separación temporal predefinida: entrenamiento anterior a julio de 2025 ({len(train)}); validación de julio de 2025 a enero de 2026 ({len(val)}); prueba desde febrero de 2026 ({len(test)}).
- Preprocesamiento ajustado solo con entrenamiento: imputación de faltantes, estandarización numérica y codificación one-hot.
- ANN: MLP con capas ocultas 16 y 8, ReLU, optimizador Adam, regularización L2, detención temprana con validación interna del entrenamiento.
- Referencia: regresión logística con el mismo preprocesamiento.
- Umbrales seleccionados en el conjunto de validación para maximizar F1. El conjunto de prueba se reservó para evaluación final.
- Métricas: área bajo la curva ROC (ROC-AUC), precisión promedio (AP), precisión, sensibilidad, F1, exactitud y puntuación de Brier.

## Resultados fuera de muestra

| Indicador | ANN | Regresión logística |
|---|---:|---:|
| ROC-AUC | {ann_m['roc_auc']:.3f} | {log_m['roc_auc']:.3f} |
| Precisión promedio (AP) | {ann_m['average_precision']:.3f} | {log_m['average_precision']:.3f} |
| F1 | {ann_m['f1']:.3f} | {log_m['f1']:.3f} |
| Precisión | {ann_m['precision']:.3f} | {log_m['precision']:.3f} |
| Sensibilidad | {ann_m['recall']:.3f} | {log_m['recall']:.3f} |
| Brier (menor es mejor) | {ann_m['brier']:.3f} | {log_m['brier']:.3f} |

**Matriz de confusión ANN** (filas: real 0/1; columnas: predicho 0/1): {ann_m['matriz_confusion']}.  
**Umbral ANN seleccionado en validación:** {umbrales['Red neuronal ANN']:.3f}.  
**Ejemplo nuevo (hipotético):** probabilidad ANN {p_nuevo:.1%}.

## Interpretación y limitaciones

La clasificación permite ordenar las revisiones de controles por probabilidad estimada. La importancia por permutación indica qué variables afectan más la discriminación del modelo en estos datos, sin establecer causalidad. La probabilidad no representa una tasa bancaria observada. Las bandas de prioridad baja/media/alta son ilustrativas, no reglas normativas. La selección del modelo no debe basarse exclusivamente en la comparación de prueba: la ANN puede ser inferior a la regresión logística si la relación subyacente es sencilla.

Los registros reutilizan identificadores de control, pero son observaciones sintéticas generadas independientemente; no reproducen trayectorias históricas reales. Antes de cualquier uso real se requiere: historial etiquetado y autorizado, definición operacional de deficiencia, prevención de fuga temporal de datos, validación por periodo y control, calibración, revisión de sesgos y aprobación de gobierno de modelos.

## Archivos generados

`datos/base_sintetica_controles.csv`, `resultados/metricas_modelos.json`, `resultados/priorizacion_controles_prueba.csv`, `resultados/prediccion_control_nuevo.csv`, `resultados/importancia_variables.csv`, y gráficos PNG 01 a 05.

## Conclusión

El proyecto implementa y ejecuta una ANN para clasificación binaria, la compara con un modelo lineal de referencia y demuestra la producción reproducible de predicciones, métricas y un ranking operativo. Su utilidad empírica fuera del escenario sintético permanece pendiente de validación.
'''
    (SALIDA/'INFORME_RESULTADOS.md').write_text(informe, encoding='utf-8')
    print('\nEjemplo de control nuevo: probabilidad estimada', f'{p_nuevo:.1%}')
    print('Archivos creados en:', SALIDA)
    print('EJECUCION FINALIZADA CORRECTAMENTE')
    return resultados

if __name__ == '__main__':
    ejecutar()
