# Evaluación y Priorización de Controles de Riesgo Operacional mediante Redes Neuronales Artificiales

**Autor:** Gonzalo Gallardo Alvarado  
**Curso:** Introducción a modelos de Machine Learning en Finanzas  
**Alternativa:** B, red neuronal artificial (ANN)  
**Problema:** predecir si un control operacional presentará deficiencias en su siguiente revisión, utilizando atributos disponibles antes de la revisión.

## Alcance y naturaleza de los datos

Los **2400 registros son completamente sintéticos** y generados con una regla probabilística hipotética más ruido aleatorio. Los resultados son una demostración de funcionamiento del software y **no** validan su capacidad de predicción en bancos reales. No se usan datos confidenciales. Los registros no representan operaciones, controles ni revisiones de una entidad real.

## Metodología

- Variables predictoras: criticidad_riesgo, frecuencia_mensual, antiguedad_meses, hallazgos_previos, incumplimientos_previos, dias_desde_revision, cambios_proceso_90d, porcentaje_evidencia_previa, tipo_control, area, plan_previo_abierto.
- Etiqueta: `deficiencia_siguiente_revision` (1 = deficiencia en siguiente revisión; 0 = sin deficiencia).
- Separación temporal predefinida: entrenamiento anterior a julio de 2025 (1586); validación de julio de 2025 a enero de 2026 (371); prueba desde febrero de 2026 (443).
- Preprocesamiento ajustado solo con entrenamiento: imputación de faltantes, estandarización numérica y codificación one-hot.
- ANN: MLP con capas ocultas 16 y 8, ReLU, optimizador Adam, regularización L2, detención temprana con validación interna del entrenamiento.
- Referencia: regresión logística con el mismo preprocesamiento.
- Umbrales seleccionados en el conjunto de validación para maximizar F1. El conjunto de prueba se reservó para evaluación final.
- Métricas: área bajo la curva ROC (ROC-AUC), precisión promedio (AP), precisión, sensibilidad, F1, exactitud y puntuación de Brier.

## Resultados fuera de muestra

| Indicador | ANN | Regresión logística |
|---|---:|---:|
| ROC-AUC | 0.704 | 0.719 |
| Precisión promedio (AP) | 0.575 | 0.610 |
| F1 | 0.543 | 0.559 |
| Precisión | 0.382 | 0.429 |
| Sensibilidad | 0.940 | 0.801 |
| Brier (menor es mejor) | 0.199 | 0.192 |

**Matriz de confusión ANN** (filas: real 0/1; columnas: predicho 0/1): [[62, 230], [9, 142]].  
**Umbral ANN seleccionado en validación:** 0.225.  
**Ejemplo nuevo (hipotético):** probabilidad ANN 74.7%.

## Interpretación y limitaciones

La clasificación permite ordenar las revisiones de controles por probabilidad estimada. La importancia por permutación indica qué variables afectan más la discriminación del modelo en estos datos, sin establecer causalidad. La probabilidad no representa una tasa bancaria observada. Las bandas de prioridad baja/media/alta son ilustrativas, no reglas normativas. La selección del modelo no debe basarse exclusivamente en la comparación de prueba: la ANN puede ser inferior a la regresión logística si la relación subyacente es sencilla.

Los registros reutilizan identificadores de control, pero son observaciones sintéticas generadas independientemente; no reproducen trayectorias históricas reales. Antes de cualquier uso real se requiere: historial etiquetado y autorizado, definición operacional de deficiencia, prevención de fuga temporal de datos, validación por periodo y control, calibración, revisión de sesgos y aprobación de gobierno de modelos.

## Archivos generados

`datos/base_sintetica_controles.csv`, `resultados/metricas_modelos.json`, `resultados/priorizacion_controles_prueba.csv`, `resultados/prediccion_control_nuevo.csv`, `resultados/importancia_variables.csv`, y gráficos PNG 01 a 05.

## Conclusión

El proyecto implementa y ejecuta una ANN para clasificación binaria, la compara con un modelo lineal de referencia y demuestra la producción reproducible de predicciones, métricas y un ranking operativo. Su utilidad empírica fuera del escenario sintético permanece pendiente de validación.
