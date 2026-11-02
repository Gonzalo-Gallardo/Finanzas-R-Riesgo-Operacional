# -*- coding: utf-8 -*-
"""Evaluación y priorización de controles de riesgo operacional.

Trabajo final | Diplomado en Ciencia de Datos para las Finanzas
Autor: Gonzalo Gallardo Alvarado
Metodología: red neuronal artificial (MLP) y regresión logística comparativa.
Datos sintéticos para fines académicos.
"""
from pathlib import Path
import os
import sys
import subprocess
import tempfile
import hashlib
import venv

BASE = Path(__file__).resolve().parent
MODELO = BASE / 'modelo_red_neuronal_riesgo_operacional.py'
REQUISITOS = BASE / 'requirements.txt'


def entorno_graficos():
    env = os.environ.copy()
    env['MPLBACKEND'] = 'Agg'
    return env


def interpretes_disponibles():
    """Prioriza Python operativo; admite instalaciones previas sin mover entornos."""
    yield Path(sys.executable)
    yield BASE / '.entorno_proyecto' / 'Scripts' / 'python.exe'
    yield BASE / '.entorno_proyecto' / 'bin' / 'python'
    anterior = (Path.home() / 'Downloads' /
                'Entrega_Final_ANN_Riesgo_Operacional_VERSION_FACIL_SPYDER' /
                'Entrega_Final_ANN_Riesgo_Operacional' / '.entorno_proyecto' /
                'Scripts' / 'python.exe')
    yield anterior


def apto(python):
    if not python.is_file():
        return False
    try:
        proceso = subprocess.run(
            [str(python), '-c', 'import numpy, pandas, sklearn, matplotlib'],
            cwd=str(BASE), env=entorno_graficos(), capture_output=True,
            text=True, timeout=25)
        return proceso.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False


def seleccionar_python():
    for candidato in interpretes_disponibles():
        if apto(candidato):
            return candidato
    # Ruta breve, independiente de la carpeta de entrega; evita rutas largas de Windows.
    huella = hashlib.sha256(str(BASE).encode('utf-8')).hexdigest()[:8]
    raiz = Path(tempfile.gettempdir()) / ('ro_ann_' + huella)
    python = raiz / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
    if not python.is_file():
        print('Preparando entorno científico independiente...', flush=True)
        venv.EnvBuilder(with_pip=True).create(str(raiz))
    if not apto(python):
        print('Instalando dependencias científicas...', flush=True)
        # Sin captura: los mensajes reales de pip quedan visibles si falla la instalación.
        subprocess.run([str(python), '-m', 'pip', 'install', '--disable-pip-version-check',
                        '-r', str(REQUISITOS)], cwd=str(BASE), env=entorno_graficos(), check=True)
    if not apto(python):
        raise RuntimeError('No se pudo importar las dependencias instaladas.')
    return python


def principal():
    print('=' * 74)
    print('DIPLOMADO EN CIENCIA DE DATOS PARA LAS FINANZAS')
    print('EVALUACIÓN Y PRIORIZACIÓN DE CONTROLES DE RIESGO OPERACIONAL')
    print('MEDIANTE REDES NEURONALES ARTIFICIALES')
    print('Autor: Gonzalo Gallardo Alvarado')
    print('=' * 74, flush=True)
    try:
        python = seleccionar_python()
        print('Iniciando entrenamiento y evaluación de modelos...', flush=True)
        subprocess.run([str(python), str(MODELO)], cwd=str(BASE),
                       env=entorno_graficos(), check=True)
        print('PROCESAMIENTO FINALIZADO CORRECTAMENTE', flush=True)
    except Exception as exc:
        print('No se pudo repetir el entrenamiento:', exc)
        resultados = BASE / 'resultados'
        if (resultados / 'metricas_modelos.json').is_file():
            print('Los resultados académicos previamente generados están disponibles en:')
            print(resultados)
            print('ATENCIÓN: esta ejecución NO realizó un entrenamiento nuevo.')
        else:
            raise


if __name__ == '__main__':
    principal()
