# Evaluación y Priorización de Controles de Riesgo Operacional mediante Redes Neuronales Artificiales

**Autor:** Gonzalo Gallardo Alvarado  
**Programa:** Diplomado en Ciencia de Datos para las Finanzas  
**Asignatura:** Introducción a Modelos de Machine Learning en Finanzas  
**Docente:** Guillermo Yañez  
**Alternativa seleccionada:** B — Redes neuronales artificiales (ANN)  
**Lenguaje de programación:** Python  

## Resumen ejecutivo

Este proyecto desarrolla un sistema de aprendizaje supervisado orientado a estimar la probabilidad de que un control de riesgo operacional presente deficiencias en su próxima revisión. Se entrena una red neuronal multicapa (MLP) y se contrasta su desempeño con una regresión logística de referencia. El sistema genera métricas de clasificación, gráficos diagnósticos, estimaciones de probabilidad y una priorización ilustrativa de controles.

**Alcance:** los 2.400 registros utilizados son **sintéticos** y no representan información de una institución financiera. Las métricas corresponden a un ejercicio académico; no acreditan desempeño predictivo en producción.

## Ejecución y reproducibilidad

1. Extraer el ZIP en una carpeta local (por ejemplo, `C:\Diplomado`).
2. Abrir y ejecutar `main.py` en un entorno Python, o ejecutar `python main.py` en terminal.
3. El programa utiliza un intérprete con bibliotecas disponibles; si no lo encuentra, intenta preparar un entorno independiente en una ruta corta del sistema y muestra el detalle de cualquier error de instalación.
4. Consultar los archivos en `resultados/`. El paquete incluye resultados de referencia para su revisión aun cuando la instalación de dependencias no sea posible.

**Validación de ejecución:** solo se considera un entrenamiento nuevo cuando aparece `PROCESAMIENTO FINALIZADO CORRECTAMENTE`. Si la instalación falla, el programa informa que los resultados incluidos son preexistentes; no afirma haber reentrenado.

**Dependencias:** Python 3.10 o superior; `requirements.txt`. Para instalar manualmente: `python -m pip install -r requirements.txt`.

## Estructura del proyecto

- `main.py`: orquestación de dependencias y del flujo de procesamiento.
- `modelo_red_neuronal_riesgo_operacional.py`: generación de datos, preprocesamiento, entrenamiento, evaluación y resultados.
- `validacion_modelo.py`: pruebas de reproducibilidad, integridad y consistencia de resultados.
- `requirements.txt`: dependencias del proyecto.
- `datos/base_sintetica_controles.csv`: base de observaciones sintéticas.
- `resultados/`: gráficos ROC, precisión–sensibilidad, matriz de confusión, evolución de pérdida, importancia de variables, indicadores JSON, predicciones y priorización CSV.
- `INFORME_ACADEMICO_FINAL.pdf`: informe académico y metodología.

## Metodología

**Pregunta de investigación:** ¿Es posible estimar la ocurrencia de deficiencias en la siguiente revisión de controles de riesgo operacional a partir de atributos disponibles antes de la revisión?

**Modelo principal:** red neuronal artificial multicapa con dos capas ocultas (16 y 8 neuronas), función de activación ReLU, optimizador Adam y detención temprana.

**Modelo comparativo:** regresión logística con preprocesamiento equivalente.

**Diseño de evaluación:** partición temporal en entrenamiento, validación y prueba; elección del umbral con el conjunto de validación; evaluación fuera de muestra en prueba.

**Indicadores:** ROC-AUC, precisión promedio (AP), precisión, sensibilidad (recall), F1, exactitud y Brier.

## Resultados de referencia

| Indicador (prueba) | Red neuronal ANN | Regresión logística |
|---|---:|---:|
| ROC-AUC | 0,704 | 0,719 |
| Precisión promedio (AP) | 0,575 | 0,610 |
| F1-score | 0,543 | 0,559 |
| Sensibilidad (recall) | 0,940 | 0,801 |

La ANN exhibe mayor sensibilidad, mientras que la regresión logística obtiene mejores ROC-AUC y F1. Los resultados no justifican afirmar superioridad general de la red neuronal. Las bandas de priorización son demostrativas y no equivalen a clasificaciones regulatorias.

## Reproducibilidad y límites

Se utiliza semilla fija (`20261022`) y un procedimiento reproducible de generación de datos. El ejercicio no emplea información bancaria real. Antes de cualquier aplicación operativa serían necesarios datos históricos autorizados, evaluación de sesgos, calibración, validación temporal adicional y gobierno de modelos.

**Entrega:** incluir código fuente, `requirements.txt`, datos, resultados e informe. **Excluir `.entorno_proyecto`, `__pycache__` y archivos temporales** del ZIP.
