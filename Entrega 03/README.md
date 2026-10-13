# Entrega 03 — Proyecto final de Finanzas en R

**Autor:** Gonzalo Gallardo  
**Proyecto:** Revisión y priorización de riesgos y controles de Riesgo Operacional  
**Estado:** MVP funcional y validado localmente; despliegue y monitoreo operativo propuestos.

Esta entrega consolida los seis apartados de la pauta: solución de negocio, planificación, MVP, documentación, despliegue y monitoreo. **Complementa las Entregas 01 y 02; no las reemplaza.**

## Contenido

| Ruta | Contenido |
|---|---|
| `reporte_final.qmd` | Fuente Quarto del informe final, con tablas, gráficos, Gantt y flujo |
| `reporte_final.html` | Informe HTML generado |
| `codigo/ejecutar_entrega03.R` | Ejecuta el MVP de Entrega 02 y exporta los CSV |
| `codigo/monitoreo_mvp.R` | Calcula métricas y distribución de prioridades |
| `codigo/pruebas_entrega03.R` | Pruebas automatizadas de integración y regresión de indicadores y CSV |
| `codigo/verificar_publicacion.R` | Comprueba estructura y estado de `renv` una vez integrado el repositorio |
| `codigo/validar_entradas.R` | Función independiente para validar esquemas, duplicados, escalas y referencias de futuros datos externos |
| `codigo/pruebas_negativas.R` | Pruebas de rechazo con entradas intencionalmente inválidas para la función de validación |
| `documentacion/PROYECTO_FINAL.md` | Desarrollo de los seis criterios de la pauta |
| `documentacion/DIAGRAMA_FLUJO.md` | Diagrama de flujo lógico y alcance |
| `documentacion/DICCIONARIO_DATOS.md` | Variables, orígenes y reglas de transformación |
| `documentacion/PLAN_PRUEBAS.md` | Pruebas, resultados y pendientes |
| `documentacion/RESULTADOS_ESPERADOS.md` | Valores de referencia de la ejecución validada |
| `reportes/` | Salidas CSV del MVP |

## Requisitos y estructura

Abrir **la raíz del repositorio** en Positron o R. `Entrega 02/` y `Entrega 03/` deben ser carpetas hermanas, porque el código de esta entrega reutiliza `Entrega 02/riesgo_operacional_mvp.R`.

Para reproducibilidad, en **la raíz del repositorio** deben existir `.Rprofile`, `renv.lock` y `renv/activate.R` junto con `renv/settings.json`. Estos archivos corresponden al entorno inicializado y validado localmente con R 4.6.1 y `renv` 1.2.4; **no se debe subir `renv/library/` ni `renv/staging/`**. Quarto debe estar instalado en el equipo para regenerar HTML.

**Este paquete incluye** los archivos reales de `renv` en la raíz del ZIP: `.Rprofile`, `renv.lock`, `renv/activate.R`, `renv/settings.json` y `renv/.gitignore`. Al integrar el paquete en GitHub, estos archivos deben quedar en la **raíz del repositorio**, al mismo nivel que las carpetas `Entrega 01`, `Entrega 02` y `Entrega 03`. El `renv.lock` de `Entrega 02` se conserva como antecedente histórico; el de la raíz es el que utiliza el proyecto integrado.

En una instalación nueva, abrir R desde la raíz y recuperar las dependencias:

```r
renv::restore()
renv::status()
```

Si la sesión solicita reinicio tras activar `renv`, reiniciar R antes de continuar.

## Ejecución y pruebas

Desde la consola de R **ubicada en la raíz**:

```r
source("Entrega 03/codigo/pruebas_entrega03.R")
source("Entrega 03/codigo/pruebas_negativas.R")
```

El primer comando ejecuta el MVP original, calcula el monitoreo, exporta los CSV y comprueba la integración. El segundo comprueba escenarios negativos del validador auxiliar. Los mensajes esperados son:

```text
PRUEBAS ENTREGA 03: SUPERADAS
PRUEBAS NEGATIVAS DEL VALIDADOR AUXILIAR: SUPERADAS
```

Para generar nuevamente el informe HTML desde la raíz, en una terminal con Quarto:

```sh
quarto render "Entrega 03/reporte_final.qmd" --to html
```

Alternativamente, desde la consola de R:

```r
system2("quarto", c("render", shQuote("Entrega 03/reporte_final.qmd")))
```

El HTML se escribe en `Entrega 03/reporte_final.html`.

## Comprobación antes de publicar en GitHub

Una vez que la raíz contenga `Entrega 01`, `Entrega 02`, `Entrega 03`, `.Rprofile`, `renv.lock`, `renv/activate.R` y `renv/settings.json`, ejecutar:

```r
source("Entrega 03/codigo/verificar_publicacion.R")
source("Entrega 03/codigo/pruebas_entrega03.R")
```

Ejecute además `source("Entrega 03/codigo/pruebas_negativas.R")` para comprobar el rechazo de entradas inválidas. Estas pruebas corresponden al validador de entradas futuras, no a la mutación del conjunto embebido del MVP. **Las nuevas pruebas requieren ejecución local antes de declarar que fueron superadas.** Para publicar por la web de GitHub, verificar que se mantengan las carpetas y no se incluya `renv/library/`.

## Resultados de la validación local

En Positron se ejecutaron satisfactoriamente las pruebas de integración y la generación del HTML con el entorno `renv` sincronizado: **10 riesgos, 12 controles, 0 riesgos sin control, 2 controles de prioridad alta, 6 media y 4 baja**. Se observaron **4 controles sin evidencia, 2 deficientes y 1 plan vencido**. Los resultados de esta muestra no son indicadores históricos de producción.

## Método, límites y uso responsable

La criticidad es `probabilidad × impacto` (escala de 1 a 5). La prioridad de revisión agrega puntos por alertas y características del control. **No es un modelo predictivo ni un sistema de decisiones automáticas.** Los datos de ejemplo están definidos dentro del script de Entrega 02; no se conectan fuentes bancarias externas. El despliegue productivo, la ingesta automatizada, las alertas externas y la comparación histórica son propuestas sujetas a autorización y validación.

Las reglas, limitaciones, responsables, pruebas pendientes y procedimientos de monitoreo están documentados en `documentacion/` y en el informe final.

## Alcance de las pruebas nuevas

`codigo/pruebas_negativas.R` prueba la función auxiliar `validar_entradas()` con casos alterados (IDs duplicados, escala inválida, referencias inexistentes y riesgos sin controles). **No modifica el MVP original de Entrega 02 ni constituye prueba de integración con fuentes externas.** En un despliegue futuro, el validador debe incorporarse al flujo de ingesta antes del cálculo de prioridades.

## Criterio de cierre

No considerar la versión validada hasta ejecutar los dos scripts de prueba y regenerar Quarto desde el repositorio integrado. La revisión estática del ZIP no sustituye esas ejecuciones.
