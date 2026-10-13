# Finanzas en R | Riesgo Operacional

**Autor:** Gonzalo Gallardo  
**Proyecto:** Revisión y priorización de riesgos y controles mediante R  
**Curso:** Finanzas en R

## 1. Descripción del proyecto

Este proyecto desarrolla una solución reproducible en R para apoyar la identificación, revisión, evaluación y priorización de riesgos operacionales y sus controles asociados.

La herramienta integra información sobre probabilidad, impacto, características de los controles, resultados de revisión, evidencias y planes de acción. A partir de reglas explícitas, genera una matriz priorizada y reportes para apoyar el seguimiento de situaciones que requieren atención.

El alcance corresponde a un prototipo funcional (MVP) de apoyo al análisis. La priorización no sustituye el juicio profesional ni constituye una predicción de pérdidas operacionales.

## 2. Objetivos

- Estructurar y relacionar riesgos operacionales con sus controles.
- Validar la calidad, integridad y coherencia de los datos.
- Calcular niveles de riesgo mediante probabilidad e impacto.
- Priorizar controles según criterios definidos en el modelo.
- Identificar alertas sobre evidencias, resultados de revisión y planes de acción.
- Generar reportes y métricas de monitoreo reproducibles.

## 3. Entregas del proyecto

### Entrega 01 | Definición del problema

Presenta la problemática de riesgo operacional, los objetivos, el alcance, la relación entre riesgos y controles y las matrices de riesgo que fundamentan la solución.

### Entrega 02 | Desarrollo del MVP en R

Implementa el procesamiento de riesgos y controles, las validaciones de datos, el cálculo de puntajes y la priorización de resultados mediante código R.

### Entrega 03 | Proyecto final

Integra el MVP, las pruebas de validación, las pruebas negativas, los indicadores de monitoreo y la generación de un informe final reproducible mediante Quarto.

## 4. Estructura general del repositorio

```text
Finanzas-R-Riesgo-Operacional/
├── Entrega 01/
├── Entrega 02/
│   └── riesgo_operacional_mvp.R
├── Entrega 03/
│   ├── codigo/
│   │   ├── pruebas_entrega03.R
│   │   └── pruebas_negativas.R
│   ├── reportes/
│   └── reporte_final.qmd
├── renv/
│   ├── activate.R
│   └── settings.json
├── .Rprofile
├── renv.lock
├── EJECUTAR_PROYECTO.R
└── README.md
```

Los reportes se generan o actualizan al ejecutar el proyecto.

## 5. Requisitos

- R (proyecto desarrollado y comprobado con R 4.6.1).
- Positron, RStudio u otro entorno compatible con R.
- Quarto instalado y disponible en el sistema para regenerar el informe HTML.
- Conexión a Internet para descargar las dependencias si no están instaladas.

Las versiones de los paquetes R están registradas en `renv.lock` y se administran mediante `renv`.

## 6. Instalación y ejecución paso a paso

### Paso 1. Descargar el proyecto

En GitHub, seleccionar **Code > Download ZIP** y descomprimir el archivo.

### Paso 2. Abrir la carpeta correcta

Abrir en Positron o RStudio la carpeta interna del repositorio que contiene directamente:

- `renv.lock`
- `.Rprofile`
- `EJECUTAR_PROYECTO.R`
- `Entrega 01`, `Entrega 02` y `Entrega 03`

**Importante:** algunos programas de descompresión crean una carpeta exterior adicional con el mismo nombre. Debe abrirse la carpeta que contiene directamente los archivos anteriores, no la carpeta exterior.

### Paso 3. Activar y restaurar dependencias

Al abrir el proyecto, `.Rprofile` permite activar `renv`. Si el entorno solicita reiniciar R, reiniciar la sesión.

En la consola de R, ejecutar:

```r
renv::restore()
```

Si R solicita confirmar la instalación de paquetes, responder `Y`.

Comprobar la consistencia del entorno:

```r
renv::status()
```

Resultado esperado:

```text
No issues found -- the project is in a consistent state.
```

Si `renv` no está disponible, instalarlo una vez con:

```r
install.packages("renv")
```

Luego repetir `renv::restore()`.

### Paso 4. Ejecutar el proyecto completo

Desde la carpeta principal del repositorio, ejecutar:

```r
source("EJECUTAR_PROYECTO.R")
```

Este único comando:

1. Ejecuta y valida el MVP de riesgo operacional.
2. Genera los reportes de la Entrega 03.
3. Ejecuta las pruebas negativas del validador.
4. Genera el informe final HTML mediante Quarto, si está disponible.

Al terminar correctamente, la consola muestra:

```text
=== VALIDACIÓN COMPLETADA SIN ERRORES EN R ===
```

El informe se genera en:

```text
Entrega 03/reporte_final.html
```

**Nota:** si Quarto no está disponible en el sistema, el script informa esta situación y no regenera el HTML. Para una reproducción completa del informe se requiere Quarto.

## 7. Resultados de referencia

En la ejecución de comprobación del proyecto se obtuvieron los siguientes resultados:

| Indicador | Resultado |
|---|---:|
| Riesgos analizados | 10 |
| Controles analizados | 12 |
| Riesgos sin controles asociados | 0 |
| Controles de prioridad alta | 2 |
| Controles de prioridad media | 6 |
| Controles de prioridad baja | 4 |
| Controles sin evidencia | 4 |
| Controles deficientes | 2 |
| Planes de acción vencidos | 1 |

Las validaciones del MVP y las pruebas negativas se ejecutaron correctamente. El informe Quarto también se generó exitosamente.

## 8. Criterios de análisis y validaciones

La solución evalúa la exposición al riesgo mediante probabilidad e impacto, y considera los resultados de los controles para establecer prioridades de revisión.

Entre las comprobaciones implementadas se incluyen:

- Identificadores de riesgos y controles sin duplicados.
- Probabilidad e impacto dentro de la escala de 1 a 5.
- Puntajes de riesgo correctamente calculados.
- Controles asociados a riesgos existentes.
- Coherencia entre resultados de revisión y planes de acción.
- Validación de categorías y puntajes de prioridad.
- Pruebas negativas para comprobar la detección de entradas inválidas.

La metodología y los criterios de priorización se desarrollan en los archivos del proyecto y el informe final.

## 9. Monitoreo y uso de resultados

El MVP genera indicadores para revisar la cobertura de controles, la disponibilidad de evidencia, los resultados deficientes, el estado de los planes de acción y la distribución de prioridades.

Estos resultados pueden apoyar revisiones periódicas, seguimiento de planes y propuestas de mejora del ambiente de control.

## 10. Reproducibilidad

El proyecto fue comprobado a partir de una descarga nueva del repositorio en un entorno Windows con R 4.6.1 y `renv` 1.2.4.

Se verificaron:

- Restauración de 48 dependencias registradas en el archivo de bloqueo.
- Estado consistente del entorno mediante `renv::status()`.
- Ejecución del MVP y sus validaciones.
- Ejecución de pruebas negativas.
- Generación de reportes y del informe HTML con Quarto.
- Finalización del script principal sin errores.

Para reproducir los resultados, se recomienda utilizar las versiones de dependencias especificadas en `renv.lock`.

---

**Autor:** Gonzalo Gallardo  
**Proyecto académico:** Finanzas en R — Riesgo Operacional
