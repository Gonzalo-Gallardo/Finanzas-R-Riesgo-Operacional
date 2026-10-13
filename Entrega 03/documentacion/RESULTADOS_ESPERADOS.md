# Valores de referencia para verificar la ejecución

Los siguientes resultados se derivan del universo embebido en el MVP original y sirven como **referencia** y fueron contrastados con la ejecución local informada desde Positron. No corresponden a datos productivos ni a una serie histórica.

- `riesgos`: **10**
- `controles`: **12**
- `riesgos_sin_control`: **0**
- `pct_riesgos_sin_control`: **0**
- `controles_sin_evidencia`: **4**
- `pct_controles_sin_evidencia`: **33.33**
- `controles_deficientes`: **2**
- `planes_vencidos`: **1**
- `prioridad_alta`: **2**
- `pct_prioridad_alta`: **16.67**
- `puntajes_faltantes`: **0**
- `ids_control_duplicados`: **0**
- `deficientes_sin_plan`: **0**

Distribución de prioridades de referencia: Alta 2, Media 6, Baja 4. Si los resultados reales difieren, revisar la versión de Entrega 02 antes de enviar.

**Comprobación adicional:** tras la inicialización de `renv` en la raíz, las pruebas de Entrega 03 y el render Quarto finalizaron correctamente. La reproducción desde un clon nuevo sigue siendo una verificación posterior a la publicación.
