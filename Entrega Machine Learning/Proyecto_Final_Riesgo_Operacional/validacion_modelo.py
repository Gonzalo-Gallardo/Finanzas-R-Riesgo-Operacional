# -*- coding: utf-8 -*-
"""
DIPLOMADO EN CIENCIA DE DATOS PARA LAS FINANZAS
TRABAJO FINAL | MODELOS DE APRENDIZAJE AUTOMATICO EN FINANZAS

Evaluación y Priorización de Controles de Riesgo Operacional mediante Redes Neuronales Artificiales

Autor: Gonzalo Gallardo Alvarado
Metodologia: aprendizaje supervisado y red neuronal multicapa (ANN/MLP).
Modulo de verificacion de reproducibilidad, integridad y consistencia
de los productos analiticos del proyecto.

Nota metodologica: los datos son sinteticos; el desempeño corresponde
a un ejercicio academico y no constituye validacion bancaria real.
"""
from pathlib import Path
import json
import numpy as np
from modelo_red_neuronal_riesgo_operacional import crear_datos_sinteticos, construir_preprocesador, NUM, CAT, TARGET, ejecutar

def verificar():
    df = crear_datos_sinteticos()
    assert len(df) == 2400
    assert df.id_revision.is_unique
    assert set(df[TARGET].unique()) == {0, 1}
    assert TARGET not in NUM + CAT
    assert df[NUM+CAT].notna().all().all()
    df2 = crear_datos_sinteticos()
    assert df.equals(df2), 'Los datos no son reproducibles'
    pre = construir_preprocesador()
    pre.fit(df.iloc[:100][NUM+CAT])
    assert np.isfinite(pre.transform(df.iloc[100:110][NUM+CAT])).all()
    r = ejecutar()
    for nombre, info in r.items():
        for fase in ('validacion', 'prueba'):
            m = info[fase]
            assert 0 <= m['roc_auc'] <= 1
            assert 0 <= m['f1'] <= 1
            assert sum(map(sum,m['matriz_confusion'])) == m['n']
    base = Path(__file__).resolve().parent
    for archivo in ('01_curvas_roc.png','02_precision_recall.png','03_matriz_confusion.png','04_curva_aprendizaje.png','05_importancia_variables.png','metricas_modelos.json','priorizacion_controles_prueba.csv','prediccion_control_nuevo.csv','INFORME_RESULTADOS.md'):
        assert (base/'resultados'/archivo).stat().st_size > 0, archivo
    print('TODAS LAS PRUEBAS FINALIZARON CORRECTAMENTE')

if __name__ == '__main__':
    verificar()
